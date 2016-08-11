//
//  Call+CoreDataProperties.m
//  
//
//  Created by ZK on 16/8/10.
//
//

#import "Call+CoreDataProperties.h"

@implementation Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Call"];
}

@dynamic markdetail;
@dynamic marknumber;
@dynamic marktotal;
@dynamic marktype;

@end
