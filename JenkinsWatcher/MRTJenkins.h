//
//  MRTJenkins.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kJenkinsDidBecomeAvailableNotification;
extern NSString* const kJenkinsDidBecomeUnavailableNotification;
extern NSString* const kJenkinsDidUpdateFailedJobsNotification;

extern NSString* const kInsertedJobsKey;
extern NSString* const kRemovedJobsKey;

@class BFTask;
@class NSManagedObjectContext;

@interface MRTJenkins : NSObject

@property (nonatomic, readonly, copy) NSURL *url;
@property (nonatomic, readonly, copy) NSArray *failedJobs;

@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *password;

@property (nonatomic, readonly) BOOL isAvailable;
@property (nonatomic, readonly) BOOL isFetching;

@property (nonatomic) BOOL autoRefresh;
@property (nonatomic) NSUInteger autoRefreshInterval;

- (id)initWithURL:(NSURL*)url context:(NSManagedObjectContext*)context;

- (void)setCredentialsWithUsername:(NSString*)username andPassword:(NSString*)password;

- (BFTask*)connect; // TODO: BFTask
- (BFTask*)fetchFailedJobs; // TODO: BFTask

@end
