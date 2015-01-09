//
//  MRTBuild.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(int16_t, BuildResult) {
    BuildResultSuccess,
    BuildResultFail,
    BuildResultUnknown
};

@interface MRTBuild : NSManagedObject

@property (nonatomic, strong) NSString *buildID;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic) int number;
@property (nonatomic) BuildResult result;

@property (nonatomic) BOOL isBuilding;
@property (nonatomic) BOOL isFetching;

- (void)updateWithDictionary:(NSDictionary*)dictionary;
- (void)fetchBuildDetails;

+ (MRTBuild*)buildWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context;

@end
