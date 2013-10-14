#import "DEIgor.h"

@protocol SelectorEngine
- (NSArray *)selectViewsWithSelector:(NSString *)query;
@end

@interface SelectorEngineRegistry
+(void)registerSelectorEngine:(id <SelectorEngine>)engine WithName:(NSString *)name;
@end

@interface UIApplication (FEXWindows)
- (NSArray *)FEX_windows;
@end

@interface DEIgorSelfRegisteringSelectorEngine : NSObject <SelectorEngine>
@end

@implementation DEIgorSelfRegisteringSelectorEngine {
    DEIgor *_igor;
}

+ (void)applicationDidBecomeActive:(NSNotification *)notification {
    [SelectorEngineRegistry registerSelectorEngine:[[DEIgorSelfRegisteringSelectorEngine alloc] initWithIgor:[DEIgor igor]] WithName:@"igor"];
    NSLog(@"Igor 0.5.0 registered with Frank as selector engine named 'igor'");
}

- (id)initWithIgor:(DEIgor *)igor {
    self = [super init];
    if (self) {
        _igor = igor;
    }
    return self;
}

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:@"UIApplicationDidBecomeActiveNotification"
                                               object:nil];
}

- (NSArray *)selectViewsWithSelector:(NSString *)query {
  NSArray *foundViews;
  UIApplication *application = [UIApplication sharedApplication];
  
  // check this exists so as not to break compatibility with old versions of Frank
  if ([application respondsToSelector:@selector(FEX_windows)]) {
    NSMutableArray *combinedResults = [NSMutableArray array];
    
    for (UIWindow *window in [application FEX_windows]) {
	    NSArray *results = [_igor findViewsThatMatchQuery:query inTree:window];
      [combinedResults addObjectsFromArray:results];
	  }
    foundViews = [combinedResults copy];
  }
  else {
    UIView *tree = [application keyWindow];
    foundViews = [_igor findViewsThatMatchQuery:query inTree:tree];
  }

  return foundViews;
}

@end
