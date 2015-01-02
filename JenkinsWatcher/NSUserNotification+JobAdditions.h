//
//  MRTJobFailedUserNotification.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRTJob;

@interface NSUserNotification (JobAdditions)

+ (NSUserNotification*)notificationWithJob:(MRTJob*)job;

@end
