//
//  MRTFailedJobsController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTFailedJobsController.h"
#import "NSUserNotification+JobAdditions.h"
#import <CoreData/CoreData.h>
#import "MRTAppStatusBar.h"
#import "MRTJobItem.h"
#import "MRTJob.h"

// TDOO: This class can be refactored into 2 classes. StatusBarController, NotificationController
@interface MRTFailedJobsController () <NSUserNotificationCenterDelegate>

@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, strong, readwrite) MRTAppStatusBar *statusBar;

@property (nonatomic, strong) NSMutableArray *failedJobs;

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
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Job"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status == %i", JobStatusFailed]];
        [fetchRequest setSortDescriptors:[[self class] sortDescriptors]];
        
        NSArray *results = [self.context executeFetchRequest:fetchRequest error:nil];
        if (results.count > 0) {
            _failedJobs = [results mutableCopy];
            [self updateStatusBar];
        }
        else {
            _failedJobs = [NSMutableArray array];
        }
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChangeObjects:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
    }
    return self;
}

- (void)dealloc {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:nil];
}

- (void)handleJobItemClick:(MRTJobItem*)item {
    [[NSWorkspace sharedWorkspace] openURL:[item.job url]];
}

- (void)updateStatusBar {
    [self.statusBar clearJobItems];
    
    for (MRTJob *job in self.failedJobs) {
        MRTJobItem *item = [[MRTJobItem alloc] initWithJob:job];
        [item setTarget:self];
        [item setAction:@selector(handleJobItemClick:)];
        
        [self.statusBar addJobMenuItem:item];
    }
    
    if ([self.failedJobs count] > 0) {
        [self.statusBar setIconColor:StatusIconColorRed];
    }
    else {
        [self.statusBar setIconColor:StatusIconColorBlack];
    }
}

- (void)presentUserNotificationForNewFailedJobs:(NSArray*)newFailedJobs
                                   andFixedJobs:(NSArray*)fixedJobs {
    if (!self.isFirstTimeFetch) {
        for (MRTJob *job in fixedJobs) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[NSUserNotification normalNotificationWithJob:job]];
        }
        
        for (MRTJob *job in newFailedJobs) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[NSUserNotification failedNotificationWithJob:job]];
        }
    }
    else {
        self.isFirstTimeFetch = NO;
    }
}

#pragma mark - NSManagedObjectContext Notification

- (void)contextDidChangeObjects:(NSNotification*)notification {
    NSArray *insertedObjects = [[notification.userInfo objectForKey:NSInsertedObjectsKey] allObjects];
    NSArray *updatedObjects = [[notification.userInfo objectForKey:NSUpdatedObjectsKey] allObjects];
    
    NSPredicate *jobPredicate = [NSPredicate predicateWithFormat: @"class == %@", [MRTJob class]];
    NSPredicate *failedJobPredicate = [NSPredicate predicateWithFormat: @"class == %@ && status == %i", [MRTJob class], JobStatusFailed];
    
    NSArray *newFailedJobs = [insertedObjects filteredArrayUsingPredicate:failedJobPredicate];
    NSMutableArray *fixedJobs = [NSMutableArray array];
    
    NSArray *updatedJobs = [updatedObjects filteredArrayUsingPredicate:jobPredicate];
    for (MRTJob *job in updatedJobs) {
        NSDictionary *changedValues = [job changedValues];
        if ([changedValues objectForKey:@"status"]) {
            JobStatus oldStatus = [[changedValues objectForKey:@"status"] intValue];
            if (oldStatus == JobStatusFailed && job.status == JobStatusStable) {
                [fixedJobs addObject:job];
            }
        }
    }
    
    NSMutableSet *failedJobsSet = [NSMutableSet setWithArray:self.failedJobs];
    [failedJobsSet minusSet:[NSSet setWithArray:fixedJobs]];
    [failedJobsSet unionSet:[NSSet setWithArray:newFailedJobs]];
    self.failedJobs = [[failedJobsSet allObjects] mutableCopy];
    [self.failedJobs sortUsingDescriptors:[[self class] sortDescriptors]];
    
    [self updateStatusBar];
    [self presentUserNotificationForNewFailedJobs:newFailedJobs andFixedJobs:[fixedJobs copy]];
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

#pragma mark - Helpers

+ (NSArray*)sortDescriptors {
    static NSArray *_sortDescriptors = nil;
    if (!_sortDescriptors) {
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    }
    
    return _sortDescriptors;
}

@end
