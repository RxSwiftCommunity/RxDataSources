#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSExceptionCatcher : NSObject
    
+ (void) try: (__attribute__((noescape)) void(^ _Nullable)(void))try catch: (__attribute__((noescape)) void(^ _Nullable)(NSException *exception))catch finally: (__attribute__((noescape)) void(^ _Nullable)(void))finally;
    
@end

NS_ASSUME_NONNULL_END
