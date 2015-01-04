//
//  MRTJob.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJob.h"

@implementation MRTJob

@dynamic jobID;
@dynamic name;
@dynamic url;

+ (MRTJob*)jobWithDictionary:(NSDictionary *)dictionary
                   inContext:(NSManagedObjectContext *)context {
    MRTJob *newJob = [NSEntityDescription insertNewObjectForEntityForName:@"Job"
                                                   inManagedObjectContext:context];
    newJob.jobID = [dictionary objectForKey:@"id"];
    newJob.url = [NSURL URLWithString:[dictionary valueForKeyPath:@"link._href"]];
    
    NSString *title = [dictionary objectForKey:@"title"];
    newJob.name = [[[self class] titleStatusRegex] stringByReplacingMatchesInString:title
                                                                            options:kNilOptions
                                                                              range:NSMakeRange(0, [title length])
                                                                       withTemplate:@""];
    return newJob;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Job(%@)", self.name];
}

+ (NSString*)jobIDFromDictionary:(NSDictionary *)dictionary {
    return [dictionary objectForKey:@"id"];
}

+ (NSRegularExpression*)titleStatusRegex {
    return [NSRegularExpression regularExpressionWithPattern:@"\\s[(]broken since[\\s\\w#]+[)]$"
                                                     options:kNilOptions
                                                       error:nil];
}

@end
