//
//  MRTColorDataParser.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 11/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRTColorData.h"

@interface MRTColorDataParser : NSObject

+ (NSArray*)parseData:(NSData*)data;
+ (NSArray*)parseString:(NSString*)string;
+ (NSArray*)parseDataFileAtPath:(NSString*)path;

@end
