//
//  AveHookBootstrapper.m
//  AveNoAnimationsInMailPlugin
//
//  Created by Andreas Verhoeven on 24-10-13.
//  Copyright (c) 2013 AveApps. All rights reserved.
//

#import "AveHookBootstrapper.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation AveHookBootstrapper

static BOOL elCapitanOverrideTransactionDurationToZero = NO;

+(BOOL)isAtLeastElCapitan
{
    static BOOL isAtLeastElCapitan = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSProcessInfo* processInfo = [NSProcessInfo processInfo];
        if([processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
        {
            NSOperatingSystemVersion version = {0};
            version.majorVersion = 10;
            version.minorVersion = 11; // el cap
            isAtLeastElCapitan = [processInfo isOperatingSystemAtLeastVersion:version];
        }
    });
    
    return isAtLeastElCapitan;
}


+(BOOL)isAtLeastSierra
{
	static BOOL isAtLeastSierra = NO;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSProcessInfo* processInfo = [NSProcessInfo processInfo];
		if([processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
		{
			NSOperatingSystemVersion version = {0};
			version.majorVersion = 10;
			version.minorVersion = 12; // sierra
			isAtLeastSierra = [processInfo isOperatingSystemAtLeastVersion:version];
		}
	});
	
	return isAtLeastSierra;
}

static IMP AveReplaceMethod(Class class, BOOL isMetaClass, SEL sel, id block) {
    
    NSString* printableMethodDescription = [NSString stringWithFormat:@"%@[%@ %@]", isMetaClass ? @"+" : @"-", NSStringFromClass(class), NSStringFromSelector(sel)];
    
    // get original method
    Method method = class_getInstanceMethod(class, sel);
    if(method == nil)
    {
        NSLog(@"Ave: Method not found %@", printableMethodDescription);
    }
    
    NSLog(@"Ave: %@ -> %s", printableMethodDescription, method_getTypeEncoding(method));
    
    IMP newIMP = imp_implementationWithBlock(block);
    
    if(class_addMethod(class, sel, newIMP, method_getTypeEncoding(method)))
    {
        NSLog(@"Ave: Added %@", printableMethodDescription);
        return method_getImplementation(method);
    }
    else
    {
        NSLog(@"Ave: Replaced %@", printableMethodDescription);
        return method_setImplementation(method, newIMP);
    }
}

static IMP AveReplaceInstanceMethod(Class class, SEL sel, id block) {
    return AveReplaceMethod(class, NO, sel, block);
}

static IMP AveReplaceClassMethod(Class class, SEL sel, id block) {
    Class metaClass = object_getClass(class);
    return AveReplaceMethod(metaClass, YES, sel, block);
}

#pragma mark - El Capitan

+(void)aveElCapitanSwizzleCATransactionSetAnimationDuration
{
    Class class = [CATransaction class];
    SEL sel = @selector(setAnimationDuration:);
    __block IMP originalImplementation = AveReplaceClassMethod(class, sel, ^(id obj, NSTimeInterval duration){
        
        if([NSThread isMainThread] && elCapitanOverrideTransactionDurationToZero)
            duration = 0.01;
        
        if(originalImplementation != NULL)
        {
            ((void(*)(id, SEL, NSTimeInterval))originalImplementation)(obj, sel, duration);
        }
    });
}

+(void)aveElCapitanSwizzleNSAnimationContextSetDuration
{
    Class class = [NSAnimationContext class];
    SEL sel = @selector(setDuration:);
    __block IMP originalImplementation = AveReplaceInstanceMethod(class, sel, ^(id obj, NSTimeInterval duration){
        
        if([NSThread isMainThread] && elCapitanOverrideTransactionDurationToZero)
            duration = 0.0;
        
        if(originalImplementation != NULL)
        {
            ((void(*)(id, SEL, NSTimeInterval))originalImplementation)(obj, sel, duration);
        }
    });
}

+(void)aveElCapitanSwizzleComposeWindowControllerPerformSendAnimation
{
    Class class = NSClassFromString(@"ComposeWindowController");
    SEL sel = @selector(_performSendAnimation);
    __block IMP originalImplementation = AveReplaceInstanceMethod(class, sel, ^(id obj){
        elCapitanOverrideTransactionDurationToZero = YES;
        if(originalImplementation != NULL)
        {
            ((void(*)(id, SEL))originalImplementation)(obj, sel);
        }
        
        elCapitanOverrideTransactionDurationToZero = NO;
    });
}

// -[ComposeWindowController _performSendAnimationWithCompletion:](void * self, void * _cmd, void * arg2) {
+(void)aveSierraSwizzleComposeWindowControllerPerformSendAnimationWithCompletion
{
	Class class = NSClassFromString(@"ComposeWindowController");
	SEL sel = @selector(_performSendAnimationWithCompletion:);
	__block IMP originalImplementation = AveReplaceInstanceMethod(class, sel, ^(id obj, id block){
		elCapitanOverrideTransactionDurationToZero = YES;
		if(originalImplementation != NULL)
		{
			((void(*)(id, SEL, id))originalImplementation)(obj, sel, block);
		}
		
		elCapitanOverrideTransactionDurationToZero = NO;
	});
}

+(void)aveElCapitanSwizzlePopoutAnimationController_animateFrom_to_withCompletion
{
    Class class = NSClassFromString(@"PopoutAnimationController");
    SEL sel = @selector(animateFrom:to:withCompletion:);
    __block IMP originalImplementation = AveReplaceInstanceMethod(class, sel, ^(id obj, id from, id to, id completion){
        elCapitanOverrideTransactionDurationToZero = YES;
        if(originalImplementation != NULL)
        {
            ((void(*)(id, SEL, id, id, id))originalImplementation)(obj, sel, from, to, completion);
        }
        
        elCapitanOverrideTransactionDurationToZero = NO;
    });
}

