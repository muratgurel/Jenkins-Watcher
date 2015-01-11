//
//  MRTColorDataParser.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 11/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTColorDataParser.h"
#import <Cocoa/Cocoa.h>

@implementation MRTColorDataParser

+ (NSArray*)parseData:(NSData *)data {
    NSParameterAssert(data);
    return [[self class] parseString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

+ (NSArray*)parseDataFileAtPath:(NSString *)path {
    NSParameterAssert(path);
    return [[self class] parseData:[[NSData alloc] initWithContentsOfFile:path]];
}

+ (NSArray*)parseString:(NSString *)string {
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    if (lines.count == 0) {
        return nil;
    }
    
    NSRegularExpression *colorRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\((\\d{1,3}),(\\d{1,3}),(\\d{1,3})\\)$"
                                                                                options:kNilOptions
                                                                                  error:nil];
    
    NSMutableArray *colorDatas = [NSMutableArray array];
    for (NSString *line in lines) {
        NSArray *sections = [line componentsSeparatedByString:@" "];
        if (sections.count > 0) {
            NSString *regexString = [sections objectAtIndex:0];
            regexString = [regexString substringWithRange:NSMakeRange(1, [regexString length] - 2)]; // Remove "
            
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                                   options:kNilOptions
                                                                                     error:&error];
            if (error) {
                // TODO: Error handling
                return nil;
            }
            
            if ([sections count] - 1 != [regex numberOfCaptureGroups]) {
                // TODO: Error handling
                return nil;
            }
            
            NSMutableArray *colors;
            
            if ([regex numberOfCaptureGroups] != 0) {
                colors = [NSMutableArray arrayWithCapacity:[regex numberOfCaptureGroups]];
                
                for (int i = 0; i < [regex numberOfCaptureGroups]; i++) {
                    NSString *colorString = [sections objectAtIndex:i + 1];
                    NSArray *results = [colorRegex matchesInString:colorString
                                                           options:kNilOptions
                                                             range:NSMakeRange(0, [colorString length])];
                    if (results.count == 0) {
                        // TODO: Error Handling
                        return nil;
                    }
                    
                    NSTextCheckingResult *result = [results objectAtIndex:0];
                    NSColor *color = [NSColor colorWithDeviceRed:[[colorString substringWithRange:[result rangeAtIndex:1]] intValue]/255.0
                                                           green:[[colorString substringWithRange:[result rangeAtIndex:2]] intValue]/255.0
                                                            blue:[[colorString substringWithRange:[result rangeAtIndex:3]] intValue]/255.0
                                                           alpha:1];
                    
                    [colors addObject:color];
                }
            }
            
            [colorDatas addObject:[MRTColorData colorDataWithRegex:regex colors:colors]];
        } else {
            // TODO: Error handling
            return nil;
        }
    }
    
    return [colorDatas copy];
}

@end
