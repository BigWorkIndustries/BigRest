//
//  BIGRestfulObject.h
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#import <Foundation/Foundation.h>
#import "EKMappingProtocol.h"

@protocol BIGMappableObject <NSObject,EKManagedMappingProtocol>

/**
 *  The default date formatter used to transalte from JSON dates to NSDate. If not set, then defaults to ISO8601 "yyyy-MM-dd'T'HH:mm:ssZZZZZ".
 *
 * @discussion Callers should override this method for exception cases on a per class basis.
 *
 *  @return An instantiated date formatter.
 */
+ (NSDateFormatter*) BIG_dateFormatter;

/**
 *  Sets the default date formatter.
 *
 *  @param dateFormatter An instantiated date formatter.
 */
+ (void) BIG_setDefaultDateFormatter:(NSDateFormatter*)dateFormatter;

/**
 *  Set the default primary key property for objects globally.
 *
 *  @param keyProperty The primary key property as is set in the CoreData model editor.
 */
+ (void) BIG_setPrimaryKeyProperty:(NSString*)keyProperty;

/**
 *  Set the default primary key path to be found in JSON responses.
 *
 *  @param keyPath The key path for the primary key found in JSON responses.
 */
+ (void) BIG_setPrimaryKeyPath:(NSString*)keyPath;

/**
 *  Returns the default primary key property for objects. This property can be overridden.
 *
 *  @return A string representing the primary key property.
 */
+ (NSString*) BIG_primaryKeyProperty;

/**
 *  Returns the default primary key path to be found in JSON responses. This property can be overridden.
 *
 *  @return A string representing the primary key path.
 */
+ (NSString*) BIG_primaryKeyPath;


/**
 *  The value of the promary key property if set.
 *
 *  @return The vlaue of the primary key property if any.
 */
- (NSString*) BIG_primaryKeyPropertyValue;

/**
 *  Serializes an array of NSManagedObject subclass instances to an array of NSDictionary representations.
 *
 *  @param arrayOfRepresentations An array of NSManagedObject subclass instances.
 *
 *  @return An array of NSManagedObject subclass instances.
 *
 *
 *  @discussion This method operates on the NSManagedObjectContext for the current thread and does not save the instances to the local persistent store. This is the responsibility of the caller.
 */
+ (NSArray*) BIG_arrayOfEntitiesWithArray:(NSArray*)arrayOfRepresentations;


/**
 *  Serializes an array of NSDictionary representions to NSManagedObject subclass instances.
 *
 *  @param entities An array of NSDictionary representations.
 *
 *  @return An array of NSDictionary representations.
 *
 */
+ (NSArray*) BIG_arrayOfRepresentationsWithEntities:(NSArray*)entities;


/**
 *  The name of the notification that will be posted when an object is deleted using the deleteEntities: REST method.
 *
 *  @return A string value representing the notification name;
 */
+ (NSString*) BIG_deletedNotificationName;


/**
 *  Serializes an NSDictionary representions to a NSManagedObject subclass instance.
 *
 *  @param dictionaryRepresentation A NSDictionary representation of the object.
 *
 *  @return A NSManagedObject subclass instance.
 *
 *  @discussion This method operates on the NSManagedObjectContext for the current thread and does not save the instances to the local persistent store. This is the responsibility of the caller.
 */
+ (instancetype) BIG_entityWithDictionary:(NSDictionary*)dictionaryRepresentation;


/**
 *  The name of the notification that will be posted when an object or objects are saved using the serializeAndSaveOneEntity: or serializeAndSaveManyEntities: methods.
 *
 *  @return A string value representing the notification name;
 */
+ (NSString*) BIG_savedNotificationName;


/**
 *  Serializes a single device object to an NSManagedObject and saves it to the CoreData persistent store.
 *
 *  @param deviceDictionary A dictionary returned from the API back end that represents a device.
 *
 *  @return The entity created.
 */
+ (instancetype) BIG_serializeAndSaveOneEntity:(NSDictionary*)objectDictionary;


/**
 *  Serializes a collections of device objects to NSManagedObjects and saves them to the CoreData persistent store.
 *
 *  @param deviceDictionaryArray Ana rray of dictionaries returned from the API back end that represents a collection of devices.
 *
 *  @return The array of entities created.
 */
+ (NSArray*) BIG_serializeAndSaveManyEntities:(NSArray*)objectDictionaryArray;


/**
 *  Updates or creates a NSManagedObject subclass instance based on the supplied NSDictionary representation.
 *
 *  @param dictionaryRepresentation A NSDictionary representation to be inserted or updated.
 *
 *  @return A NSManagedObject subclass instance.
 *
 *  @discussion This method queries the local persistent store for any object having the identifier property value that corresponds to the _id key value of the dictionaryRepresentation. If an object with the corresponding identifier is found then updateWithDictionary: is called on that instance. If an object with the corresponding identifier is not found then entityWithDictionary: is called. This method operates on the NSManagedObjectContext for the current thread and does not save the instances to the local persistent store. This is the responsibility of the caller.
 */
+ (instancetype) BIG_upsertWithDictionary:(NSDictionary*)dictionaryRepresentation;



/**
 *  Returns a dictionary that can be used to make API calls. This method will return nil if it is not overridden.
 *
 *  @return A NSDictionary representation of the object suitable for API requests.
 */
- (NSDictionary*) BIG_dictionaryRepresentation;


/**
 *  Updates the current instance with the values of dictionaryRepresentation.
 *
 *  @param dictionaryRepresentation A NSDictionary representation of the object.
 *
 *  @discussion This method operates on the NSManagedObjectContext for the current thread and does not save the instances to the local persistent store. This is the responsibility of the caller.
 */
- (void) BIG_updateWithDictionary:(NSDictionary*)dictionaryRepresentation;


@end
