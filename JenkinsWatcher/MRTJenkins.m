//
//  MRTJenkins.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJenkins.h"
#import "NSURLSession+Jenkins.h"
#import "MRTJob.h"
#import <Bolts/Bolts.h>
#import <XMLDictionary/XMLDictionary.h>

NSString* const kJenkinsDidBecomeAvailableNotification = @"com.muratgurel.notification.jenkinsAvailable";
NSString* const kJenkinsDidBecomeUnavailableNotification = @"com.muratgurel.notification.jenkinsUnavailable";

@interface MRTJenkins ()

@property (nonatomic, readwrite, copy) NSURL *url;

@property (nonatomic, readwrite, copy) NSString *username;
@property (nonatomic, readwrite, copy) NSString *password;

@property (nonatomic, readwrite) BOOL isAvailable;

@property (nonatomic, readwrite) BOOL isFetching;
@property (nonatomic, strong) BFTask *fetchTask;

@property (nonatomic) BOOL isConnecting;
@property (nonatomic, strong) BFTask *connectionTask;

@property (nonatomic, strong) NSTimer *refreshTimer;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSURLSession *session;

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
    }
    return self;
}

- (BFTask*)connect {
    if (!self.isConnecting) {
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        
        // Jenkins may have changed, remove old jobs & builds
        [self deleteAllJobs];
        
        self.session = [NSURLSession sessionWithConfiguration:[[self class] authorizedSessionConfigurationWithUsername:self.username andPassword:self.password]];
        [NSURLSession setDefaultJenkinsSession:self.session];
        
        [[self.session dataTaskWithURL:[self jsonApiURL]
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

- (void)setCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password {
    self.username = username;
    self.password = password;
}

- (BFTask*)fetchJobs {
    if (!self.isFetching && self.isAvailable) {
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        
        [[self.session dataTaskWithURL:[self jsonApiURL]
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
                             if (urlResponse.statusCode == 200) {
                                 [self updateJenkinsWithData:data];
                             }
                             else {
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

- (void)updateJenkinsWithData:(NSData*)jsonData {
    NSParameterAssert(jsonData);
    
    NSError *error;
    NSDictionary *jenkinsInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                  error:&error];
    
    // TODO: Error handling
    if (!jenkinsInfo) return;
    
    NSArray *jobs = [jenkinsInfo objectForKey:@"jobs"];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"url.absoluteString == $ABSOLUTE_PATH"];
    
    for (NSDictionary *jobDict in jobs) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Job"];
        fetchRequest.predicate = [predicateTemplate predicateWithSubstitutionVariables:@{@"ABSOLUTE_PATH":[MRTJob absolutePathFromDictionary:jobDict]}];
        
        NSArray *results = [self.context executeFetchRequest:fetchRequest error:nil];
        if (results.count > 0) {
            MRTJob *job = (MRTJob*)results[0];
            [job updateWithDictionary:jobDict];
        }
        else {
            [MRTJob jobWithDictionary:jobDict inContext:self.context];
        }
    }
    
    // TODO: Delete removed job from the context
}

- (void)startRefreshTimer {
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshInterval target:self selector:@selector(refreshTick:) userInfo:nil repeats:YES];
}

- (void)refreshTick:(NSTimer*)timer {
    [self fetchJobs];
}

- (void)deleteAllJobs {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Job"];
    NSArray *allJobs = [self.context executeFetchRequest:fetchRequest error:nil];
    
    for (MRTJob *job in allJobs) {
        [self.context deleteObject:job];
    }
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
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:self.url
                                                  resolvingAgainstBaseURL:NO];
    urlComponents.path = @"/api/json";
    urlComponents.query = @"tree=jobs[name,displayName,description,url,buildable,color,builds[fullDisplayName,id,result,building,url,number]]";
    
    return [urlComponents URL];
}

+ (NSURLSessionConfiguration*)authorizedSessionConfigurationWithUsername:(NSString*)username
                                                             andPassword:(NSString*)password {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    if (username && password) {
        NSString *credentialsString = [NSString stringWithFormat:@"%@:%@", username, password];
        NSData *credentialsData = [credentialsString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *baseEncodedCredentials = [credentialsData base64EncodedStringWithOptions:kNilOptions];
        NSString *authString = [NSString stringWithFormat:@"Basic %@", baseEncodedCredentials];
        
        [configuration setHTTPAdditionalHeaders:@{ @"Authorization" : authString }];
    }
    
    return configuration;
}

@end










