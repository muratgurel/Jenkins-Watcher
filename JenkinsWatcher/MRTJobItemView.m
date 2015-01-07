//
//  MRTJobItemView.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 07/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTJobItemView.h"

@interface MRTJobItemView ()

@property (nonatomic) BOOL isMouseInside;

@end

@implementation MRTJobItemView

- (void)drawRect:(NSRect)dirtyRect {
    if ([self.enclosingMenuItem isHighlighted]) {
        [[NSColor colorWithRed:148/255.0 green:210/255.0 blue:255/255.0 alpha:0.2] setFill];
        NSRectFill(dirtyRect);
    }
    
    [super drawRect:dirtyRect];
}

- (void)mouseUp:(NSEvent*)event {
    NSMenuItem *item = [self enclosingMenuItem];
    NSMenu *menu = [item menu];
    if (nil != menu) {
        NSInteger index = [menu indexOfItem:item];
        [menu cancelTracking];
        [menu performActionForItemAtIndex:index];
        
        // hack to reset highlighted menu item state
        NSArray *items = [menu itemArray];
        [menu removeAllItems];
        for (NSMenuItem *item in items) {
            [menu addItem:item];
        }
    }
}

@end
