//
//  BIGRestfulObject.h
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#import <Foundation/Foundation.h>
#import "EKMappingProtocol.h"
#import "BigRest-Blocks.h"

@class AFHTTPSessionManager;

@protocol BIGRestfulObject <NSObject,EKManagedMappingProtocol>

+ (void) BIG_setBackgroundOperationQueue:(NSOperationQueue*)operationQueue;
+ (NSOperationQueue*) BIG_BackgroundQueue;

+ (void) BIG_setHTTPSessionManager:(AFHTTPSessionManager*)httpSessionManager;

+ (AFHTTPSessionManager*) BIG_HTTPSessionManager;

+ (NSString*) BIG_rootResponseElement;

+ (NSString*) BIG_RESTPath;

/**
 *  Gets all entities from the RESTPath endpoint.
 *
 *  @param completion An optional completion block to be executed upon completion.
 *
 *  @discussion Once this call is complete, the retrieved objects will be serialized and stored in the persistent store.
 */
+ (void) BIG_getRemoteEntitiesWithCompletion:(BIGRestCompletionBlock)completion;

/**
 *  Gets a specific entity with an identifier, then serializes the response into CoreData.
 *
 *  @param identifier The identifier (_id) of the entity.
 *  @param completion A block to be executed when the transaction completes.
 */
+ (void) BIG_getRemoteEntityWithID:(NSString*)identifier withCompletion:(BIGRestCompletionBlock)completion;

+ (void) BIG_createRemoteEntity:(NSDictionary*)entityRepresentation withCompletion:(BIGRestCompletionBlock)completion;

/**
 *  Deletes the entities from the server.
 *
 *  @param entities     An array of NSManagedObject subclasses to delete.
 *  @param completion A completion block to be run when the transaction completes.
 *
 */
+ (void) BIG_deleteRemoteEntities:(NSArray*)entities withCompletion:(BIGRestCompletionBlock)completion;

/**
 *  Updates the entity, then serializes the response into CoreData.
 *
 *  @param entity     The entity with updated values to be PUT.
 *  @param completion A completion block to be run when the transaction completes.
 */
+ (void) BIG_updateRemoteEntity:(id)entity withCompletion:(BIGRestCompletionBlock)completion;

- (void) BIG_updateRemoteWithCompletion:(BIGRestCompletionBlock)completion;

+ (void) BIG_createRemoteEntity:(NSDictionary*)entityRepresentation atPath:(NSString*)path completion:(BIGRestCompletionBlock)completion;

/**
 *  Creates a collection of entities at a specific path, then serializes the response to CoreData.
 *
 *  @param requestDictionaries An array of NSDictionary object representations.
 *  @param path                The path to POST the entities to.
 *  @param params              Parameters to send along with the request.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion;

/**
 *  Creates a collection of entities at a specific path, then serializes the response to CoreData.
 *
 *  @param requestDictionaries An array of NSDictionary object representations.
 *  @param path                The path to POST the entities to.
 *  @param params              Parameters to send along with the request.
 *  @param progress            A progress block to be run when each operation completes.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion;

+ (void) BIG_createRemoteEntities:(NSArray*)requestDictionaries atPath:(NSString*)path parameters:(NSDictionary*)params queue:(NSOperationQueue*)operationQueue progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion;

/**
 *  Deletes a single entity.
 *
 *  @param entity     The entity to delete.
 *  @param completion A completion block to be run when the transaction completes.
 */
+ (void) BIG_deleteRemoteEntity:(NSManagedObject*)entity completion:(BIGRestCompletionBlock)completion;

/**
 *  Deletes a collection of entities at a specific path, then serializes the response to CoreData.
 *
 *  @param requestDictionaries An array of NSManagedObject subclasses to delete.
 *  @param path                The path to DELETE the entities from.
 *  @param params              Parameters to send along with the request.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion;


/**
 *  Deletes a collection of entities at a specific path, then serializes the response to CoreData.
 *
 *  @param requestDictionaries An array of NSManagedObject subclasses to delete.
 *  @param path                The path to DELETE the entities from.
 *  @param params              Parameters to send along with the request.
 *  @param progress            A progress block to be run when each operation completes.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion;


+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params queue:(NSOperationQueue*)operationQueue progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion;

/**
 *  Gets a collection of entities at a specific path, then serializes the response to CoreData.
 *
 *  @param path                The path to GET the entities from.
 *  @param params              Parameters to send along with the request.
  *  @param rootResponseElement              The root element from which to extract the response or nil.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_getRemoteEntitiesAtPath:(NSString*)path parameters:(NSDictionary*)params rootResponseElement:(NSString*)rootElement completion:(BIGRestCompletionBlock)completion;

/**
 *  Gets a single entity at a specific path, then serializes the response to CoreData.
 *
 *  @param path       The path to GET the entity from.
 *  @param identifier The identifier (_id) of the entity to GET.
 *  @param params              Parameters to send along with the request.
 *  @param rootResponseElement              The root element from which to extract the response or nil.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_getRemoteEntityAtPath:(NSString*)path withID:(NSString*)identifier parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion;

+ (void) BIG_getRemoteEntityAtPath:(NSString*)path parameters:(NSDictionary*)params rootResponseElement:(NSString*)rootElement completion:(BIGRestCompletionBlock)completion;

/**
 *  Updates the supplied entity at a specific path.
 *
 *  @param entity     The entity with updated values to be PUT.
 *  @param path        The path to PUT the entities to.
 *  @param completion A completion block to be run when the transaction completes.
 */
+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path completion:(BIGRestCompletionBlock)completion;

+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path withID:(id)uniqueID withParameters:(NSDictionary*)parameters completion:(BIGRestCompletionBlock)completion;

@end
