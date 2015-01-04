//
//  MRTJobFailedUserNotification.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 02/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "NSUserNotification+JobAdditions.h"
#import "MRTJob.h"

@implementation NSUserNotification (JobAdditions)

// TODO: Can you not create a subclass of NSUserNotification? It failed before.
+ (NSUserNotification*)failedNotificationWithJob:(MRTJob *)job {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Job Failed";
    notification.informativeText = job.name;
    // TODO: Set image & sound
    //        notification.soundName = NSUserNotificationDefaultSoundName;
    //        [notification setContentImage:]
    return notification;
}

+ (NSUserNotification*)normalNotificationWithJob:(MRTJob *)job {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Job Back to Normal";
    notification.informativeText = job.name;
    // TODO: Set image & sound
    //        notification.soundName = NSUserNotificationDefaultSoundName;
    //        [notification setContentImage:]
    return notification;
}

@end
