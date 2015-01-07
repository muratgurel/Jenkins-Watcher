//
//  MRTAppStatusBar.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTAppStatusBar.h"
#import <Cocoa/Cocoa.h>

#import "MRTJobItem.h"

@interface MRTAppStatusBar ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenu *menu;

@property (nonatomic, weak) id<MRTStatusBarDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *jobItems;

@end

@implementation MRTAppStatusBar

- (id)initWithDelegate:(id<MRTStatusBarDelegate>)delegate {
    NSParameterAssert(delegate);
    
    self = [super init];
    if (self) {
        _delegate = delegate;
        _jobItems = [NSMutableArray array];
        _iconColor = StatusIconColorBlack;
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        _statusItem.title = @"";
        _statusItem.image = [NSImage imageNamed:@"status-icon-black"];
        _statusItem.alternateImage = [NSImage imageNamed:@"status-icon-white"];
        _statusItem.highlightMode = YES;
        
        _menu = [[NSMenu alloc] init];
        [_menu setAutoenablesItems:NO];
        
        [_menu addItem:[NSMenuItem separatorItem]];
        
        [_menu addItem:[self itemWithTitle:@"Settings" action:@selector(showSettings:)]];
        [_menu addItem:[self itemWithTitle:@"Quit" action:@selector(quit:)]];
        
        _statusItem.menu = _menu;
    }
    return self;
}

- (NSMenuItem*)itemWithTitle:(NSString*)title action:(SEL)selector {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:selector keyEquivalent:@""];
    [item setTarget:self];
    
    return item;
}

- (void)clearJobItems {
    for (MRTJobItem *item in self.jobItems) {
        [self.menu removeItem:item];
    }
    
    [self.jobItems removeAllObjects];
}

- (void)addJobMenuItem:(MRTJobItem *)jobItem {
    NSParameterAssert(jobItem);
    
    [self.menu insertItem:jobItem atIndex:0];
    [self.jobItems addObject:jobItem];
}

- (void)setIconColor:(StatusIconColor)iconColor {
    if (_iconColor != iconColor) {
        _iconColor = iconColor;
        
        switch (_iconColor) {
            case StatusIconColorBlack:
                self.statusItem.image = [NSImage imageNamed:@"status-icon-black"];
                break;
            case StatusIconColorRed:
                self.statusItem.image = [NSImage imageNamed:@"status-icon-red"];
                break;
            default:
                break;
        }
    }
}

#pragma MARK - Menu Callbacks

- (void)showSettings:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showSettings)]) {
        [self.delegate showSettings];
    }
}

- (void)quit:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(quit)]) {
        [self.delegate quit];
    }
}

@end
