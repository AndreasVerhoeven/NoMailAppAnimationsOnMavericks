//
//  AveHookBootstrapper.m
//  AveNoAnimationsInMailPlugin
//
//  Created by Andreas Verhoeven on 24-10-13.
//  Copyright (c) 2013 AveApps. All rights reserved.
//

#import "AveHookBootstrapper.h"
#import <objc/runtime.h>

@implementation AveHookBootstrapper

#pragma mark shouldDoPopOutAnimation

// use the same names as the method we swizzle, so the selectors exist
-(BOOL)shouldDoPopOutAnimation
{
	return NO;
}

+(void)aveSwizzlePopoutAnimation
{
	// Swizzle Mail.app's -[DocumentEditor shouldDoPopOutAnimation] to always return NO
	Class class = NSClassFromString(@"DocumentEditor");
	Method orig = class_getInstanceMethod(class, @selector(shouldDoPopOutAnimation));
	Method repl = class_getInstanceMethod(self, @selector(shouldDoPopOutAnimation));
	NSLog(@"Ave: Swizzle shouldDoPopOutAnimation: %p -> %p", orig, repl);
	method_exchangeImplementations(orig, repl);
}

#pragma mark


// use the same names as the method we swizzle, so the selectors exist
-(void)_performSendAnimation
{
	// will call -[DocumentEditor _sendAnimationCompleted], due to this method being
	// swizzled
	[self _sendAnimationCompleted];
}

// this will never be called, but we define it so we can call it in the swizzled
// method _performSendAnimation in this class. However, _performSendAnimation will
// only be called in the context of DocumentEditor, so -[DocumentEditor _sendAnimationCompleted]
// will be called instead.
-(void)_sendAnimationCompleted
{
	NSLog(@"Ave: _sendAnimationCompleted should not be called in our class!");
}

+(void)swizzlePerformSendAnimation
{
	// Swizzle Mail.app's -[DocumentEditor _performSendAnimation] to directly invoke
	// -[DocumentEditor _sendAnimationCompleted]
	Class class = NSClassFromString(@"DocumentEditor");
	Method orig = class_getInstanceMethod(class, @selector(_performSendAnimation));
	Method repl = class_getInstanceMethod(self, @selector(_performSendAnimation));
	NSLog(@"Ave: Swizzle _performSendAnimation: %p -> %p", orig, repl);
	method_exchangeImplementations(orig, repl);
}

+(void)load
{
	NSLog(@"Ave: Loaded, time to start swizzling");
	[self aveSwizzlePopoutAnimation];
	[self swizzlePerformSendAnimation];
}

#pragma mark MVMailBundle class methods
+(BOOL)hasPreferencesPanel
{
	return NO;
}

+(NSString*)preferencesOwnerClassName
{
	return nil;
}

+(NSString*)preferencesPanelName
{
	return nil;
}

@end
