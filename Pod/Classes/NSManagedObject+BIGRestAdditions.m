//
//  NSManagedObject+BIGRestAdditions.m
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#import "NSManagedObject+BIGRestAdditions.h"
#import "BigRest-Internal.h"

static AFHTTPSessionManager *_BIGHTTPSessionManager;
static NSOperationQueue *_BIGBackgroundOperationQueue;

@implementation NSManagedObject (BIGRestAdditions)

+ (void) BIG_setBackgroundOperationQueue:(NSOperationQueue*)operationQueue
{
    _BIGBackgroundOperationQueue = operationQueue;
}

+ (NSOperationQueue*) BIG_BackgroundQueue
{
    if (!_BIGBackgroundOperationQueue) {
        _BIGBackgroundOperationQueue = [NSOperationQueue new];
        _BIGBackgroundOperationQueue.maxConcurrentOperationCount = 4;
    }
    
    return _BIGBackgroundOperationQueue;
}

+ (void) BIG_setHTTPSessionManager:(AFHTTPSessionManager*)HTTPSessionManager
{
    _BIGHTTPSessionManager = HTTPSessionManager;
}

+ (AFHTTPSessionManager*) BIG_HTTPSessionManager
{
    return _BIGHTTPSessionManager;
}

+ (NSString*) BIG_RESTPath
{
    return nil;
}

+ (NSString*) BIG_rootResponseElement
{
    return nil;
}

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping new];
}

#pragma mark - Entity Convenience Verbs -

+ (void) BIG_getRemoteEntitiesWithCompletion:(BIGRestCompletionBlock)completion
{
    [self BIG_getRemoteEntitiesAtPath:[self BIG_RESTPath] parameters:nil rootResponseElement:[self BIG_rootResponseElement] completion:completion];
}

+ (void) BIG_getRemoteEntityWithID:(NSString*)identifier withCompletion:(BIGRestCompletionBlock)completion
{
    [self BIG_getRemoteEntityAtPath:[self BIG_RESTPath] withID:identifier parameters:nil completion:completion];
}

+ (void) BIG_createRemoteEntity:(NSDictionary*)entityRepresentation withCompletion:(BIGRestCompletionBlock)completion
{
    [self BIG_createRemoteEntity:entityRepresentation atPath:[self BIG_RESTPath] completion:completion];
}

+ (void) BIG_deleteRemoteEntities:(NSArray*)entities withCompletion:(BIGRestCompletionBlock)completion
{
    [self BIG_deleteRemoteEntities:entities atPath:[self BIG_RESTPath] parameters:nil completion:completion];
}

+ (void) BIG_updateRemoteEntity:(id)entity withCompletion:(BIGRestCompletionBlock)completion
{
    [self BIG_updateRemoteEntity:entity atPath:[self BIG_RESTPath] completion:completion];
}

- (void) BIG_updateRemoteWithCompletion:(BIGRestCompletionBlock)completion
{
    [[self class] BIG_updateRemoteEntity:self withCompletion:completion];
}

#pragma mark - Entity Verb Base Method -

