//
//  MRTJob.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(int16_t, JobStatus) {
    JobStatusStable = 0,
    JobStatusUnstable,
    JobStatusFailed,
    JobStatusUnknown
};

@interface MRTJob : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) JobStatus status;

@property (nonatomic) BOOL isBuildable;
@property (nonatomic) BOOL isFetching;

@property (nonatomic, strong) NSURLSession *session;

- (void)updateWithDictionary:(NSDictionary*)dictionary;
- (void)fetchJobDetails;

+ (MRTJob*)jobWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context;
+ (NSString*)absolutePathFromDictionary:(NSDictionary*)dictionary;

@end
