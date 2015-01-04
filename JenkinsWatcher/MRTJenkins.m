//
//  MRTJenkins.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJenkins.h"
#import "MRTJob.h"
#import <Bolts/Bolts.h>
#import <XMLDictionary/XMLDictionary.h>

NSString* const kJenkinsDidBecomeAvailableNotification = @"com.muratgurel.notification.jenkinsAvailable";
NSString* const kJenkinsDidBecomeUnavailableNotification = @"com.muratgurel.notification.jenkinsUnavailable";;
NSString* const kJenkinsDidUpdateFailedJobsNotification = @"com.muratgurel.notification.jenkinsFailedJobUpdate";

NSString* const kInsertedJobsKey = @"insertedJobs";
NSString* const kRemovedJobsKey = @"removedJobs";

@interface MRTJenkins ()

@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readwrite, copy) NSArray *failedJobs;

@property (nonatomic, readwrite) BOOL isAvailable;

@property (nonatomic, readwrite) BOOL isFetching;
@property (nonatomic, strong) BFTask *fetchTask;

@property (nonatomic) BOOL isConnecting;
@property (nonatomic, strong) BFTask *connectionTask;

@property (nonatomic, strong) NSTimer *refreshTimer;

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation MRTJenkins

- (id)initWithURL:(NSURL *)url context:(NSManagedObjectContext *)context {
    NSParameterAssert(url);
    NSParameterAssert(context);
    
    self = [super init];
    if (self) {
        _url = url;
        _context = context;
        
        _isAvailable = NO;
        
        _isFetching = NO;
        _fetchTask = nil;
        
        _isConnecting = NO;
        _connectionTask = nil;
        
        _autoRefresh = YES;
        _autoRefreshInterval = 30;
        _refreshTimer = nil;
        
        _failedJobs = [NSArray array];
    }
    return self;
}

- (BFTask*)connect {
    if (!self.isConnecting) {
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[self jsonApiURL]
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
                       if (urlResponse.statusCode == 200) {
                           NSError *error;
                           NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                           
                           self.isAvailable = (jsonDict != nil && jsonDict.count != 0);
                           [task setResult:@(YES)];
                           
                           if (self.autoRefresh && self.refreshTimer == nil) {
                               [self startRefreshTimer];
                           }
                       }
                       else {
                           self.isAvailable = NO;
                           [task setError:[NSError errorWithDomain:@"" code:-101 userInfo:nil]];
                       }
                       
                       self.isConnecting = NO;
                       self.connectionTask = nil;
                   });
               }] resume];
        
        self.isConnecting = YES;
        self.connectionTask = [task task];
        return self.connectionTask;
    }
    else {
        return self.connectionTask;
    }
}

- (BFTask*)fetchFailedJobs {
    if (!self.isFetching && self.isAvailable) {
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[self latestBuildsURL]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
                        if (urlResponse.statusCode == 200) {
                            [self setChangesAndNotifyWithResponseXML:data];
                        }
                        else {
                            self.failedJobs = [NSArray array];
                            self.isAvailable = NO;
                            [task setError:[NSError errorWithDomain:@"" code:-102 userInfo:nil]];
                        }
                        
                        self.isFetching = NO;
                        self.fetchTask = nil;
                    });
                }] resume];
        
        self.isFetching = YES;
        self.fetchTask = [task task];
        return self.fetchTask;
    }
    else {
        return self.fetchTask;
    }
}

- (void)setChangesAndNotifyWithResponseXML:(NSData*)xmlData {
    NSParameterAssert(xmlData);
    
    XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
    NSDictionary *xmlDictionary = [parser dictionaryWithData:xmlData];
    
    NSRegularExpression *regex = [MRTJob titleStatusRegex];
    NSArray *currentJobs = self.failedJobs;
    
    NSMutableSet *insertedJobs = [NSMutableSet set];
    NSMutableSet *unchangedJobs = [NSMutableSet set];
    
    NSArray *entries;
    if ([[xmlDictionary objectForKey:@"entry"] isKindOfClass:[NSArray class]]) {
        entries = [xmlDictionary objectForKey:@"entry"];
    }
    else if ([[xmlDictionary objectForKey:@"entry"] isKindOfClass:[NSDictionary class]]) {
        entries = [NSArray arrayWithObject:[xmlDictionary objectForKey:@"entry"]];
    }
    else {
        entries = [NSArray array];
    }
    
    for (NSDictionary *entryDictionary in (NSArray*)entries) {
        NSString *title = [entryDictionary objectForKey:@"title"];
        if ([regex numberOfMatchesInString:title options:kNilOptions range:NSMakeRange(0, [title length])] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobID == %@", [MRTJob jobIDFromDictionary:entryDictionary]];
            NSArray *filteredArray = [currentJobs filteredArrayUsingPredicate:predicate];
            
            if ([filteredArray count] > 0) {
                [unchangedJobs addObject:[filteredArray objectAtIndex:0]];
            }
            else {
                [insertedJobs addObject:[MRTJob jobWithDictionary:entryDictionary inContext:self.context]];
            }
        }
    }
    
    NSMutableSet *removedJobs = [NSMutableSet setWithArray:self.failedJobs];
    [removedJobs minusSet:unchangedJobs];
    
    NSSet *failedJobsSet = [unchangedJobs setByAddingObjectsFromSet:insertedJobs];
    
    self.failedJobs = [failedJobsSet allObjects];
    
    NSDictionary *dictionary = @{ kInsertedJobsKey : [insertedJobs allObjects],
                                  kRemovedJobsKey : [removedJobs allObjects] };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJenkinsDidUpdateFailedJobsNotification object:self userInfo:dictionary];
    
    for (MRTJob *job in removedJobs) {
        [self.context deleteObject:job];
    }
}

- (void)startRefreshTimer {
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshInterval target:self selector:@selector(refreshTick:) userInfo:nil repeats:YES];
}

- (void)refreshTick:(NSTimer*)timer {
    [self fetchFailedJobs];
}

#pragma mark - Overriden Setters

- (void)setAutoRefresh:(BOOL)autoRefresh {
    if (_autoRefresh != autoRefresh) {
        _autoRefresh = autoRefresh;
        
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
        
        if (_autoRefresh) {
            [self startRefreshTimer];
        }
    }
}

- (void)setAutoRefreshInterval:(NSUInteger)autoRefreshInterval {
    if (_autoRefreshInterval != autoRefreshInterval) {
        _autoRefreshInterval = autoRefreshInterval;
        
        if (self.autoRefresh) {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
            
            [self startRefreshTimer];
        }
    }
}

- (void)setIsAvailable:(BOOL)isAvailable {
    if (_isAvailable != isAvailable) {
        _isAvailable = isAvailable;
        
        if (_isAvailable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kJenkinsDidBecomeAvailableNotification object:self];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kJenkinsDidBecomeUnavailableNotification object:self];
        }
    }
}

#pragma mark - Helpers

- (NSURL*)jsonApiURL {
    return [self.url URLByAppendingPathComponent:@"api/json"];
}

- (NSURL*)latestBuildsURL {
    return [self.url URLByAppendingPathComponent:@"rssLatest"];
}

@end










