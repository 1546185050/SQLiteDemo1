//
//  ViewController.m
//  SQLiteDemo
//
//  Created by dhp on 30/11/16.
//  Copyright © 2016年 dhp. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import <FMDB.h>

@interface ViewController ()

@end

//设置句柄 通过句柄对数据库进行操作
static sqlite3 * database = nil;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    /*
    //打开
    [self openDatabase];
    //增
    [self insertData];
    //删
    [self deleteData];
    //改
    [self updateData];
    //查
    [self selectData];
    //关闭
    [self closeSqlite];
     */
    
    [self FMDBOpenSqlite];
    [self test];
}

/**
 *  打开数据库并创建一个表
 */
-(void)openDatabase
{
    //1.设置文件名
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"person.db"];
    NSLog(@"path:%@",filename);
    
    //2.打开数据库文件，如果没有会自动创建一个文件
    NSInteger result = sqlite3_open(filename.UTF8String, &database);
    if (result == SQLITE_OK) {
        NSLog(@"打开/创建数据库成功");
        char *error = NULL;
        //3.创建表
        const char *sql = "CREATE TABLE IF NOT EXISTS t_person(id integer primary key autoincrement, name text, age integer)";
        sqlite3_exec(database, sql, NULL, NULL, &error);
        if (error) {
            NSLog(@"error:%s",error);
        }
    }
    else
        NSLog(@"打开数据库失败");
}

/**
 *  插入数据
 */
-(void)insertData
{
    for (NSInteger i = 0; i < 20; i ++)
    {
        NSString *name = [NSString stringWithFormat:@"name-%d",arc4random_uniform(100)];
        NSInteger age = arc4random_uniform(100);
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_person (name, age) VALUES('%@', '%ld')", name, age];
        char *errmsg =NULL;
        sqlite3_exec(database, sql.UTF8String, NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"错误：%s", errmsg);
        }
    }
    NSLog(@"插入完毕");
}

/**
 *  删除数据
 */
-(void)deleteData
{
    NSString *sql = @"DELETE FROM t_person WHERE id > 15 AND id <25";
    char *errmsg = NULL;
    sqlite3_exec(database, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"错误：%s", errmsg);
    }
    else
        NSLog(@"删除完毕");
}

/**
 *  更新数据
 */
-(void)updateData
{
    NSString *sql = @"UPDATE t_person SET name = 'apple' WHERE id = 2;";
    char *errmsg = NULL;
    sqlite3_exec(database, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"错误：%s", errmsg);
    }
    else
        NSLog(@"更新完毕");
}

/**
 *  查询数据
 */
- (void)selectData
{
    //1.准备sqlite语句
    NSString *sql = [NSString stringWithFormat:@"select id,name,age from t_person"];
    //2.伴随指针
    sqlite3_stmt *stmt = NULL;
    //3.预执行sqlite语句
    NSInteger result = sqlite3_prepare_v2(database, sql.UTF8String, -1, &stmt, NULL);
    //第3个参数是一次性返回所有的参数,就用-1
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        //4.执行n次
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            //从伴随指针获取数据,第0列
            NSInteger ID = sqlite3_column_int(stmt, 0);
            //从伴随指针获取数据,第1列
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt, 1)];
            //从伴随指针获取数据,第2列
            NSInteger age = sqlite3_column_int(stmt, 2);
            NSLog(@"ID:%ld;name:%@;age:%ld",ID,name,age);
        }
    }
    else
        NSLog(@"查询失败");
    
    //5.关闭伴随指针
    sqlite3_finalize(stmt);
}

#pragma mark - 4.关闭数据库
- (void)closeSqlite
{
    if (sqlite3_close(database) == SQLITE_OK)
    {
        NSLog(@"数据库关闭成功");
    }
    else
        NSLog(@"数据库关闭失败");
}

-(void)FMDBOpenSqlite
{
    //1.获得数据库文件的路径
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    //2.获得数据库
    FMDatabase *fmdb = [FMDatabase databaseWithPath:fileName];
    
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([fmdb open])
    {
        //4.建表
        BOOL result = [fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (ID integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
        if (result) {
            NSLog(@"创建表成功");
            NSLog(@"%@",fileName);
        }
    }
    
    //测试插入数据
    NSInteger age = 20;
    NSString *name = @"apple";
    for (NSInteger i = 0; i < 3; i ++)
    {
        //1.executeUpdate:不确定的参数用？来占位（后面参数必须是oc对象，；代表语句结束）
        [fmdb executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",name,@(age)];
        
        //2.executeUpdateWithForamat：不确定的参数用%@，%d等来占位 （参数为原始数据类型，执行语句不区分大小写）
        [fmdb executeUpdateWithFormat:@"INSERT INTO t_student (name, age) VALUES (%@,%ld);",name,age];
        
        //3.参数是数组的使用方式
        [fmdb executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);" withArgumentsInArray:@[name,@(age)]];
    }
    

    //测试删除数据
    NSInteger delID = 1;
    [fmdb executeUpdate:@"DELETE FROM t_student WHERE ID = ?;",@(delID)];
//    [fmdb executeUpdateWithFormat:@"DELETE FROM t_student WHERE ID = %ld;",delID];
    
    //测试更新
    NSString *newName = @"new";
    NSString *oldName = @"apple";
    [fmdb executeUpdate:@"update t_student set name = ? where name = ?",newName,oldName];
    
    //测试查询
    //查询整个表
    FMResultSet *resultSet = [fmdb executeQuery:@"select * from t_student;"];
    
    //根据条件查询
//    FMResultSet *resultSet2 = [fmdb executeQuery:@"select * from t_student where id<?;",@(14)];
    
    //遍历结果集合
    while ([resultSet next]) {
        NSInteger idNum = [resultSet intForColumn:@"ID"];
        NSString *nameStr = [resultSet objectForColumnName:@"name"];
        NSInteger ageNum = [resultSet intForColumn:@"age"];
        NSLog(@"ID:%ld;name:%@;age:%ld",idNum,nameStr,ageNum);
    }
    
    //如果表格存在 则销毁
//    [fmdb executeUpdate:@"drop table if exists t_student;"];
}

-(void)test
{
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    NSString *aPath = [doc stringByAppendingPathComponent:@"student.sqlite"];
    FMDatabaseQueue *q = [FMDatabaseQueue databaseQueueWithPath:aPath];
    //1.创建队列
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:aPath];
    __block BOOL whoopsSomethingWrongHappened = true;
    
    //2.线程内操作
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",@"newname1",@(10)];
        [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",@"newname2",@(20)];
    }];
    
    //3.把任务包装到事务里
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback)
     {
         whoopsSomethingWrongHappened =  [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",@"newname3",@(30)];
         whoopsSomethingWrongHappened = [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",@"newname4",@(40)];
         
         whoopsSomethingWrongHappened = [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",@"newname5",@(50)];
         //如果有错误 返回
         if (!whoopsSomethingWrongHappened)
         { 
             *rollback = YES;
             return;
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
