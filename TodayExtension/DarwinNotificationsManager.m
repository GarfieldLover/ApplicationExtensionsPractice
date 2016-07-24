//
//  DarwinNotificationsManager.m
//  ApplicationExtensionsPractice
//
//  Created by zhangke on 16/7/24.
//
//

#import "DarwinNotificationsManager.h"

@implementation DarwinNotificationsManager {
    NSMutableDictionary * handlers;
}

+ (instancetype)sharedInstance {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(id messageObject))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name object:(id<NSCoding>)object
{
    [self writeMessageObject:object forIdentifier:name];
    
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name object:(NSObject*)object{
    void (^callback)(id messageObject) = handlers[name];
    callback(object);
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                                  void *observer,
                                  CFStringRef name,
                                  const void *object,
                                  CFDictionaryRef userInfo)
{
    NSLog(@"name: %@", name);
    NSLog(@"userinfo: %@", userInfo);
    
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)(observer);
    
    [[DarwinNotificationsManager sharedInstance] notificationCallbackReceivedWithName:identifier object:sender];
}


- (nullable NSString *)messagePassingDirectoryPath {
    NSURL *appGroupContainer = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"gl.xxx"];
    NSString *appGroupContainerPath = [appGroupContainer path];
    NSString *directoryPath = appGroupContainerPath;
    
    //    if (self.directory != nil) {
    //        directoryPath = [appGroupContainerPath stringByAppendingPathComponent:self.directory];
    //    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    
    return directoryPath;
}

- (nullable NSString *)filePathForIdentifier:(nullable NSString *)identifier {
    if (identifier == nil || identifier.length == 0) {
        return nil;
    }
    
    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.archive", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

- (BOOL)writeMessageObject:(id<NSCoding>)messageObject forIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return NO;
    }
    
    if (messageObject) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messageObject];
        NSString *filePath = [self filePathForIdentifier:identifier];
        
        if (data == nil || filePath == nil) {
            return NO;
        }
        
        BOOL success = [data writeToFile:filePath atomically:YES];
        
        if (!success) {
            return NO;
        }
    }
    
    return YES;
}

- (id<NSCoding>)messageObjectForIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }
    
    NSString *filePath = [self filePathForIdentifier:identifier];
    
    if (filePath == nil) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data == nil) {
        return nil;
    }
    
    id messageObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return messageObject;
}


- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}

@end
