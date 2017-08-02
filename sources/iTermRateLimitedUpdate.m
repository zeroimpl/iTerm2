//
//  iTermRateLimitedUpdate.m
//  iTerm2
//
//  Created by George Nachman on 6/17/17.
//
//

#import "iTermRateLimitedUpdate.h"
#import "NSTimer+iTerm.h"

@implementation iTermRateLimitedUpdate {
    // While nonnil, block will not be performed.
    NSTimer *_timer;
    void (^_block)();
}

- (void)invalidate {
    [_timer invalidate];
    _timer = nil;
    _block = nil;
}

- (void)performRateLimitedBlock:(void (^)())block {
    if (_timer == nil) {
        block();
        _timer = [NSTimer it_weakTimerWithTimeInterval:self.minimumInterval
                                               repeats:NO
                                                target:self
                                              selector:@selector(performBlockIfNeeded:)];
    } else {
        _block = [block copy];
    }
}

- (void)performRateLimitedSelector:(SEL)selector
                          onTarget:(id)target
                        withObject:(id)object {
    __weak id weakTarget = target;
    [self performRateLimitedBlock:^{
        id strongTarget = weakTarget;
        if (strongTarget) {
            void (*func)(id, SEL, NSTimer *) = (void *)[weakTarget methodForSelector:selector];
            func(weakTarget, selector, object);
        }
    }];
}

- (void)performBlockIfNeeded:(NSTimer *)timer {
    _timer = nil;
    if (_block != nil) {
        void (^block)() = _block;
        _block = nil;
        block();
    }
}

@end
