//
//  NSURLSession+Jenkins.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "NSURLSession+Jenkins.h"

@implementation NSURLSession (Jenkins)

static NSURLSession *_defaultJenkinsSession;

+ (NSURLSession*)defaultJenkinsSession {
    return _defaultJenkinsSession;
}

+ (void)setDefaultJenkinsSession:(NSURLSession *)urlSession {
    _defaultJenkinsSession = urlSession;
}

@end
