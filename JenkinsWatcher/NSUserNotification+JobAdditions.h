//
//  MRTJobFailedUserNotification.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kJobObjectURIKey;

@class MRTJob;

@interface NSUserNotification (JobAdditions)

+ (NSUserNotification*)failedNotificationWithJob:(MRTJob*)job;
+ (NSUserNotification*)normalNotificationWithJob:(MRTJob*)job;

@end
