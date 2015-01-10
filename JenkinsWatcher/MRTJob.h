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

@class MRTBuild;

@interface MRTJob : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) JobStatus status;

@property (nonatomic) BOOL isBuildable;
@property (nonatomic) BOOL isFetching;

@property (nonatomic, strong) NSSet *builds;

- (void)updateWithDictionary:(NSDictionary*)dictionary;
- (void)fetchJobDetails;

+ (MRTJob*)jobWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context;
+ (NSString*)absolutePathFromDictionary:(NSDictionary*)dictionary;

@end

@interface MRTJob (CoreDataGeneratedAccessors)

- (void)addBuildsObject:(MRTBuild *)value;
- (void)removeBuildsObject:(MRTBuild *)value;
- (void)addBuilds:(NSSet *)values;
- (void)removeBuilds:(NSSet *)values;

@end