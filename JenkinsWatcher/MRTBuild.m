//
//  MRTBuild.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 09/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTBuild.h"
#import "NSURLSession+Jenkins.h"

@implementation MRTBuild

@dynamic buildID;
@dynamic fullname;
@dynamic url;
@dynamic number;
@dynamic result;
@dynamic isBuilding;
@dynamic isFetching;
@dynamic job;

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    
    if ([dictionary objectForKey:@"fullDisplayName"]) {
        // Longer JSON
        self.fullname = [dictionary objectForKey:@"fullDisplayName"];
        self.buildID = [dictionary objectForKey:@"id"];
        self.result = [[self class] resultFromString:[[dictionary objectForKey:@"result"] lowercaseString]];
        self.isBuilding = [[dictionary objectForKey:@"building"] boolValue];
        // TODO: Parse Builds
    }
    else {
        // If short json, fetch details
        [self fetchBuildDetails];
    }
    
    self.url = [NSURL URLWithString:[dictionary objectForKey:@"url"]];
    self.number = [[dictionary objectForKey:@"number"] intValue];
}

- (void)fetchBuildDetails {
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
                        [self performSelector:@selector(fetchBuildDetails) withObject:nil afterDelay:2.0f];
                    }
                    
                    self.isFetching = NO;
                }] resume];
    }
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Build(%i)", self.number];
}

+ (MRTBuild*)buildWithDictionary:(NSDictionary *)dictionary
                   inContext:(NSManagedObjectContext *)context {
    MRTBuild *newBuild = [NSEntityDescription insertNewObjectForEntityForName:@"Build"
                                                       inManagedObjectContext:context];
    [newBuild updateWithDictionary:dictionary];
    
    return newBuild;
}

+ (int)buildNumberFromDictionary:(NSDictionary *)dictionary {
    return [[dictionary objectForKey:@"number"] intValue];
}

#pragma mark - Helpers

- (NSURL*)jobDetailApiURL {
    return [self.url URLByAppendingPathComponent:@"api/json"];
}

+ (BuildResult)resultFromString:(NSString*)string {
    if ([string isEqualToString:@"SUCCESS"]) {
        return BuildResultSuccess;
    }
    else if ([string isEqualToString:@"FAIL"]) {
        return BuildResultFail;
    }
    else {
        return BuildResultUnknown;
    }
}

@end
