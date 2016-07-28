//
//  SpotLightManager.m
//  EmotionConfigCenter
//
//  Created by guoxiaodong on 15/9/9.
//  Copyright © 2015年 guoxiaodong. All rights reserved.
//

#import "SpotLightManager.h"
#import "UrlFormats_openAPI.h"
#import "RequestItem.h"
#import "ConfigurationCenter.h"
#import "DataParser.h"
#import "DataCenter+spotLight.h"
#import "DataCenter+.h"
#import "SDWebImageDownloader.h"
#import "UIDeviceAdditions.h"

#import "CoreSpotlight/CSSearchableItem.h"
#import "CoreSpotlight/CSSearchableItemAttributeSet_Categories.h"
#import "CoreSpotlight/CSSearchableIndex.h"
#import <MobileCoreServices/MobileCoreServices.h>
NSString* const SOHUSpotLightDomain = @"com.sohu.mobile.spotlight";
const int requestGranularity = 20;

@interface SpotLightManager ()
@property (nonatomic,strong)NSMutableArray* spotLightItems;
@property (nonatomic,assign)int             currentPage;
@property (nonatomic,assign)int             totalCount;
@property (nonatomic,strong)  dispatch_queue_t serialQueue;
@property (nonatomic,strong)NSDictionary    *constColumnName;
@end

@implementation SpotLightManager

