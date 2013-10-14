//
//  SelectorEngineTests.m
//  Igor
//
//  Created by Luke Redpath on 14/10/2013.
//
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "ViewFactory.h"
#import "DEIgor.h"

@interface DEIgorSelfRegisteringSelectorEngine : NSObject
- (id)initWithIgor:(DEIgor *)igor;
- (NSArray *)selectViewsWithSelector:(NSString *)query;
@end

@interface UIApplication (WindowRegistration)

/* This method is implemented in Frank as a category and uses 
 * method swizzling to register all initialised windows in the app.
 *
 * This is a simpler implementation that allow for deterministic
 * registering of windows for testing purposes.
 */
- (NSArray *)FEX_windows;
- (void)FEX_registerWindow:(UIWindow *)window;

@end

@implementation UIApplication (WindowRegistration)

- (NSMutableArray *)FEX_registeredWindows
{
  NSMutableArray *registeredWindows = objc_getAssociatedObject(self, "FEX_registeredWindows");
  if (registeredWindows == nil) {
    registeredWindows = [[NSMutableArray alloc] init];
    objc_setAssociatedObject(self, "FEX_registeredWindows", registeredWindows, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return registeredWindows;
}

- (NSArray *)FEX_windows
{
  return [[self FEX_registeredWindows] copy];
}

- (void)FEX_registerWindow:(UIWindow *)window
{
  [[self FEX_registeredWindows] addObject:window];
}

@end

@interface SelectorEngineRegistry : NSObject
@end

// We need this to keep the compiler happy.
@implementation SelectorEngineRegistry
+ (void)registerSelectorEngine:(id)engine WithName:(NSString *)name
{}
@end

@interface SelectorEngineTests : XCTestCase
@end

@implementation SelectorEngineTests

- (void)testFindsViewsAcrossAllRegisteredWindows
{
  DEIgor *igor = [DEIgor igor];
  DEIgorSelfRegisteringSelectorEngine *engine = [[DEIgorSelfRegisteringSelectorEngine alloc] initWithIgor:igor];
  
  UIWindow *windowOne = [ViewFactory window];
  UIView *rootOne = [ViewFactory viewWithName:@"root"];
  UIView *middleOne = [ViewFactory viewWithName:@"middle"];
  [windowOne addSubview:rootOne];
  [rootOne addSubview:middleOne];
  
  UIWindow *windowTwo = [ViewFactory window];
  UIView *rootTwo = [ViewFactory viewWithName:@"root"];
  UIView *middleTwo = [ViewFactory viewWithName:@"middle"];
  [windowTwo addSubview:rootTwo];
  [rootTwo addSubview:middleTwo];
  
  UIApplication *application = [UIApplication sharedApplication];
  NSLog(@"Windows %@", [application FEX_windows]);
  [application FEX_registerWindow:windowOne];
  [application FEX_registerWindow:windowTwo];
  NSLog(@"Windows %@", [application FEX_windows]);
  
  NSArray *matchingViews = [engine selectViewsWithSelector:@"#root > #middle"];
  assertThat(matchingViews, containsInAnyOrder(middleOne, middleTwo, nil));
}

@end
