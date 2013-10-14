#import "DEIgor.h"

@protocol SelectorEngine
- (NSArray *)selectViewsWithSelector:(NSString *)query;
- (NSArray *)selectViewsWithSelector:(NSString *)query inWindows:(NSArray *)windows;
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
  // the 'windows' method might not include all system windows, but is used for compatibility
  return [self selectViewsWithSelector:query inWindows:[[UIApplication sharedApplication] windows]];
}

- (NSArray *)selectViewsWithSelector:(NSString *)query inWindows:(NSArray *)windows
{
  NSMutableArray *combinedResults = [NSMutableArray array];
  
  for (UIWindow *window in windows) {
    NSArray *results = [_igor findViewsThatMatchQuery:query inTree:window];
    [combinedResults addObjectsFromArray:results];
  }
  return [combinedResults copy];
}

@end
