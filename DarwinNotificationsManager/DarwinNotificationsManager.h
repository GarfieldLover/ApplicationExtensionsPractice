//
//  DarwinNotificationsManager.h
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/24.
//
//

#import <Foundation/Foundation.h>

@interface DarwinNotificationsManager : NSObject

@property (strong, nonatomic) id someProperty;

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(id messageObject))callback;

- (void)postNotificationWithName:(NSString *)name object:(NSObject*)object;

@end

