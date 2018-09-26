#import "NSExceptionCatcher.h"

@implementation NSExceptionCatcher
    
+ (void) try: (void (^)(void))try catch: (void (^)(NSException *))catch finally: (void (^)(void))finally {
    @try {
        if (try != NULL) try();
    }
    @catch (NSException *exception) {
        if (catch != NULL) catch(exception);
    }
    @finally {
        if (finally != NULL) finally();
    }
}
    
@end