+(void)aveElCapitanswizzlePopoutAnimationController_internalTransitionAnimationWithDestination_fadeOut
{
    Class class = NSClassFromString(@"PopoutAnimationController");
    SEL sel = @selector(_internalTransitionAnimationWithDestination:fadeOut:);
    /*__block IMP originalImplementation = */AveReplaceInstanceMethod(class, sel, ^id(id obj, CGRect rc, BOOL fadeOut){
        
        return nil;
        /*
        if(originalImplementation != NULL)
        {
            CAAnimationGroup* animationGroup = ((CAAnimationGroup*(*)(id, SEL, CGRect, BOOL))originalImplementation)(obj, sel, rc, fadeOut);
            return animationGroup;
        }
        */
    });
}

+(void)aveElCapitanSwizzleWindowTransformAnimation__animationDurationForAnimationType
{
    Class class = NSClassFromString(@"WindowTransformAnimation");
    SEL sel = @selector(_animationDurationForAnimationType:);
    AveReplaceInstanceMethod(class, sel, ^NSTimeInterval(id obj, NSInteger type){
        return 0.0;
    });
}

+(void)aveElCapitanSwizzleFullScreenWindowController_animateModalWindowClose
{
    Class class = NSClassFromString(@"FullScreenWindowController");
    SEL sel = @selector(_animateModalWindowClose:);
    __block IMP originalImplementation = AveReplaceInstanceMethod(class, sel, ^(id obj, id sender){
        elCapitanOverrideTransactionDurationToZero = YES;
        if(originalImplementation != NULL)
        {
            ((void(*)(id, SEL, id))originalImplementation)(obj, sel, sender);
        }
        
        elCapitanOverrideTransactionDurationToZero = NO;
    });
}


// ensure the selectors exist
-(CAAnimationGroup*)_internalTransitionAnimationWithDestination:(CGRect)rc fadeOut:(BOOL)fadeOut
{
    return nil;
}
-(void)animateFrom:(id)from to:(id)to withCompletion:(id)completion
{
}

-(NSTimeInterval)_animationDurationForAnimationType:(NSInteger)type
{
    return 0.0;
}

-(void)_animateModalWindowClose:(id)sender
{
}

#pragma mark - Mavericks and Yosemite

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
	NSLog(@"Ave: Swizzle %@ shouldDoPopOutAnimation: %p -> %p", class, orig, repl);
	method_exchangeImplementations(orig, repl);
}

#pragma mark


// use the same names as the method we swizzle, so the selectors exist
-(void)_performSendAnimation
{
	// will call -[DocumentEditor _sendAnimationCompleted], due to this method being
	// swizzled
	if([self respondsToSelector:@selector(_sendAnimationCompleted)])
	{
		[self _sendAnimationCompleted];
	}
}

- (void)_performSendAnimationWithCompletion:(id)block
{
	NSLog(@"Ave _performSendAnimationWithCompletion: should not be called in our class!");
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
	if(nil == orig || nil == class)
	{
		class = NSClassFromString(@"ComposeWindowController");
		orig = class_getInstanceMethod(class, @selector(_performSendAnimation));
	}
	
	Method repl = class_getInstanceMethod(self, @selector(_performSendAnimation));
	NSLog(@"Ave: Swizzle %@ _performSendAnimation: %p -> %p", class, orig, repl);
	method_exchangeImplementations(orig, repl);
}

#pragma mark - WindowTransformAnimation (Fullscreen animations)

-(NSTimeInterval)duration
{
	return 0.0; // the animation should end immediately
}

+(void)aveSwizzleWindowTransformAnimation
{
	// Swizzle Mail.app's -[WindowTransformAnimation duration] to be a very short animation, so
	// the animation is not noticavle. this is for fullscreen window animations
	Class class = NSClassFromString(@"WindowTransformAnimation");
	Method orig = class_getInstanceMethod(class, @selector(duration));
	Method repl = class_getInstanceMethod(self, @selector(duration));
	NSLog(@"Ave: Swizzle addMethod [WindowTransformAnimation duration]: %p -> %p", orig, repl);
	
	class_addMethod(class, @selector(duration), method_getImplementation(repl), method_getTypeEncoding(repl));
}

#pragma mark - bootstrap

+(void)load
{
	NSLog(@"Ave: Loaded, time to start swizzling");
	
    if([self isAtLeastElCapitan])
    {
        [self aveElCapitanSwizzleCATransactionSetAnimationDuration];
        [self aveElCapitanSwizzleNSAnimationContextSetDuration];
        [self aveElCapitanSwizzleComposeWindowControllerPerformSendAnimation];
        [self aveElCapitanSwizzlePopoutAnimationController_animateFrom_to_withCompletion];
        [self aveElCapitanswizzlePopoutAnimationController_internalTransitionAnimationWithDestination_fadeOut];
        [self aveElCapitanSwizzleWindowTransformAnimation__animationDurationForAnimationType];
        [self aveElCapitanSwizzleFullScreenWindowController_animateModalWindowClose];
		
		if([self isAtLeastSierra])
		{
			[self aveSierraSwizzleComposeWindowControllerPerformSendAnimationWithCompletion];
		}
    }
    else
    {
        [self aveSwizzlePopoutAnimation];
        [self swizzlePerformSendAnimation];
        [self aveSwizzleWindowTransformAnimation];
    }
	
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
