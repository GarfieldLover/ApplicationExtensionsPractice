//
//  AppDelegate.m
//  CallDirectory
//
//  Created by ZK on 16/8/10.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "AppDelegate.h"
//#import "Call+CoreDataClass.h"

@interface AppDelegate (){
    NSUInteger numberLast8;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    numberLast8=0;
    
//    [MagicalRecord setupCoreDataStackWithStoreNamed:@"CallBlockerModel.sqlite"];
    
    [self getDataFromBaidu];
    
    return YES;
}

/*
 想从百度扒数据下来保存数据库，但是
 1.太慢 一天30w次请求  2.防刷了，请求到4000多次时返回解析不了
 */

-(void)getDataFromBaidu
{
    NSString* urlString = [NSString stringWithFormat:@"http://www.baidu.com/s?wd=189%08lu",(unsigned long)numberLast8];
    numberLast8++;
    if(numberLast8>99999999){
        exit(0);
    }
    NSLog(@"-----------------%@",[NSString stringWithFormat:@"189%08lu",(unsigned long)numberLast8]);
    
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    
    NSURLSessionDataTask * dataTask =  [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *searchResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if(searchResult.length>0){
                NSNumber* marknumber = [self marknumber:searchResult];
                if(marknumber.integerValue>0){
//                    Call *aCall = [Call MR_createEntity];
//                    aCall.marknumber= [self marknumber:searchResult];
//                    aCall.marktype = [self marktype:searchResult];
//                    aCall.markdetail = [self markdetail:searchResult];
//                    aCall.marktotal = [self marktotal:searchResult];
//                    
//                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }else{
                NSLog(@"++++++++++++++searchResult==0");
            }
            
            
            
            [self getDataFromBaidu];
            
        });
    }];
    [dataTask resume];
}

-(NSString*)markdetail:(NSString*)searchResult
{
    NSString *marktype = @"";
    
    NSRegularExpression *liarNodeRegex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<span[^<]*class=\"[^\"]*op_liarphone2_label op_liarphone2_label_tx  c-gap-right-small(.+?)</span>"
                                          options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                          error:NULL];
    
    NSRange rngLiar = [liarNodeRegex rangeOfFirstMatchInString:searchResult
                                                       options:0
                                                         range:NSMakeRange(0, searchResult.length)];
    
    if (rngLiar.location != NSNotFound) {
        NSString *liarInfo = [searchResult substringWithRange:rngLiar];
        
        // 如果有具体的信息就用
        NSRange rngStrong = [liarInfo rangeOfString:@"op_liarphone2_label op_liarphone2_label_tx  c-gap-right-small\">"];
        if (rngStrong.location != NSNotFound) {
            NSUInteger begin = rngStrong.location + rngStrong.length;
            NSRange rngEndStrong = [liarInfo rangeOfString:@"</"
                                                   options:NSLiteralSearch
                                                     range:NSMakeRange(begin, liarInfo.length - begin)];
            if (rngEndStrong.location != NSNotFound) {
                marktype = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                marktype = [marktype stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            }
        }
    }
    return marktype;
}

-(NSNumber*)marknumber:(NSString*)searchResult
{
    NSString *marktype = @"";
    
    NSRegularExpression *liarNodeRegex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<span[^<]*class=\"[^\"]*op_liarphone2_number c-gap-right-small(.+?)</span>"
                                          options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                          error:NULL];
    
    NSRange rngLiar = [liarNodeRegex rangeOfFirstMatchInString:searchResult
                                                       options:0
                                                         range:NSMakeRange(0, searchResult.length)];
    
    if (rngLiar.location != NSNotFound) {
        NSString *liarInfo = [searchResult substringWithRange:rngLiar];
        
        // 如果有具体的信息就用
        NSRange rngStrong = [liarInfo rangeOfString:@"op_liarphone2_number c-gap-right-small\">"];
        if (rngStrong.location != NSNotFound) {
            NSUInteger begin = rngStrong.location + rngStrong.length;
            NSRange rngEndStrong = [liarInfo rangeOfString:@"</"
                                                   options:NSLiteralSearch
                                                     range:NSMakeRange(begin, liarInfo.length - begin)];
            if (rngEndStrong.location != NSNotFound) {
                marktype = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                marktype = [marktype stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            }
        }
    }
    return [NSNumber numberWithInteger:marktype.integerValue];
}

-(NSNumber*)marktotal:(NSString*)searchResult
{
    NSString *marktype = @"";
    
    NSRegularExpression *liarNodeRegex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<div[^<]*class=\"[^\"]*op_liarphone2_word(.+?)</div>"
                                          options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                          error:NULL];
    
    NSRange rngLiar = [liarNodeRegex rangeOfFirstMatchInString:searchResult
                                                       options:0
                                                         range:NSMakeRange(0, searchResult.length)];
    
    if (rngLiar.location != NSNotFound) {
        NSString *liarInfo = [searchResult substringWithRange:rngLiar];
        
        // 如果有具体的信息就用
        NSRange rngStrong = [liarInfo rangeOfString:@"被"];
        if (rngStrong.location != NSNotFound) {
            NSUInteger begin = rngStrong.location + rngStrong.length;
            NSRange rngEndStrong = [liarInfo rangeOfString:@"个"
                                                   options:NSLiteralSearch
                                                     range:NSMakeRange(begin, liarInfo.length - begin)];
            if (rngEndStrong.location != NSNotFound) {
                marktype = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                marktype = [marktype stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            }
        }
    }
    return [NSNumber numberWithInteger:marktype.integerValue];
}

-(NSString*)marktype:(NSString*)searchResult
{
    NSString *marktype = @"";
    
    NSRegularExpression *liarNodeRegex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<div[^<]*class=\"[^\"]*op_liarphone2_word(.+?)</div>"
                                          options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                          error:NULL];
    
    NSRange rngLiar = [liarNodeRegex rangeOfFirstMatchInString:searchResult
                                                       options:0
                                                         range:NSMakeRange(0, searchResult.length)];
    
    if (rngLiar.location != NSNotFound) {
        NSString *liarInfo = [searchResult substringWithRange:rngLiar];
        
        // 如果有具体的信息就用
        NSRange rngStrong = [liarInfo rangeOfString:@"<strong>"];
        if (rngStrong.location != NSNotFound) {
            NSUInteger begin = rngStrong.location + rngStrong.length;
            NSRange rngEndStrong = [liarInfo rangeOfString:@"</"
                                                   options:NSLiteralSearch
                                                     range:NSMakeRange(begin, liarInfo.length - begin)];
            if (rngEndStrong.location != NSNotFound) {
                marktype = [liarInfo substringWithRange:NSMakeRange(begin, rngEndStrong.location - begin)];
                marktype = [marktype stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
            }
        }
    }
    return marktype;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
