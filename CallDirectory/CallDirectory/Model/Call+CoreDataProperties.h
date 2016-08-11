//
//  Call+CoreDataProperties.h
//  
//
//  Created by ZK on 16/8/10.
//
//

#import "Call+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *markdetail;
@property (nullable, nonatomic, copy) NSNumber *marknumber;
@property (nullable, nonatomic, copy) NSNumber *marktotal;
@property (nullable, nonatomic, copy) NSString *marktype;

@end

NS_ASSUME_NONNULL_END
