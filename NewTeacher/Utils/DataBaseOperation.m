//
//  DataBaseOperation.m
//  TY
//
//  Created by songzhanglong on 14-6-12.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "DataBaseOperation.h"
#import "NSObject+Reflect.h"
#import "MyMsgModel.h"

#pragma mark - 我的消息表
#define MSG_MY_TABLE            @"msgMyTable2"
#define MSG_PRIMARYKEY          @"primaryId"
#define MSG_MY_DATE             @"date"     //时间戳表名
#define MSG_MY_EACHDATA         @"eachData" //接口名称
#define MSG_MY_FLAG             @"flag"     //时间戳
#define MSG_MY_MDFLAG           @"mdFlag"   //表名
#define MSG_MY_SENDER           @"sender"   //主键id
#define MSG_MY_ID               @"id"       //id
#define MSG_MY_URL              @"url"      //

#pragma mark - 里程列表查看记录
#define MILEAGE_TABLE           @"mileageTable"
#define MILEAGE_USERID          @"userid"   //
#define MILEAGE_ALBUM_ID        @"album_id"  //
#define MILEAGE_PHOTO_IDS       @"photoids"
#define MILEAGE_ID              @"id"

@implementation DataBaseOperation

- (void)dealloc
{
    [self releaseDatabaseQueue];
}



#pragma mark - 数据库的打开与关闭
+ (DataBaseOperation *)shareInstance
{
    static DataBaseOperation *databaseOperation = nil;
    static dispatch_once_t onceTokenDatabase;
    dispatch_once(&onceTokenDatabase, ^{
        databaseOperation = [[DataBaseOperation alloc] init];
    });
    
    return databaseOperation;
}

/**
 *	@brief	打开数据库
 *
 *	@param 	filePath 	数据库路径
 */
- (void)openDataBase:(NSString *)filePath
{
    if (_databaseQueue) {
        [self releaseDatabaseQueue];
    }
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    /*
     [_databaseQueue inDatabase:^(FMDatabase *db) {
     
     }];
     */
    [_databaseQueue close];
    self.databaseName = [filePath lastPathComponent];
}

/**
 *	@brief	关闭数据库
 */
- (void)close
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

/**
 *	@brief	释放队列
 */
- (void)releaseDatabaseQueue
{
    if (_databaseQueue) {
        [_databaseQueue close];
    }
    _databaseQueue = nil;
}

#pragma mark - 建表
/**
 *	@brief	创建表
 *
 *	@param 	type 	表类型
 */
