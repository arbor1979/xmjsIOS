//
//  DDIDataModel.h
//  老师助手
//
//  Created by yons on 13-12-30.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CommonFunc.h"
#import "Message.h"
#import "LinkMan.h"
#import "CommonFunc.h"
#import "News.h"
#import "AlbumMsg.h"
@interface DDIDataModel : NSObject
{
    sqlite3 *db;
    NSString *hostUser;
    NSString *hostName;
}
@property (nonatomic, strong) NSMutableArray* messages;

-(void)initHostUser:(NSString *)userId hostName:(NSString *)userName;
- (void)addMessage:(Message*)message;
- (void)updateMessage:(Message*)message;

-(void)execSql:(NSString *)sql;
-(void)createTable;
-(void)insertRecord:(NSDictionary *)dict;
-(int)queryMsgByUserId:(NSString *)userId maxId:(int)maxId minId:(int)minId;
-(NSArray *)queryLastMsgGroupByUser:(NSInteger)curId;
-(void) clearUnReadByUser:(NSString *)respondUser;

-(void)compareLastMsg:(Message *)lastMsg;
- (void)updateMessageFlag:(int)rowid flag:(int)flag msgIdArray:(NSArray *)msgIdArray userIdArray:(NSArray *)userIdArray;
-(NSArray *)updateReadFlag:(NSArray *)readedArra;
-(int)getMaxNewsId:(NSString *)newsType userId:(NSString *)userId;
-(void)insertNewsRecord:(NSDictionary *)dict newsType:(NSString *)newsType;
-(NSArray *)queryNewsList:(NSInteger)curId newsType:(NSString *)newsType userId:(NSString *)userId;
-(int)getUnreadNews:(NSString *)newsType userId:(NSString *)userId;
-(void)clearUnReadByNewsId:(int)newsId;
-(void)clearUnreadNewsByTypeAndUserId:(NSString *)newsType userId:(NSString *)userId;
-(void) closeDB;
-(void)insertNewAubumMsg:(NSDictionary *)dict;
-(NSInteger)getAlbumUnreadCount:(NSString *)toId;
-(NSArray *)getAlbumMsgList:(NSString *)toId ifRead:(NSInteger)ifRead;
-(void)updateUnreadAlbumMsg:(NSArray *)msgList;
-(void) deleteAllNews;
-(void) deleteMessageByUserId:(NSString *)respondUser;
@end
