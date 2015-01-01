//
//  MRTAppStatusBar.m
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#import "MRTAppStatusBar.h"
#import <Cocoa/Cocoa.h>

@interface MRTAppStatusBar ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenu *menu;
@property (nonatomic, weak) id<MRTStatusBarDelegate> delegate;

@end

@implementation MRTAppStatusBar

- (id)initWithDelegate:(id<MRTStatusBarDelegate>)delegate {
    NSParameterAssert(delegate);
    
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        _statusItem.title = @"";
        _statusItem.image = [NSImage imageNamed:@"status-icon"];
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
