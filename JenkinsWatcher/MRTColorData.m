//
//  MRTColorData.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 11/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTColorData.h"

@interface MRTColorData ()

@property (nonatomic, readwrite) NSRegularExpression *regex;
@property (nonatomic, readwrite, copy) NSArray *colors;

@end

@implementation MRTColorData

- (id)initWithRegex:(NSRegularExpression *)regex colors:(NSArray *)colors {
    self = [super init];
    if (self) {
        _regex = regex;
        _colors = colors;
    }
    return self;
}

+ (MRTColorData*)colorDataWithRegex:(NSRegularExpression *)regex colors:(NSArray *)colors {
    return [[[self class] alloc] initWithRegex:regex colors:colors];
}

- (NSUInteger)groupCount {
    return [self.regex numberOfCaptureGroups];
}

@end
