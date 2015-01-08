//
//  MRTJob.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MRTJob : NSManagedObject

@property (nonatomic, strong) NSString *jobID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *url;

- (void)updateWithDictionary:(NSDictionary*)dictionary;

+ (MRTJob*)jobWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context;
+ (NSString*)absolutePathFromDictionary:(NSDictionary*)dictionary;

@end
