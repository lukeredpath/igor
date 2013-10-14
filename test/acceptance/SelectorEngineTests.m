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
- (NSArray *)selectViewsWithSelector:(NSString *)query inWindows:(NSArray *)windows;
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

- (void)testFindsViewsAcrossAllGivenWindows
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
  
  NSArray *matchingViews = [engine selectViewsWithSelector:@"#root > #middle" inWindows:@[windowOne, windowTwo]];
  assertThat(matchingViews, containsInAnyOrder(middleOne, middleTwo, nil));
}

@end
