//
//  CompoundSelector.h
//  igor
//
//  Created by Dale Emery on 11/18/11.
//  Copyright (c) 2011 Dale H. Emery. All rights reserved.
//

#import "Matcher.h"

@interface NodeMatcher : NSObject<Matcher>

@property(retain) NSMutableArray* simpleMatchers;

+(NodeMatcher*) withClassMatcher:(id<Matcher>)classmatcher predicateMatcher:(id<Matcher>)predicateMatcher;

@end