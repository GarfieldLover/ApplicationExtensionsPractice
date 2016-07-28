//
//  SpotLightItem.m
//  EmotionConfigCenter
//
//  Created by guoxiaodong on 15/9/10.
//  Copyright © 2015年 guoxiaodong. All rights reserved.
//

#import "SpotLightItem.h"

NSString* const kSpotLightContentKey_aid    = @"aid";
NSString* const kSpotLightContentKey_vid    = @"vid";
NSString* const kSpotLightContentKey_cid    = @"cid";
NSString* const kSpotLightContentKey_site   = @"site";
NSString* const kSpotLightContentKey_title  = @"album_name";
NSString* const kSpotLightContentKey_desc   = @"album_desc";
NSString* const kSpotLightContentKey_pic    = @"ver_big_pic";
NSString* const kSpotLightContentKey_actors = @"main_actor";
NSString* const kSpotLightContentKey_director = @"director";
NSString* const kSpotLightContentKey_guest  = @"guest";
NSString* const kSpotLightContentKey_tip    = @"tip";
NSString* const kSpotLightContentKey_sec_Cate =@"second_cate_name";

NSString *const SpotLightDirectory          = @"SpotLightDirectory";
NSString *const SpotLightFileName           = @"SpotLightContent.plist";
NSString *const SpotLightindentifyFormat    = @"SOHU_aid=%@_vid=%@_site=%@";

@implementation SpotLightItem
#pragma mark protocol mathod override
+ (instancetype)instanceWithJSONDictionary:(NSDictionary *)jsonDictionary {
    return [[self alloc] initWithJSONDictionary:jsonDictionary];
}


+ (NSMutableArray *)instancesWithJSONArray:(NSArray *)jsonArray {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (id jsonObject in jsonArray) {
        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        id object = [self instanceWithJSONDictionary:(NSDictionary *)jsonObject];
        [resultArray addObjectOrNil:object];
    }
    return resultArray;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        [self updateWithJSONDictionary:jsonDictionary];
    }
    return self;
}

- (void)updateWithJSONDictionary:(NSDictionary *)jsonDictionary {
    self.aid    = [jsonDictionary stringForKey:kSpotLightContentKey_aid defaultValue:@""];
    self.vid    = [jsonDictionary stringForKey:kSpotLightContentKey_vid defaultValue:@""];
    self.cid    = [jsonDictionary stringForKey:kSpotLightContentKey_cid defaultValue:@""];
    self.site   = [jsonDictionary stringForKey:kSpotLightContentKey_site defaultValue:@""];
    self.title  = [jsonDictionary stringForKey:kSpotLightContentKey_title];
    self.desc   = [jsonDictionary stringForKey:kSpotLightContentKey_desc];
    self.picURL = [jsonDictionary stringForKey:kSpotLightContentKey_pic];
    self.actors = [jsonDictionary stringForKey:kSpotLightContentKey_actors];
    self.guest  = [jsonDictionary stringForKey:kSpotLightContentKey_guest];
    self.director = [jsonDictionary stringForKey:kSpotLightContentKey_director];
    self.tips   = [jsonDictionary stringForKey:kSpotLightContentKey_tip];
    self.cateName = [jsonDictionary stringForKey:kSpotLightContentKey_sec_Cate];
    
    /*aid_vid_site 可以确定唯一视频*/
    self.indentify = [NSString stringWithFormat:SpotLightindentifyFormat,self.aid,self.vid,self.site];
}

- (NSMutableDictionary *)toJSONDictionary {
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObjectOrNil:self.aid forKey:kSpotLightContentKey_aid];
    [jsonDictionary setObjectOrNil:self.vid forKey:kSpotLightContentKey_vid];
    [jsonDictionary setObjectOrNil:self.cid forKey:kSpotLightContentKey_cid];
    [jsonDictionary setObjectOrNil:self.site forKey:kSpotLightContentKey_site];
    return jsonDictionary;
}

#pragma  mark ---tools------
+ (NSString *)spotLightContentItemsFilePath {
    NSString *directoryPath = [[self class] spotLightDirectoryPath];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:SpotLightFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            filePath = nil;
        }
    }
    return filePath;
}

+ (NSString *)spotLightDirectoryPath {
    NSArray *libraryPathList = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [libraryPathList objectAtIndex:0];
    NSString *directoryPath = [libraryPath stringByAppendingPathComponent:SpotLightDirectory];
    
    BOOL needCreateDirectory = YES;
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        if (isDirectory) {
            needCreateDirectory = NO;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
        }
    }
    
    if (needCreateDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return directoryPath;
}
@end
