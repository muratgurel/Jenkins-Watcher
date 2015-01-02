//
//  MRTJob.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTJob : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSURL *url;

- (id)initWithDictionary:(NSDictionary*)dictionary;
+ (NSRegularExpression*)titleStatusRegex;

@end
