//
//  Student.h
//  SQLiteDemo
//
//  Created by dhp on 02/12/16.
//  Copyright © 2016年 dhp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property(nonatomic, assign) NSInteger ID;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSInteger age;

@end