+ (void) BIG_createRemoteEntity:(NSDictionary*)entityRepresentation atPath:(NSString*)path completion:(BIGRestCompletionBlock)completion {
    //NSString *urlString = [NSString stringWithFormat:@"%@%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],[self RESTPath]];
    
    [[NSManagedObject BIG_HTTPSessionManager] POST:path parameters:entityRepresentation success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([self BIG_rootResponseElement] && [responseObject isKindOfClass:[NSDictionary class]]) {
			
			NSDictionary *responseDictionary = (NSDictionary*)responseObject;
			
			if (responseDictionary[[self BIG_rootResponseElement]]) {
			
				responseObject = responseDictionary[[self BIG_rootResponseElement]];
			}
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
			
            id entity = [self BIG_serializeAndSaveOneEntity:responseObject];
            
            if (completion) {
                completion(self,YES,nil,entity);
            }
			
		} else if ([responseObject isKindOfClass:[NSArray class]]) {
			
			NSArray *entities = [self BIG_serializeAndSaveManyEntities:responseObject];
			
			if (completion) {
				completion(self,YES,nil,entities);
			}
		
		} else {
			
            if (completion) {
                
                NSError *error = [NSError errorWithDomain:kBIGRestErrorDomain_UnexpectedType code:kBIGRestErrorCode_UnexpectedType userInfo:@{NSLocalizedFailureReasonErrorKey:responseObject}];
                
                completion(self,NO,error,nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self logError:error request:entityRepresentation path:[self BIG_RESTPath] object:task method:@"POST"];
        
        if (completion) {
            completion(self,NO,error,nil);
        }
    }];
}

+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion
{
    [self BIG_createRemoteEntities:requestDictionaries atPath:path parameters:params progress:nil completion:completion];
}


+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion {
    
    [self BIG_createRemoteEntities:requestDictionaries atPath:path parameters:params queue:[NSManagedObject BIG_BackgroundQueue] progress:progress completion:completion];
}


+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params queue:(NSOperationQueue*)operationQueue progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *mutableOperations = [NSMutableArray new];
        
        __block NSMutableArray *errors = [NSMutableArray new];
        __block NSError *requestError = nil;
        [requestDictionaries enumerateObjectsUsingBlock:^(NSDictionary *requestDictionary, NSUInteger idx, BOOL *stop) {
            NSMutableURLRequest *request = [[NSManagedObject BIG_HTTPSessionManager].requestSerializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],path] parameters:requestDictionary error:&requestError];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [[NSManagedObject BIG_HTTPSessionManager] responseSerializer];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if ([self BIG_rootResponseElement] && [responseObject isKindOfClass:[NSDictionary class]]) {
                    responseObject = ((NSDictionary*)responseObject)[[self BIG_rootResponseElement]];
                }
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    // Endpoint returns 201 if a new device was created.
                    [self BIG_serializeAndSaveOneEntity:responseObject];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self logError:error request:requestDictionary path:[self BIG_RESTPath] object:operation.request method:@"POST"];
                
                [errors addObject:error];
            }];
            [mutableOperations addObject:operation];
        }];
        
        if (requestError) {
            [errors addObject:requestError];
        }
        
        NSArray *operations = nil;
        
        operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            
            //DDLogVerbose(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
            
            if (progress) {
                progress(self,YES,nil,@{@"numberOfFinishedOperations":[NSNumber numberWithUnsignedInteger:numberOfFinishedOperations],@"totalNumberOfOperations":[NSNumber numberWithUnsignedInteger:totalNumberOfOperations]});
            }
            
        } completionBlock:^(NSArray *operations) {
            
        }];
        
        [operationQueue addOperations:mutableOperations waitUntilFinished:YES];
        
        if (completion) {
            
            if (errors.count > 0) {
                
                completion(self,NO,errors[0],errors);
                
            } else {
                
                completion(self,YES,nil,operations);
            }
            
        }
        
        
    });
}


+ (void) BIG_deleteRemoteEntity:(NSManagedObject*)entity completion:(BIGRestCompletionBlock)completion {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],[self BIG_RESTPath],[entity BIG_primaryKeyPropertyValue]];
    
    NSArray *entityDicts = nil;
    if (entity) {
        
        id<BIGRestfulObject> object = entity;
        if ([[object class] objectMapping].primaryKey) {
            
            entityDicts = @[[entity valueForKey:[[object class] objectMapping].primaryKey]];
            
        } else {
            
            entityDicts = @[[entity BIG_dictionaryRepresentation]];
        }
    }
    
    [[NSManagedObject BIG_HTTPSessionManager] DELETE:urlString parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
            [entity MR_deleteEntity];
        }];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[self BIG_savedNotificationName] object:entityDicts];
            
        });
        
        
        if (completion) {
            completion(self,YES,nil,entity);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSString *entityDescription = [[entity BIG_dictionaryRepresentation] description];
        [self logError:error request:entityDescription path:[self BIG_RESTPath] object:task method:@"DELETE"];
        
        if (completion) {
            completion(self,NO,error,nil);
        }
        
    }];
}