+(SpotLightManager *)sharedInstance
{
    static SpotLightManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SpotLightManager alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init{
    self = [super init];
    self.currentPage = 1;
    self.totalCount = self.currentPage *requestGranularity;
    [self loadSpotLightItemsFromLocal];
    [self serialQueue];
    self.constColumnName = @{@(kVideoType_Movie):@"电影",
                             @(kVideoType_TV):@"电视剧",
                             @(kVideoType_VarietyChina):@"综艺",
                             @(kVideoType_Newsreel):@"纪录片",
                             @(kVideoType_Commic):@"动漫"};
    return self;
}
/*向服务器请求spotlight内容*/
-(void) RequestSpotLightContent{
    [self RequestSpotLightContentByPage:self.currentPage];
}
/*向服务器请求spotlight内容*/
-(void) RequestSpotLightContentByPage:(int)page {
    RequestItem *requestItem = [[RequestItem alloc] initWithOwner:self];
    requestItem.finalUrl = Url_Format_SpotLightContentRequestUrl;
    [requestItem setDelegateTarget:self
                     succeedMethod:@selector(requestDidLoadSpotLightContentWithResponseItem:)
                      failedMethod:@selector(requestDidFailedLoadSpotLightContentWithResponseItem:)];
    //拼接URL参数
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    ConfigurationCenter *configurationCenter = [ConfigurationCenter sharedCenter];
    [parameters setObjectOrNil:[configurationCenter getOpenApiKey] forKey:@"api_key"];
    [parameters setObjectOrNil:configurationCenter.plat forKey:@"plat"];
    [parameters setObjectOrNil:configurationCenter.partnerID forKey:@"partner"];
    [parameters setObjectOrNil:configurationCenter.appVersion forKey:@"sver"];
    
    [parameters setUnsignedInteger:page forKey:@"page"];
    [parameters setUnsignedInteger:requestGranularity forKey:@"pagesize"];/*server建议每次20条*/
    
    requestItem.additionalParams = parameters;
    [[DataCenter sharedCenter] requestSpotLightContentWithRequestItem:requestItem];
}

/*通过indentify获取item*/
-(SpotLightItem*) spotLightItemByIndentify:(NSString*)indentify{
    for (SpotLightItem *i in self.spotLightItems) {
        if ([i.indentify isEqualToString:indentify]) {
            return i;
        }
    }
    return nil;
}

#pragma mark- handle server
-(void)requestDidFailedLoadSpotLightContentWithResponseItem:(ResponseItem *)responseItem{
    /*如果中间某一页失败了，终止后面的请求。保存本地*/
    [self saveToLocalBySerialQueue];
}

-(void)requestDidLoadSpotLightContentWithResponseItem:(ResponseItem *)responseItem{
    NSDictionary *responseDataDic = [responseItem responseDictionary];
    if (responseDataDic == nil) {
        return;
    }
    self.totalCount = (int)[responseDataDic integerForKey:@"count"];
    
    /*第一个包下来，那么老的缓存需要删除*/
    if(self.currentPage == 1){
        [self.spotLightItems removeAllObjects];/*移除从local加载的数据，使用新的数据*/
        [self removeFromIndexByDomain];/*移除所有sohu索引*/
    }
    /*串行队列，处理数据*/
    dispatch_async(self.serialQueue, ^{//把block中的任务放入串行队列中执行，这是第一个任务
        NSArray* contentArray = [responseDataDic arrayForKey:@"videos"];
        NSArray* spotLightItem = [SpotLightItem instancesWithJSONArray:contentArray];
        [self cacheSpotLightContentItems:spotLightItem];
    });
    
    
    /*开始下一个请求，一共需要请求@“counts”条*/
    if (self.currentPage*requestGranularity < self.totalCount) {
        self.currentPage ++;
        [self RequestSpotLightContentByPage:self.currentPage];
    }else{
        /*如果最后一个包，保存本地*/
        [self saveToLocalBySerialQueue];
    }
}

#pragma mark --load store ---

/*从沙盒中载数据,即如果启动后没有请求成功，则使用缓存的内容*/
-(void) loadSpotLightItemsFromLocal{
    NSArray *spotLightItemsJSONArray = [NSArray arrayWithContentsOfFile:[SpotLightItem spotLightContentItemsFilePath]];
    self.spotLightItems = [[SpotLightItem instancesWithJSONArray:spotLightItemsJSONArray] mutableCopy];
}

-(void) saveToLocalBySerialQueue{
    dispatch_async(self.serialQueue, ^{//把block中的任务放入串行队列中执行，这是第一个任务
        NSMutableArray* local = [NSMutableArray array];
        for (SpotLightItem* i in self.spotLightItems) {
            [local addObjectOrNil:[i toJSONDictionary]];
        }
        if (local.count) {
            [local writeToFile:[SpotLightItem spotLightContentItemsFilePath] atomically:YES];
        }
    });
}
/*只要Server数据正确则保存到沙盒，当图片下来后则逐条保存至系统索引*/
- (void)cacheSpotLightContentItems:(NSArray *)spotLightContentItems {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    
    NSMutableArray *spotLightItemsJSONArray = [NSMutableArray array];
    for (SpotLightItem *item in spotLightContentItems) {
        [spotLightItemsJSONArray addObjectOrNil:[item toJSONDictionary]];
    }
    
    /*更新内存中数据,支持多页,append方式*/
    [self.spotLightItems addObjectsFromArray:spotLightContentItems];
    
    /* 下载每一项的海报图,成功则更新系统spotLight索引 */
    for (SpotLightItem *item in spotLightContentItems) {
        weakifyself;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:item.picURL]
                                                              options:0
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                strongifyself;
                                                                if (finished && !error && image) {
                                                                    [self saveSpotLightItemToIndex:item thumbnailData:data];
                                                                }else{
                                                                    /*使用默认图*/
                                                                    UIImage* defaultImage =  [UIImage imageNamed:@"PosterView340_470"];
                                                                    [self saveSpotLightItemToIndex:item thumbnailData:UIImagePNGRepresentation(defaultImage)];
                                                                }
                                                            }];
    }

    
}

#pragma mark --save to system index---

/*移除所有sohu索引*/
-(void) removeFromIndexByDomain{
    if([[UIDevice currentDevice] deviceSystemMajorVersion] < 9){
        return;
    }
    NSArray* deleteIdentify = @[SOHUSpotLightDomain];
    [[CSSearchableIndex defaultSearchableIndex ]deleteSearchableItemsWithDomainIdentifiers:deleteIdentify completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@ %@",NSStringFromSelector(_cmd),error);
        }

    }];
}

