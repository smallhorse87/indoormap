//
//  IndoorMapContext.m
//  indoormap
//
//  Created by chenxiaosong on 2018/12/26.
//  Copyright © 2018年 chenxiaosong. All rights reserved.
//

#import "IndoorMapContext.h"

#define kMapCommented       @"mapCommented"
#define kIndoorSearchHist   @"IndoorSearchHist"
#define kIndoorFloorList    @"IndoorFloorList"

@implementation IndoorMapContext

+(NSMutableDictionary*)readValue
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"IndoorMapContext.plist"];
    
    NSMutableDictionary *valueDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    if(valueDic==nil)
        return [[NSMutableDictionary alloc] init];
    else
        return valueDic;
}

+(void)saveValue:(NSDictionary*)valueDic
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"IndoorMapContext.plist"];
    
    BOOL rlt = [valueDic writeToFile:plistPath atomically:YES];
    
    NSLog(@"save %@", rlt ? @"Suc" : @"Fail");
}

//地图评论
+(void)cleanMapCommented
{
    NSMutableDictionary *settingDic = [self readValue];
    
    [settingDic removeObjectForKey:kMapCommented];
    
    [self saveValue:settingDic];
}

+(void)setMapCommented
{
    NSMutableDictionary *settingDic = [self readValue];
    
    [settingDic setObject:@"yes" forKey:kMapCommented];
    
    [self saveValue:settingDic];
}

+(BOOL)getMapCommented
{
    NSDictionary *settingDic = [self readValue];
    
    NSString *commented = [settingDic objectForKey:kMapCommented];
    
    if([commented isEqualToString:@"yes"])
        return YES;
    else
        return NO;
}

//缓存楼层加载记录
+(void)cacheFloorList:(NSString*)buildId floorArr:(NSArray*)floorArr
{
    if(floorArr.count==0)
        return;
    
    //key值
    NSString *key = [kIndoorFloorList stringByAppendingString:buildId];
    
    //将所有楼层拼接到一起
    NSString *floorStr = @"";
    
    for(NSString *floor in floorArr)
    {
        floorStr = [floorStr stringByAppendingFormat:@"%@,",floor];
    }
    floorStr = [floorStr substringToIndex:floorStr.length-1];
    
    //保存
    NSMutableDictionary *settingDic = [self readValue];
    [settingDic setObject:floorStr
                   forKey:key];
    [self saveValue:settingDic];
}

+(NSArray*)retriveFloorList:(NSString*)buildId
{
    //key值
    NSString *key = [kIndoorFloorList stringByAppendingString:buildId];
    
    NSMutableDictionary *settingDic = [self readValue];
    
    NSString *floorStr = [settingDic objectForKey:key];
    
    if(floorStr.length==0)
        return nil;
    
    return [floorStr componentsSeparatedByString:@","];
}

//室内地图历史搜索记录
//格式  中国移动|F1;一点点|F3;
+(void)addIndoorSearchHistory:(NSString*)title floor:(NSString*)floor
{
    if(title.length==0)
        return;
    
    if(floor.length==0)
        return;
    
    NSString *catHistory = @"";
    NSString *addedLoc = [NSString stringWithFormat:@"%@|%@;",title,floor];
    
    //读取之前的列表，进行重排序，加入新记录
    NSMutableDictionary *settingDic = [self readValue];
    if([settingDic objectForKey:kIndoorSearchHist]) {
        catHistory = [settingDic objectForKey:kIndoorSearchHist];
        catHistory = [catHistory stringByReplacingOccurrencesOfString:addedLoc withString:@""];
    }
    
    catHistory = [addedLoc stringByAppendingString:catHistory];
    
    //保存记录
    [settingDic setObject:catHistory
                   forKey:kIndoorSearchHist];
    
    [self saveValue:settingDic];
}

+(NSArray*)retriveIndoorSearchHistoryList
{
    NSDictionary *settingDic = [self readValue];
    
    NSString *catHistory = [settingDic objectForKey:kIndoorSearchHist];
    
    if(catHistory==nil)
        return nil;
    
    catHistory = [catHistory substringToIndex:catHistory.length-1];
    
    NSArray *historyArr = [catHistory componentsSeparatedByString:@";"];
    
    return historyArr;
}

+ (void)clearIndoorSearchHistoryList
{
    NSMutableDictionary *settingDic = [self readValue];
    [settingDic removeObjectForKey:kIndoorSearchHist];
    [self saveValue:settingDic];
}

@end
