//
//  NSManagedObject+BIGMappingAdditions.m
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#import "NSManagedObject+BIGMappingAdditions.h"
#import "BigRest-Internal.h"

static NSString *_defaultPrimaryKeyProperty;
static NSString *_defaultPrimaryKeyPath;

static NSDateFormatter *_defaultDateFormatter;

@implementation NSManagedObject (BIGMappingAdditions)

+ (EKManagedObjectMapping*) objectMapping {
    
    return [EKManagedObjectMapping mappingForEntityName:NSStringFromClass(self) withBlock:^(EKManagedObjectMapping *mapping) {
        
        [mapping mapPropertiesFromArray:[[[self MR_entityDescription] attributesByName] allKeys]];
        
        // TODO: Make this conditionally set a primary key based on userInfo from the managed object model
        
    }];
}

+ (NSDateFormatter*) BIG_dateFormatter
{
	if (!_defaultDateFormatter) {
		// ISO 8601 Date
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
		[dateFormatter setLocale:enUSPOSIXLocale];
		//[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
	
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];


		_defaultDateFormatter = dateFormatter;
	}
	
	return _defaultDateFormatter;
}

+ (void) BIG_setDefaultDateFormatter:(NSDateFormatter*)dateFormatter
{
	_defaultDateFormatter = dateFormatter;
}

+ (void) BIG_setPrimaryKeyProperty:(NSString*)keyProperty
{
    _defaultPrimaryKeyProperty = keyProperty;
}

+ (void) BIG_setPrimaryKeyPath:(NSString*)keyPath
{
    _defaultPrimaryKeyPath = keyPath;
}

+ (NSString*) BIG_primaryKeyProperty
{
    return _defaultPrimaryKeyProperty;
}

+ (NSString*) BIG_primaryKeyPath
{
    return _defaultPrimaryKeyPath;
}

- (NSString*) BIG_primaryKeyPropertyValue
{
    NSString *primaryKeyPropery = [[self class] objectMapping].primaryKey;
    return [self valueForKey:primaryKeyPropery];
}


+ (NSString*) BIG_deletedNotificationName
{
    NSString *notificationNameString = [NSString stringWithFormat:@"BIG_%@_DELETED_NOTIFICATION",NSStringFromClass(self)];
    return notificationNameString;
}

+ (NSString*) BIG_savedNotificationName
{
    NSString *notificationNameString = [NSString stringWithFormat:@"BIG_%@_SAVED_NOTIFICATION",NSStringFromClass(self)];
    return notificationNameString;
}

+ (NSArray*) BIG_arrayOfEntitiesWithArray:(NSArray*)arrayOfRepresentations
{
    // TODO: remove the identifier property of all objects...
    __block NSArray *entities = nil;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context]];
	
	entities = [EKManagedObjectMapper arrayOfObjectsFromExternalRepresentation:arrayOfRepresentations withMapping:[[self class] objectMapping]  inManagedObjectContext:context];
    
    return entities;
    
}

+ (NSArray*) BIG_arrayOfRepresentationsWithEntities:(NSArray*)objects
{
    NSArray *collectionRepresentation = [EKSerializer serializeCollection:objects withMapping:[[self class] objectMapping]];
    
    return _.arrayMap(collectionRepresentation,^NSDictionary* (NSDictionary *representation){
        
        NSMutableDictionary *mutable = [representation mutableCopy];
        
        //[mutable removeObjectForKey:@"identifier"];
        return mutable;
    });
}

+ (instancetype) BIG_entityWithDictionary:(NSDictionary*)dictionaryRepresentation
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    
    [managedObject BIG_updateWithDictionary:dictionaryRepresentation];
    
    return managedObject;
}

+ (instancetype) BIG_serializeAndSaveOneEntity:(NSDictionary*)objectDictionary
{
    id entity = [self BIG_upsertWithDictionary:objectDictionary];
    [((NSManagedObject*)entity).managedObjectContext MR_saveToPersistentStoreAndWait];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *entityDicts = @[];
        
        @try {
            id<BIGRestfulObject> object = entity;
            if ([[object class] objectMapping].primaryKey) {
                
                entityDicts = @[[entity valueForKey:[[object class] objectMapping].primaryKey]];
                
            } else {
                
                entityDicts = @[[entity BIG_dictionaryRepresentation]];
            }
        }
        @catch (NSException *exception) {
            NSString *className = NSStringFromClass(self);
            //DDLogError(@"%@ BIG_serializeAndSaveOneEntity:",className);
        }
        @finally {
            [[NSNotificationCenter defaultCenter] postNotificationName:[self BIG_savedNotificationName] object:entityDicts];
        }
        
    });

    
    return entity;
}


+ (NSArray*) BIG_serializeAndSaveManyEntities:(NSArray*)objectDictionaryArray
{
    NSArray *entities = [self BIG_arrayOfEntitiesWithArray:objectDictionaryArray];
    
    if (entities && entities.count > 0) {
       
        id<BIGRestfulObject> object = entities[0];
        NSString *primaryKey = nil;
        if ([[object class] objectMapping].primaryKey) {
           primaryKey = [[[object class] objectMapping].primaryKey copy];
           
            
        }
        
        NSManagedObjectContext *context = ((NSManagedObject*)entities[0]).managedObjectContext;
        
        [context MR_saveToPersistentStoreAndWait];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *entityDicts = @[];
            
            @try {
                
                if (primaryKey) {
                   
                    entityDicts = _.pluck(entities,primaryKey);
                    
                } else {
                    
                    entityDicts = _.arrayMap(entities,^id(NSManagedObject *managedObject) {
                        
                        if (managedObject) {
                            return [[managedObject MR_inThreadContext] BIG_dictionaryRepresentation];
                        } else {
                            return @{};
                        }
                        
                    });
                }

            }
            @catch (NSException *exception) {
                NSString *className = NSStringFromClass(self);
                //DDLogError(@"%@ BIG_serializeAndSaveManyEntities:",className);
            }
            @finally {
                [[NSNotificationCenter defaultCenter] postNotificationName:[self BIG_savedNotificationName] object:entityDicts];
            }
            
            
        });
    }
    
    return entities;
}


+ (instancetype) BIG_upsertWithDictionary:(NSDictionary*)dictionaryRepresentation
{
    NSManagedObject *managedObject = nil;
    
    BOOL isUnique = [self BIG_primaryKeyProperty] && [self BIG_primaryKeyPath];
    
    if (isUnique) {
        
        managedObject = [self MR_findFirstByAttribute:[self BIG_primaryKeyProperty] withValue:dictionaryRepresentation[[self BIG_primaryKeyPath]]];
        
    }
    
    if (managedObject) {
        
        [managedObject BIG_updateWithDictionary:dictionaryRepresentation];
        
    } else {
        
        managedObject = [self BIG_entityWithDictionary:dictionaryRepresentation];
    }
    
    return managedObject;
}


- (void) BIG_updateWithDictionary:(NSDictionary*)dictionaryRepresentation
{
    [EKManagedObjectMapper fillObject:self fromExternalRepresentation:dictionaryRepresentation withMapping:[[self class] objectMapping] inManagedObjectContext:self.managedObjectContext];
}

- (NSDictionary*) BIG_dictionaryRepresentation
{
    NSMutableDictionary *representation = [[EKSerializer serializeObject:self withMapping:[[self class] objectMapping] fromContext:self.managedObjectContext] mutableCopy];
    //[representation removeObjectForKey:@"identifier"];
    [representation removeObjectForKey:@"created"];
    [representation removeObjectForKey:@"last_updated"];
    return representation;
}

@end