+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion
{
    [self BIG_deleteRemoteEntities:entities atPath:path parameters:params progress:nil completion:completion];
}


+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion
{
    [self BIG_deleteRemoteEntities:entities atPath:path parameters:params queue:[NSManagedObject BIG_BackgroundQueue] progress:progress completion:completion];
}


+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params queue:(NSOperationQueue*)operationQueue progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *mutableOperations = [NSMutableArray new];
        
        __block NSMutableArray *errors = [NSMutableArray new];
        __block NSError *requestError = nil;
        
        NSArray *entityDicts = nil;
        
        if (entities && entities.count > 0) {
            
            id<BIGRestfulObject> object = entities[0];
            if ([[object class] objectMapping].primaryKey) {
                
                entityDicts = _.pluck(entities,[[object class] objectMapping].primaryKey);
                
            } else {
                
                entityDicts = _.arrayMap(entities,^id(NSManagedObject *managedObject) {
                    
                    return [managedObject BIG_dictionaryRepresentation];
                    
                });
            }
        }
        
        [entities enumerateObjectsUsingBlock:^(NSManagedObject *entity, NSUInteger idx, BOOL *stop) {
            
            NSString *entityString = [entity description];
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
                [entity MR_deleteEntity];
            }];
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],path,[entity BIG_primaryKeyPropertyValue]];
            NSMutableURLRequest *request = [[NSManagedObject BIG_HTTPSessionManager].requestSerializer requestWithMethod:@"DELETE" URLString:urlString parameters:nil error:&requestError];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [[AFJSONResponseSerializer alloc] init];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self logError:error request:entityString path:[self BIG_RESTPath] object:operation.request method:@"DELETE"];
                
                [errors addObject:error];
            }];
            
            [mutableOperations addObject:operation];
            
        }];
        
        
        if (requestError) {
            [errors addObject:requestError];
        }
        
        NSArray *operations = nil;
        
        operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            //DDLogVerbose(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
            
            if (progress) {
                progress(self,YES,nil,@{@"numberOfFinishedOperations":[NSNumber numberWithUnsignedInteger:numberOfFinishedOperations],@"totalNumberOfOperations":[NSNumber numberWithUnsignedInteger:totalNumberOfOperations]});
            }
            
        } completionBlock:^(NSArray *operations) {
            
            
            
        }];
        
        [operationQueue addOperations:mutableOperations waitUntilFinished:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[self BIG_deletedNotificationName] object:entityDicts];
            
        });
        
        if (completion) {
            
            if (errors.count > 0) {
                
                completion(self,NO,errors[0],errors);
                
            } else {
                
                completion(self,YES,nil,operations);
            }
        }
        
    });
}


