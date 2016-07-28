//
//  SpotLightItem.h
//  EmotionConfigCenter
//
//  Created by guoxiaodong on 15/9/10.
//  Copyright © 2015年 guoxiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONObject.h"

@interface SpotLightItem : NSObject<JSONObject>

@property (nonatomic,strong) NSString* indentify;/*唯一标识，客户端生成，格式sohu_aid=_vid=_site=*/
@property (nonatomic,strong) NSString* title;   /*展示到系统搜索界面*/
@property (nonatomic,strong) NSString* desc;    /*展示到系统搜索界面*/
@property (nonatomic,strong) NSString* picURL;  /*需要下载，展示到系统搜索界面*/
@property (nonatomic,strong) NSString* aid;     /*用于action跳转*/
@property (nonatomic,strong) NSString* vid;     /*用于action跳转*/
@property (nonatomic,strong) NSString* cid;     /*用于action跳转*/
@property (nonatomic,strong) NSString* site;    /*用于action跳转*/
@property (nonatomic,strong) NSString* actors;  /*演员列表*/
@property (nonatomic,strong) NSString* director;/*用于动漫的“监督”*/
@property (nonatomic,strong) NSString* guest;   /*嘉宾，用于综艺*/
@property (nonatomic,strong) NSString* tips;    /*tips*/
@property (nonatomic,strong) NSString* cateName;/*分类名*/

/*本地spotLight的存储目录*/
+ (NSString *)spotLightContentItemsFilePath;

- (NSMutableDictionary *)toJSONDictionary;
@end

UIKIT_EXTERN NSString* const kSpotLightContentKey_aid;
UIKIT_EXTERN NSString* const kSpotLightContentKey_vid;
UIKIT_EXTERN NSString* const kSpotLightContentKey_cid;
UIKIT_EXTERN NSString* const kSpotLightContentKey_title;
UIKIT_EXTERN NSString* const kSpotLightContentKey_desc;
UIKIT_EXTERN NSString* const kSpotLightContentKey_pic;
UIKIT_EXTERN NSString* const kSpotLightContentKey_;
UIKIT_EXTERN NSString* const kSpotLightContentKey_pic;
UIKIT_EXTERN NSString* const kSpotLightContentKey_sec_Cate;
UIKIT_EXTERN NSString* const kSpotLightContentKey_director;
UIKIT_EXTERN NSString* const kSpotLightContentKey_guest;


UIKIT_EXTERN NSString *const SpotLightFileName;