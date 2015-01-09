//
//  NSURLSession+Jenkins.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (Jenkins)

+ (NSURLSession*)defaultJenkinsSession;
+ (void)setDefaultJenkinsSession:(NSURLSession*)urlSession;

@end
