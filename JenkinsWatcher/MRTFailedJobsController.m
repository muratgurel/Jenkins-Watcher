//
//  MRTFailedJobsController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTFailedJobsController.h"
#import "NSUserNotification+JobAdditions.h"
#import "MRTAppStatusBar.h"
#import <AppKit/AppKit.h>
#import "MRTJobItem.h"
#import "MRTJob.h"

@interface MRTFailedJobsController () <NSUserNotificationCenterDelegate>

@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, strong, readwrite) MRTAppStatusBar *statusBar;

@property (nonatomic, strong) NSArrayController *jobsArrayController;

@property (nonatomic) BOOL isFirstTimeFetch;

@end

@implementation MRTFailedJobsController

- (id)initWithContext:(NSManagedObjectContext *)context
         andStatusBar:(MRTAppStatusBar *)statusBar
{
    self = [super init];
    if (self) {
        _context = context;
        _statusBar = statusBar;
        _isFirstTimeFetch = YES;
        
        _jobsArrayController = [[NSArrayController alloc] init];
        [_jobsArrayController setManagedObjectContext:context];
        [_jobsArrayController setEntityName:@"Job"];
        [_jobsArrayController setFetchPredicate:[NSPredicate predicateWithFormat:@"status == %i", JobStatusFailed]];
        [_jobsArrayController addObserver:self forKeyPath:@"arrangedObjects" options:NSKeyValueObservingOptionNew context:NULL];
        [_jobsArrayController setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [_jobsArrayController fetch:self];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"arrangedObjects"]) {
        [self.statusBar clearJobItems];
        
        if (!self.isFirstTimeFetch) {
            // TODO: Present notifications
//            NSArray *removedJobs = [notification.userInfo objectForKey:kRemovedJobsKey];
//            NSArray *insertedJobs = [notification.userInfo objectForKey:kInsertedJobsKey];
//            
//            for (MRTJob *job in removedJobs) {
//                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[NSUserNotification normalNotificationWithJob:job]];
//            }
//            
//            for (MRTJob *job in insertedJobs) {
//                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[NSUserNotification failedNotificationWithJob:job]];
//            }
        }
        else {
            self.isFirstTimeFetch = NO;
        }
        
        for (MRTJob *job in [self.jobsArrayController arrangedObjects]) {
            MRTJobItem *item = [[MRTJobItem alloc] initWithJob:job];
            [item setTarget:self];
            [item setAction:@selector(handleJobItemClick:)];
            
            [self.statusBar addJobMenuItem:item];
        }
        
        if ([[self.jobsArrayController arrangedObjects] count] > 0) {
            [self.statusBar setIconColor:StatusIconColorRed];
        }
        else {
            [self.statusBar setIconColor:StatusIconColorBlack];
        }

    }
}

- (void)handleJobItemClick:(MRTJobItem*)item {
    [[NSWorkspace sharedWorkspace] openURL:[item.job url]];
}

#pragma mark - User Notification Delegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    NSURL *objectURI = [NSURL URLWithString:[notification.userInfo objectForKey:kJobObjectURIKey]];
    NSManagedObjectID *objectID = [[self.context persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    if (objectID) {
        MRTJob *job = (MRTJob*)[self.context objectWithID:objectID];
        [[NSWorkspace sharedWorkspace] openURL:job.url];
    }
}

@end
