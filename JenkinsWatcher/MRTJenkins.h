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

@class BFTask;
@class NSManagedObjectContext;

@interface MRTJenkins : NSObject

@property (nonatomic, readonly, copy) NSURL *url;

@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *password;

@property (nonatomic, readonly) BOOL isAvailable;
@property (nonatomic, readonly) BOOL isFetching;

@property (nonatomic) BOOL autoRefresh;
@property (nonatomic) NSUInteger autoRefreshInterval;

- (id)initWithURL:(NSURL*)url context:(NSManagedObjectContext*)context;

- (void)setCredentialsWithUsername:(NSString*)username andPassword:(NSString*)password;

- (BFTask*)connect;
- (BFTask*)fetchJobs;

@end
