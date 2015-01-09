//
//  MRTJob.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJob.h"
#import "MRTBuild.h"
#import "NSURLSession+Jenkins.h"

@implementation MRTJob

@dynamic displayName;
@dynamic name;
@dynamic summary;
@dynamic url;
@dynamic status;
@dynamic isBuildable;
@dynamic isFetching;
@dynamic builds;

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    
    if ([dictionary objectForKey:@"displayName"]) {
        // Longer JSON
        self.displayName = [dictionary objectForKey:@"displayName"];
        self.summary = [dictionary objectForKey:@"description"];
        self.isBuildable = [[dictionary objectForKey:@"buildable"] boolValue];
        
        NSPredicate *buildPredicate = [NSPredicate predicateWithFormat:@"number == $NUMBER"];
        
        for (NSDictionary *buildDictionary in [dictionary objectForKey:@"builds"]) {
            int buildNumber = [MRTBuild buildNumberFromDictionary:buildDictionary];
            NSSet *result = [self.builds filteredSetUsingPredicate:[buildPredicate predicateWithSubstitutionVariables:@{@"NUMBER":@(buildNumber)}]];
            if (result.count == 0) {
                MRTBuild *newBuild = [MRTBuild buildWithDictionary:buildDictionary
                                                         inContext:self.managedObjectContext];
                newBuild.job = self;
                [newBuild fetchBuildDetails];
                
                [self addBuildsObject:newBuild];
            }
        }
    }
    else {
        // If short json, fetch details
        [self fetchJobDetails];
    }
    
    self.name = [dictionary objectForKey:@"name"];
    self.url = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
    self.status = [[self class] statusFromColorString:[[dictionary objectForKey:@"color"] lowercaseString]];
}

- (void)fetchJobDetails {
    if (!self.isFetching) {
        self.isFetching = YES;
        
        NSURLSession *session = [NSURLSession defaultJenkinsSession];
        [[session dataTaskWithURL:[self jobDetailApiURL]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
                    if (urlResponse.statusCode == 200) {
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        if (json) {
                            [self updateWithDictionary:json];
                        }
                    }
                    else {
                        [self performSelector:@selector(fetchJobDetails) withObject:nil afterDelay:2.0f];
                    }
                    
                    self.isFetching = NO;
                }] resume];
    }
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Job(%@)", self.name];
}

+ (MRTJob*)jobWithDictionary:(NSDictionary *)dictionary
                   inContext:(NSManagedObjectContext *)context {
    MRTJob *newJob = [NSEntityDescription insertNewObjectForEntityForName:@"Job"
                                                   inManagedObjectContext:context];
    [newJob updateWithDictionary:dictionary];
    
    return newJob;
}

#pragma mark - Helpers

- (NSURL*)jobDetailApiURL {
    return [self.url URLByAppendingPathComponent:@"api/json"];
}

+ (NSString*)absolutePathFromDictionary:(NSDictionary *)dictionary {
    return [dictionary objectForKey:@"url"];
}

+ (JobStatus)statusFromColorString:(NSString*)colorString {
    if ([colorString isEqualToString:@"blue"]) {
        return JobStatusStable;
    }
    else if ([colorString isEqualToString:@"yellow"]) {
        return JobStatusUnstable;
    }
    else if ([colorString isEqualToString:@"red"]) {
        return JobStatusFailed;
    }
    else {
        return JobStatusUnknown;
    }
}

@end