- (void)createTableByType:(kTableType)type
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            switch (type) {
                case kTableMyMsg:
                {
//                    NSString *dele = @"drop table msgMyTable1;";
//                    [db executeStatements:dele];
                    
                    NSString *msgMy = [NSString stringWithFormat:@"create table if not exists %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null,%@ text not null);",MSG_MY_TABLE,MSG_PRIMARYKEY,MSG_MY_DATE,MSG_MY_EACHDATA,MSG_MY_FLAG,MSG_MY_MDFLAG,MSG_MY_SENDER,MSG_MY_ID,MSG_MY_URL];   //我的消息
                    NSString *mileageTable = [NSString stringWithFormat:@"create table if not exists %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ text not null,%@ text not null,%@ text not null);",MILEAGE_TABLE,MILEAGE_ID,MILEAGE_USERID,MILEAGE_ALBUM_ID,MILEAGE_PHOTO_IDS];   //里程
                    [db executeStatements:msgMy];
                    [db executeStatements:mileageTable];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

#pragma mark - 我的消息表
- (void)insertMyMsg:(MyMsgModel *)model
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *insertStr = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@) values ('%@','%@','%@','%@','%@','%@','%@')",MSG_MY_TABLE,MSG_MY_DATE,MSG_MY_EACHDATA,MSG_MY_FLAG,MSG_MY_MDFLAG,MSG_MY_SENDER,MSG_MY_ID,MSG_MY_URL,model.date,model.eachData,model.flag,model.mdFlag,model.sender,model.id,model.url];
            [db executeStatements:insertStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (void)deleteMyMsg:(NSArray *)array
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            for (MyMsgModel *model in array) {
                NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = '%ld'",MSG_MY_TABLE,MSG_PRIMARYKEY,(long)model.primaryKey];
                [db executeStatements:deleteStr];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (NSArray *)selectMyMsgByDateAsc:(BOOL)success
{
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(array) weakArr = array;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *order = success ? @"asc" : @"desc";
            NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@,%@,%@,%@,%@ from %@ order by %@ %@",MSG_MY_DATE,MSG_MY_EACHDATA,MSG_MY_FLAG,MSG_MY_MDFLAG,MSG_MY_SENDER,MSG_MY_ID,MSG_PRIMARYKEY,MSG_MY_URL,MSG_MY_TABLE,MSG_MY_DATE,order];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *date = [result stringForColumnIndex:0];
                NSString *eachdata = [result stringForColumnIndex:1];
                NSString *flag = [result stringForColumnIndex:2];
                NSString *mdflag = [result stringForColumnIndex:3];
                NSString *sender = [result stringForColumnIndex:4];
                NSString *tid = [result stringForColumnIndex:5];
                NSInteger primaryKey = [result intForColumnIndex:6];
                NSString *url = [result stringForColumnIndex:7];
                
                MyMsgModel *msgModel = [[MyMsgModel alloc] init];
                msgModel.date = date;
                msgModel.eachData = eachdata;
                msgModel.flag = flag;
                msgModel.mdFlag = mdflag;
                msgModel.sender = sender;
                msgModel.id = tid;
                msgModel.primaryKey = primaryKey;
                msgModel.url = url;
                
                [msgModel calculeteConSize:[UIScreen mainScreen].bounds.size.width - 70 Font:[UIFont systemFontOfSize:16]];
                
                [weakArr addObject:msgModel];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return array;
}

#pragma mark - 里程
- (void)insertMileage:(NSString *)userId Batch:(NSString *)albumId Photo:(NSString *)photoIds
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *insertStr = [NSString stringWithFormat:@"insert into %@(%@,%@,%@) values ('%@','%@','%@')",MILEAGE_TABLE,MILEAGE_USERID,MILEAGE_ALBUM_ID,MILEAGE_PHOTO_IDS,userId,albumId,photoIds];
            [db executeStatements:insertStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (void)deleteMileageBy:(NSString *)mileageId
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",MILEAGE_TABLE,MILEAGE_ALBUM_ID,mileageId];
            [db executeStatements:deleteStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

- (NSMutableArray *)selectMileageListBy:(NSString *)userid
{
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(array) weakArr = array;
    
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ where %@ = '%@'",MILEAGE_ID,MILEAGE_USERID,MILEAGE_ALBUM_ID,MILEAGE_PHOTO_IDS,MILEAGE_TABLE,MILEAGE_USERID,userid];
            FMResultSet *result = [db executeQuery:selectStr];
            while ([result next]) {
                NSString *mId = [result stringForColumnIndex:0];
                NSString *userid = [result stringForColumnIndex:1];
                NSString *albumId = [result stringForColumnIndex:2];
                NSString *photoIds = [result stringForColumnIndex:3];
                
                NSDictionary *dic = @{@"id":mId,@"userid":userid ?: @"",@"albumid":albumId ?: @"",@"photoids":photoIds ?: @""};
                [weakArr addObject:dic];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
    
    return array;
}

- (void)updateMileagePhotoIds:(NSString *)photoIds By:(NSString *)mid
{
    [_databaseQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try {
            NSString *selectStr = [NSString stringWithFormat:@"update %@ set %@= ? where %@='%@'",MILEAGE_TABLE,MILEAGE_PHOTO_IDS,MILEAGE_ALBUM_ID,mid];
            if (![db executeUpdate:selectStr,photoIds]) {
                NSLog(@"failed:%@",selectStr);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        @finally {
            
        }
    }];
}

@end
