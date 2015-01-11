//
//  MRTColorData.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 11/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRTColorData : NSObject

@property (nonatomic, readonly) NSRegularExpression *regex;

@property (nonatomic, readonly) NSUInteger groupCount;
@property (nonatomic, readonly, copy) NSArray *colors;

- (id)initWithRegex:(NSRegularExpression*)regex colors:(NSArray*)colors;
+ (MRTColorData*)colorDataWithRegex:(NSRegularExpression*)regex colors:(NSArray*)colors;

@end