+ (void) BIG_getRemoteEntitiesAtPath:(NSString*)path parameters:(NSDictionary*)params rootResponseElement:(NSString*)rootElement completion:(BIGRestCompletionBlock)completion
{
    [[NSManagedObject BIG_HTTPSessionManager] GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        /*
        if ([self BIG_rootResponseElement] && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *maybeResult = ((NSDictionary*)responseObject)[[self BIG_rootResponseElement]];
			
			if (maybeResult) {
				responseObject = maybeResult;
			}
        }
        */
        NSArray *response = [self BIG_getRootElement:rootElement withResponse:responseObject];
        
        if ([response isKindOfClass:[NSArray class]]) {
            
            NSArray *entities = [self BIG_serializeAndSaveManyEntities:response];
            
            if (completion) {
                completion(self,YES,nil,entities);
            }
        } else {
            if (completion) {
                
                NSError *error = [NSError errorWithDomain:kBIGRestErrorDomain_UnexpectedType code:kBIGRestErrorCode_UnexpectedType userInfo:@{NSLocalizedFailureReasonErrorKey:responseObject}];
                
                completion(self,NO,error,nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error request:params path:[self BIG_RESTPath] object:task method:@"GET"];
        if (completion) {
            completion(self,NO,error,nil);
        }
    }];
}

+ (void) BIG_getRemoteEntityAtPath:(NSString*)path withID:(NSString*)identifier parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion
{
    NSString *urlString = nil;
    
    if (identifier) {
        
        urlString = [NSString stringWithFormat:@"%@/%@",path,identifier];
        
    } else {
        
        urlString = [NSString stringWithFormat:@"%@",path];
    }
    
    [self BIG_getRemoteEntityAtPath:urlString parameters:params rootResponseElement:[self BIG_rootResponseElement] completion:completion];
    
}

+ (void) BIG_getRemoteEntityAtPath:(NSString*)path parameters:(NSDictionary*)params rootResponseElement:(NSString*)rootElement completion:(BIGRestCompletionBlock)completion
{
    [[NSManagedObject BIG_HTTPSessionManager] GET:path parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        
        /*
        if ([self BIG_rootResponseElement] && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *maybeResult = ((NSDictionary*)responseObject)[[self BIG_rootResponseElement]];
			
			if (maybeResult) {
				responseObject = maybeResult;
			}
			
        }
        */
        
        NSDictionary *response = [self BIG_getRootElement:rootElement withResponse:responseObject];
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            id entity = [self BIG_serializeAndSaveOneEntity:response];
            
            if (completion) {
                completion(self,YES,nil,entity);
            }
        } else {
            if (completion) {
                
                NSError *error = [NSError errorWithDomain:kBIGRestErrorDomain_UnexpectedType code:kBIGRestErrorCode_UnexpectedType userInfo:@{NSLocalizedFailureReasonErrorKey:responseObject}];
                
                completion(self,NO,error,nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error request:[params description] path:[self BIG_RESTPath] object:task method:@"GET"];
        if (completion) {
            completion(self,NO,error,nil);
        }
    }];
}


+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path completion:(BIGRestCompletionBlock)completion
{
    NSString *uniqueID = [entity BIG_primaryKeyPropertyValue];
	[self BIG_updateRemoteEntity:entity atPath:path withID:uniqueID withParameters:[entity BIG_dictionaryRepresentation] completion:completion];
}

+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path withID:(id)uniqueID withParameters:(NSDictionary*)parameters completion:(BIGRestCompletionBlock)completion
{
	NSString *urlString = [NSString stringWithFormat:@"%@%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],path];
	
	if (uniqueID) {
		urlString = [NSString stringWithFormat:@"%@%@%@",[[NSManagedObject BIG_HTTPSessionManager].baseURL absoluteString],path,uniqueID];
	}

	[[NSManagedObject BIG_HTTPSessionManager] PUT:urlString parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
		
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			id entity = [self BIG_serializeAndSaveOneEntity:responseObject];
			
			if (completion) {
				completion(self,YES,nil,entity);
			}
		} else {
			if (completion) {
				
				NSError *error = [NSError errorWithDomain:kBIGRestErrorDomain_UnexpectedType code:kBIGRestErrorCode_UnexpectedType userInfo:@{NSLocalizedFailureReasonErrorKey:responseObject}];
				
				completion(self,NO,error,nil);
			}
		}
		
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		[self logError:error request:entity path:[self BIG_RESTPath] object:task method:@"PUT"];
		
		if (completion) {
			completion(self,NO,error,nil);
		}
	}];
}

+ (id) BIG_getRootElement:(NSString*)rootElement withResponse:(NSDictionary*)response
{
    id result = response;
    
    if (!rootElement) {
        rootElement = [self BIG_rootResponseElement];
    }
    
    if ([response isKindOfClass:[NSDictionary class]] && rootElement) {
        @try {
            result = response[rootElement];
        }
        @catch (NSException *exception) {
            //DDLogError(@"exception in response root element: %@",exception);
        }
    }
    
    return result;
}

+ (void) logError:(NSError*)error request:(id)request path:(NSString*)path object:(id)object method:(NSString*)method
{
    //DDLogError(@"path: [%@] method:[%@] request: [%@] task: [%@] failed with error: [%@]",path,method,request,object,error);
}


@end
