//
//  MRTStatusBarDelegate.h
//  JenkinsWatcher
//
//  Created by Murat Gurel on 01/01/15.
//  Copyright (c) 2015 Murat Gurel. All rights reserved.
//

#ifndef JenkinsWatcher_MRTStatusBarDelegate_h
#define JenkinsWatcher_MRTStatusBarDelegate_h

@protocol MRTStatusBarDelegate <NSObject>
@required
- (void)quit;
- (void)showSettings;
@end

#endif
