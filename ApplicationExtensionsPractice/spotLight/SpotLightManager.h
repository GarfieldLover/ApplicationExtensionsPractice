//
//  SpotLightManager.h
//  EmotionConfigCenter
//
//  Created by guoxiaodong on 15/9/9.
//  Copyright © 2015年 guoxiaodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotLightItem.h"


@interface SpotLightManager : NSObject
+(SpotLightManager *)sharedInstance;

/*向服务器请求spotlight内容*/
-(void) RequestSpotLightContent;

/*通过indentify获取item*/
-(SpotLightItem*) spotLightItemByIndentify:(NSString*)indentify;
@end