/*将数据写入系统spotLight索引*/
-(void) saveSpotLightItemToIndex:(SpotLightItem*)spotLightItem thumbnailData:(NSData*)thumbnailData{
    if([[UIDevice currentDevice] deviceSystemMajorVersion] < 9){
        return;
    }
    /*从索引中移除*/
    NSArray* deleteIdentify = @[spotLightItem.indentify];
    [[CSSearchableIndex defaultSearchableIndex ]deleteSearchableItemsWithIdentifiers:deleteIdentify completionHandler:^(NSError * _Nullable error) {
        if (error) {
            DDLogWarn(@"deleteSearchableItemsWithIdentifiers: %@",error);
        }
    }];
    
    /*生成索引项*/
    CSSearchableItemAttributeSet* oneSet = [[CSSearchableItemAttributeSet alloc]initWithItemContentType:(NSString*)kUTTypeAudiovisualContent];
    CSSearchableItem * item = [[CSSearchableItem alloc]initWithUniqueIdentifier:spotLightItem.indentify domainIdentifier:SOHUSpotLightDomain attributeSet:oneSet];
    oneSet.title = spotLightItem.title;
    oneSet.contentDescription = [self formatDescription:spotLightItem];
    oneSet.thumbnailData = thumbnailData;
    
//    oneSet.ratingDescription = @"搜狐视频";
//    oneSet.performers = @[@"金秀贤",@"成龙"];
//    oneSet.information = @"搜狐视频0";
//    oneSet.playCount = @(100);
//    oneSet.rating   = @(4);
//    oneSet.comment = @"comment";
//    oneSet.director = @"director";
//    oneSet.producer = @"producer";
//    oneSet.copyright = @"copyright";
    
    /*添加到系统索引中*/
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * __nullable error) {
        //log
    }];
}

-(NSString*) formatDescription:(SpotLightItem*)spotLightItem{
    int cid = spotLightItem.cid.intValue;
    NSString* desc = @"";
    NSString* trail = @"搜狐视频";
    switch (cid) {
        case kVideoType_Movie:
            desc = [NSString stringWithFormat:@"电影 | %@ %@ \n主演: %@\n%@",spotLightItem.cateName OR @"",spotLightItem.tips OR @"",spotLightItem.actors OR @"",trail];
            break;
        case kVideoType_TV:
            desc = [NSString stringWithFormat:@"电视剧 | %@ %@\n主演: %@\n%@",spotLightItem.cateName OR @"",spotLightItem.tips  OR @"",spotLightItem.actors OR @"",trail];
            break;
        case kVideoType_VarietyChina:
            desc = [NSString stringWithFormat:@"综艺 | %@ 最新%@\n嘉宾: %@\n%@",spotLightItem.cateName OR @"",spotLightItem.tips OR @"",spotLightItem.guest OR @"",trail];
            break;
        case kVideoType_Newsreel:
            desc = [NSString stringWithFormat:@"纪录片 | %@ 最新%@\n%@",spotLightItem.cateName OR @"",spotLightItem.tips OR @"",trail];
            break;
        case kVideoType_Commic:
            desc = [NSString stringWithFormat:@"动漫 | %@ 最新%@\n监督: %@\n%@",spotLightItem.cateName OR @"",spotLightItem.tips OR @"",spotLightItem.director OR @"",trail];
            break;
        default:
        {
            NSString* shortDesc = [spotLightItem.desc substringToIndex:40];
            desc = [NSString stringWithFormat:@"%@...\n%@",shortDesc,spotLightItem.actors OR @""];
        }
            break;
    }
    return desc;
}

#pragma mark --thread---
- (dispatch_queue_t)serialQueue
{
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("spotlightSerialQueue", DISPATCH_QUEUE_SERIAL);//创建串行队列
    }
    return _serialQueue;
}
@end




