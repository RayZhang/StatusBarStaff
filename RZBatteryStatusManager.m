//
//  RZBatteryStatusManager.m
//  RZBatteryStatus
//
//  Created by Ray Zhang on 13-4-27.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//

#import "RZBatteryStatusManager.h"
#import "UIStatusBarBatteryItemView.h"
#import "UIStatusBar.h"

#define BATTERY_LEVEL_KEYPATH @"batteryLevel"
#define SpringBoardFullyChargedNotification CFSTR("com.apple.springboard.fullycharged")

@interface RZBatteryStatusManager ()

@property (nonatomic, retain) NSNumber *batteryLevel;

- (void)updateBatteryLevel;

@end

static void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (CFStringCompare(name, SpringBoardFullyChargedNotification, kCFCompareAnchored) == kCFCompareEqualTo) {
        [(RZBatteryStatusManager *)observer updateBatteryLevel];
    }
}

static RZBatteryStatusManager *manager = nil;

@implementation RZBatteryStatusManager

+ (id)sharedManager {
    @synchronized(self) {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    }
    return manager;
}

+ (id)activeManager {
    return manager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (manager == nil) {
            manager = [super allocWithZone:zone];
            return manager;
        }
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self updateBatteryLevel]; // initialize battery leve
        
        // add observer to battery level;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, callBack, SpringBoardFullyChargedNotification, NULL, CFNotificationSuspensionBehaviorDrop);
        [self addObserver:self forKeyPath:BATTERY_LEVEL_KEYPATH options:NSKeyValueObservingOptionNew context:NULL];
        
        _batteryState = [[UIDevice currentDevice] batteryState]; // initialize battery state
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryState) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [_batteryLevel release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, SpringBoardFullyChargedNotification, NULL);
    [super dealloc];
}

- (id)retain {
    return self;
}

- (oneway void)release {
    return;
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

#pragma mark - Key Value Observing Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:BATTERY_LEVEL_KEYPATH]) {
        NSInteger newValue = [[change objectForKey:@"new"] integerValue];
        if (_batteryCapacityLevel != newValue) {
            _batteryCapacityLevel = newValue;
            if ([_delegate respondsToSelector:@selector(batteryCapacityLevelChanged:)]) {
                [_delegate batteryCapacityLevelChanged:newValue];
            }
        }
    }
}

#pragma mark - Custom Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateBatteryLevel {
    UIStatusBar *statusBar = [[UIApplication sharedApplication] valueForKey:@"_statusBar"];
    if (statusBar) {
        UIStatusBarForegroundView *foregroundView = [statusBar valueForKey:@"_foregroundView"];
        NSArray *foregroundSubviews = [foregroundView subviews];
        for (UIStatusBarItemView *itemView in foregroundSubviews) {
            if ([itemView isMemberOfClass:NSClassFromString(@"UIStatusBarBatteryItemView")]) {
                self.batteryLevel = [itemView valueForKey:@"_capacity"];
                break;
            }
        }
    } else {
        NSUInteger batteryLevel = [[UIDevice currentDevice] batteryLevel] * 100;
        self.batteryLevel = [NSNumber numberWithInteger:batteryLevel];
    }
}

- (void)updateBatteryState {
    UIDeviceBatteryState deviceBatteryState = [[UIDevice currentDevice] batteryState];
    if (_batteryState != deviceBatteryState) {
        _batteryState = deviceBatteryState;
        if ([_delegate respondsToSelector:@selector(batteryStateChanged:)]) {
            [_delegate batteryStateChanged:deviceBatteryState];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
