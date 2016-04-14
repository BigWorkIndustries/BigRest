//
//  NSManagedObject+BIGMappingAdditions.h
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#import <CoreData/CoreData.h>
#import "EKMappingProtocol.h"
#import "BIGMappableObject.h"

@interface NSManagedObject (BIGMappingAdditions)<BIGMappableObject,EKManagedMappingProtocol>


@end
