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

@interface MRTJenkins ()

@property (nonatomic, readwrite, copy) NSURL *url;
@property (nonatomic, readwrite, copy) NSArray *failedJobs;

@property (nonatomic, readwrite) BOOL isAvailable;

@property (nonatomic, readwrite) BOOL isFetching;
@property (nonatomic, strong) BFTask *fetchTask;

@property (nonatomic) BOOL isConnecting;
@property (nonatomic, strong) BFTask *connectionTask;

@end

@implementation MRTJenkins

- (id)initWithURL:(NSURL *)url {
    NSParameterAssert(url);
    self = [super init];
    if (self) {
        _url = url;
        
        _isAvailable = NO;
        
        _isFetching = NO;
        _fetchTask = nil;
        
        _isConnecting = NO;
        _connectionTask = nil;
        
        _autoRefresh = YES;
        _autoRefreshInterval = 30;
        
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
                           
                           // TODO: Start auto fetch
                           // TODO: Notification
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
        [[session dataTaskWithURL:[self failedJobsURL]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
                        if (urlResponse.statusCode == 200) {
                            self.failedJobs = [self parseResponseXML:data];
                            [task setResult:self.failedJobs];
                            // TODO: Notification
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

- (NSArray*)parseResponseXML:(NSData*)xmlData {
    NSParameterAssert(xmlData);
    
    XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
    NSDictionary *xmlDictionary = [parser dictionaryWithData:xmlData];
    
    NSMutableArray *array = [NSMutableArray array];
    
    id entries = [xmlDictionary objectForKey:@"entry"];
    if ([entries isKindOfClass:[NSArray class]]) {
        for (NSDictionary *entryDictionary in (NSArray*)entries) {
            [array addObject:[[MRTJob alloc] initWithDictionary:entryDictionary]];
        }
    }
    else if ([entries isKindOfClass:[NSDictionary class]]) {
        [array addObject:[[MRTJob alloc] initWithDictionary:(NSDictionary*)entries]];
    }
    
    return [array copy];
}

#pragma mark - Helpers

- (NSURL*)jsonApiURL {
    return [self.url URLByAppendingPathComponent:@"api/json"];
}

- (NSURL*)failedJobsURL {
    return [self.url URLByAppendingPathComponent:@"rssFailed"];
}

@end










