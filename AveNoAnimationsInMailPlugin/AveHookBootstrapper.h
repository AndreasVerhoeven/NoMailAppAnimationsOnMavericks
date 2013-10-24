//
//  AveHookBootstrapper.h
//  AveNoAnimationsInMailPlugin
//
//  Created by Andreas Verhoeven on 24-10-13.
//  Copyright (c) 2013 AveApps. All rights reserved.
//

#import <Foundation/Foundation.h>

// This Plugin disables Mail.app animations in 10.9
// by swizzling Mail.app's -[DocumentEditor shouldDoPopOutAnimation]
// to return NO always.
//
// To disable the sent-animation, we swizzle -[DocumentEditor _performSendAnimation]
// to directly class -[DocumentEditor __sendAnimationCompleted]
//
// Store plugin bundle in ~/Library/Mail/Bundles/
// and run 'defaults write com.apple.mail EnableBundles -int 1'
@interface AveHookBootstrapper : NSObject

// we need these to be recognized as an MVMailBundle capable class
#pragma mark MVMailBundle class methods
+ (BOOL)hasPreferencesPanel;
+ (NSString*)preferencesOwnerClassName;
+ (NSString*)preferencesPanelName;

@end
