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

/**
 *  Sets the NSOperationQueue to be used for async operations.
 *
 *  @param operationQueue The operation queue.
 */
+ (void) BIG_setBackgroundOperationQueue:(NSOperationQueue*)operationQueue;

/**
 *  Gets the instance of the operation queue that will be used for async operations.
 *
 *  @return An instance of NSOperationQueue.
 */
+ (NSOperationQueue*) BIG_BackgroundQueue;

/**
 *  Sets the HTTP session manager.
 *
 *  @param httpSessionManager A session manager instance.
 */
+ (void) BIG_setHTTPSessionManager:(AFHTTPSessionManager*)httpSessionManager;


/**
 *  Gets the HTTP session manager instance.
 *
 *  @return A session manager instance.
 */
+ (AFHTTPSessionManager*) BIG_HTTPSessionManager;

/**
 *  The root response element, if any.
 *
 *  @return The root response element, or nil.
 *
 *  @discussion This methos is intended to be overridden.
 */
+ (NSString*) BIG_rootResponseElement;

/**
 *  The server's REST path for the instance type.
 *
 *  @return A string representing the server's REST path.
 */
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

/**
 *  Updates the remote instance.
 *
 *  @param completion A completion block to be executed on completion, or nil.
 */
- (void) BIG_updateRemoteWithCompletion:(BIGRestCompletionBlock)completion;

/**
 *  Creates a remnote entity at the specific path.
 *
 *  @param entityRepresentation A disctionary representation of the entity.
 *  @param path                 The server's REST path to use when creating the object.
 *  @param completion           A completion block to be executed on completion, or nil.
 */
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

/**
 *  Create multiple remote entities using an array
 *
 *  @param requestDictionaries An array of dictionaries representing objects to be created.
 *  @param path                The path to POST the entities to.
 *  @param params              Parameters to send along with the request.
 *  @param operationQueue      The operation queue to be used.
 *  @param progress            A progress block to be run when each operation completes.
 *  @param completion          A completion block to be run when the transaction completes.
 */
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
 *  Deletes a collection of entities at a specific path, then then removes the entities from CoreData.
 *
 *  @param entities            An array of NSManagedObject subclasses to delete.
 *  @param path                The path to DELETE the entities from.
 *  @param params              Parameters to send along with the request.
 *  @param progress            A progress block to be run when each operation completes.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_deleteRemoteEntities:(NSArray*)entities atPath:(NSString*)path parameters:(NSDictionary*)params progress:(BIGRestCompletionBlock)progress completion:(BIGRestCompletionBlock)completion;

/**
 *  Deletes a collection of entities at a specific path, then then removes the entities from CoreData.
 *
 *  @param entities            An array of NSManagedObject subclasses to delete.
 *  @param path                The path to DELETE the entities from.
 *  @param params              Parameters to send along with the request.
 *  @param operationQueue      The operation queue to be used.
 *  @param progress            A progress block to be run when each operation completes.
 *  @param completion          A completion block to be run when the transaction completes.
 */
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
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_getRemoteEntityAtPath:(NSString*)path withID:(NSString*)identifier parameters:(NSDictionary*)params completion:(BIGRestCompletionBlock)completion;

/**
 *  Gets a single entity at a specific path, then serializes the response to CoreData.
 *
 *  @param path       The path to GET the entity from.
 *  @param params              Parameters to send along with the request.
 *  @param rootResponseElement              The root element from which to extract the response or nil.
 *  @param completion          A completion block to be run when the transaction completes.
 */
+ (void) BIG_getRemoteEntityAtPath:(NSString*)path parameters:(NSDictionary*)params rootResponseElement:(NSString*)rootElement completion:(BIGRestCompletionBlock)completion;

/**
 *  Updates the supplied entity at a specific path.
 *
 *  @param entity     The entity with updated values to be PUT.
 *  @param path        The path to PUT the entities to.
 *  @param completion A completion block to be run when the transaction completes.
 */
+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path completion:(BIGRestCompletionBlock)completion;

/**
 *  Updated the remote entity.
 *
 *  @param entity     The entity to update.
 *  @param path        The path to PUT the entities to.
 *  @param uniqueID   A unique ID to be used when updating the entity.
 *  @param parameters A dictionary of query parameters to be sent with the request.
 *  @param completion A completion block to be run when the transaction completes.
 */
+ (void) BIG_updateRemoteEntity:(NSManagedObject*)entity atPath:(NSString*)path withID:(id)uniqueID withParameters:(NSDictionary*)parameters completion:(BIGRestCompletionBlock)completion;

@end
