//
//  PositionPatternTests.m
//  Igor
//
//  Created by Luke Redpath on 14/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DEIgor.h"
#import "ViewFactory.h"

@interface PositionPatternTests : SenTestCase
@end

@implementation PositionPatternTests {
  DEIgor *igor;
  UIView *root;
}

- (void)setUp
{
  igor = [DEIgor igor];
  root = [ViewFactory viewWithName:@"root"];
}

- (void)testFirstChildSelectsViewThatIsFirstChildOfItsSuperview
{
  UIView *superview = [ViewFactory viewWithName:@"superview"];
  UIView *firstChild = [ViewFactory viewWithName:@"child-1"];
  
  [superview addSubview:firstChild];
  [superview addSubview:[ViewFactory viewWithName:@"child-2"]];
  [superview addSubview:[ViewFactory viewWithName:@"child-3"]];
  [root addSubview:superview];
  
  @try {
    NSArray *matchingViews = [igor findViewsThatMatchQuery:@"UIView:first-child" inTree:root];
    
    assertThat(matchingViews, hasCountOf(1));
    assertThat(matchingViews, hasItem(firstChild));
  }
  @catch (NSException *exception) {
    STFail(@"Failed with exception: %@", exception);
  }
}

@end
