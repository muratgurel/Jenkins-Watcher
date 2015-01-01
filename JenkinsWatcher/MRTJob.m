//
//  MRTJob.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJob.h"

@interface MRTJob ()

@property (nonatomic, strong) NSString *jobID;

@end

@implementation MRTJob

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [super init];
    if (self) {
        _jobID = [dictionary objectForKey:@"id"];
        _url = [NSURL URLWithString:[dictionary valueForKeyPath:@"link._href"]];
        _name = [[dictionary objectForKey:@"title"] stringByReplacingOccurrencesOfString:@" (broken since this build)" withString:@""];
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Job(%@)", self.name];
}

#pragma MARK - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[MRTJob class]]) {
        MRTJob *job = (MRTJob*)object;
        return [job.jobID isEqualToString:self.jobID];
    }
    
    return NO;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[MRTJob class]]) {
        MRTJob *job = (MRTJob*)object;
        return [job.jobID isEqualToString:self.jobID];
    }
    
    return NO;
}

@end
