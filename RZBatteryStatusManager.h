//
//  RZBatteryStatusManager.h
//  RZBatteryStatus
//
//  Created by Ray Zhang on 13-4-27.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//

@protocol RZBatteryStatusManagerDelegate;

@interface RZBatteryStatusManager : NSObject

+ (id)sharedManager;

@property (nonatomic, assign) id <RZBatteryStatusManagerDelegate> delegate;

@property (nonatomic, readonly) NSInteger batteryCapacityLevel; // get current battery capacity [0, 100]
@property (nonatomic, readonly) UIDeviceBatteryState batteryState;

@end

@protocol RZBatteryStatusManagerDelegate <NSObject>

- (void)batteryCapacityLevelChanged:(NSUInteger)currentLevel;
- (void)batteryStateChanged:(UIDeviceBatteryState)currentState;

@end
