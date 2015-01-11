//
//  MRTConsoleViewController.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 11/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTConsoleViewController.h"
#import "MRTColorDataParser.h"

@interface MRTConsoleViewController () <NSTextStorageDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (nonatomic, strong) NSArray *coloringDatas;

@end

@implementation MRTConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"ConsoleColoringData" ofType:@""];
    NSData *coloringData = [[NSData alloc] initWithContentsOfFile:dataPath];
    NSString *coloringText = [[NSString alloc] initWithData:coloringData encoding:NSUTF8StringEncoding];
    
    self.coloringDatas = [MRTColorDataParser parseString:coloringText];
    
    [[self.textView textStorage] setDelegate:self];
    [self.textView setString:@"Started by user anonymous\nBuilding in workspace /Users/Shared/Jenkins/Home/workspace/Mobile - iOS - Deneme\n[Mobile - iOS - Deneme] $ /bin/sh -xe /Users/Shared/Jenkins/tmp/hudson5351916568551339527.sh\n+ exit 1\nBuild step 'Execute shell' marked build as failure\nFinished: FAILURE"];
}

#pragma mark - NSTextStorage Delegate

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    NSTextStorage *textStorage = notification.object;
    NSString *string = textStorage.string;
    NSUInteger textLength = string.length;
    
    [textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, textLength)];
    
    NSUInteger lineOffset = 0;
    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        for (MRTColorData *colorData in self.coloringDatas) {
            NSArray *matches = [colorData.regex matchesInString:line options:kNilOptions range:NSMakeRange(0, [line length])];
            for (NSTextCheckingResult *result in matches) {
                for (int i = 0; i < colorData.groupCount; i++) {
                    NSRange matchRange = [result rangeAtIndex:i + 1];
                    if (matchRange.location != NSNotFound) {
                        [textStorage addAttribute:NSForegroundColorAttributeName
                                            value:[colorData.colors objectAtIndex:i]
                                            range:NSMakeRange(lineOffset + matchRange.location, matchRange.length)];
                    }
                }
            }
        }
        
        lineOffset += [line length] + 1; // + 1 for line ending
    }
}

@end
