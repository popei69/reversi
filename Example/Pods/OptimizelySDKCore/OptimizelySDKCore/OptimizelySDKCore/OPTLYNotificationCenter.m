/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

#import "OPTLYNotificationCenter.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYLogger.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"
#import <objc/runtime.h>

@interface OPTLYNotificationCenter()

// Associative array of notification type to notification id and notification pair.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, OPTLYNotificationHolder *> *notifications;
@property (nonatomic, strong) OPTLYProjectConfig *config;

@end

@implementation OPTLYNotificationCenter : NSObject

-(instancetype)initWithProjectConfig:(OPTLYProjectConfig *)config {
    self = [super init];
    if (self != nil) {
        _notificationId = 1;
        _config = config;
        _notifications = [NSMutableDictionary new];
        for (NSUInteger i = OPTLYNotificationTypeActivate; i <= OPTLYNotificationTypeTrack; i++) {
            NSNumber *number = [NSNumber numberWithUnsignedInteger:i];
            _notifications[number] = [NSMutableDictionary new];
        }
    }
    return self;
}

#pragma mark - Public Methods

-(NSUInteger)notificationsCount {
    NSUInteger notificationsCount = 0;
    for (OPTLYNotificationHolder *notificationsMap in _notifications.allValues) {
        notificationsCount += notificationsMap.count;
    }
    return notificationsCount;
}

- (NSInteger)addActivateNotificationListener:(ActivateListener)activateListener {
    return [self addNotification:OPTLYNotificationTypeActivate listener:(GenericListener) activateListener];
}

- (NSInteger)addTrackNotificationListener:(TrackListener)trackListener {
    return [self addNotification:OPTLYNotificationTypeTrack listener:(GenericListener)trackListener];
}

- (BOOL)removeNotificationListener:(NSUInteger)notificationId {
    for (NSNumber *notificationType in _notifications.allKeys) {
        OPTLYNotificationHolder *notificationMap = _notifications[notificationType];
        if (notificationMap != nil && [notificationMap.allKeys containsObject:@(notificationId)]) {
            [notificationMap removeObjectForKey:@(notificationId)];
            return YES;
        }
    }
    return NO;
}

- (void)clearNotificationListeners:(OPTLYNotificationType)type {
    [_notifications[@(type)] removeAllObjects];
}

- (void)clearAllNotificationListeners {
    for (NSNumber *notificationType in _notifications.allKeys) {
        [self clearNotificationListeners:[notificationType unsignedIntegerValue]];
    }
}

- (void)sendNotifications:(OPTLYNotificationType)type args:(NSArray *)args {
    OPTLYNotificationHolder *notification = _notifications[@(type)];
    for (GenericListener listener in notification.allValues) {
        @try {
            switch (type) {
                case OPTLYNotificationTypeActivate:
                    [self notifyActivateListener:((ActivateListener) listener) args:args];
                    break;
                case OPTLYNotificationTypeTrack:
                    [self notifyTrackListener:((TrackListener) listener) args:args];
                    break;
                default:
                    listener(args);
            }
        } @catch (NSException *exception) {
            NSString *logMessage = [NSString stringWithFormat:@"Problem calling notify callback. Error: %@", exception.reason];
            [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        }
    }
}

#pragma mark - Private Methods

- (NSInteger)addNotification:(OPTLYNotificationType)type listener:(GenericListener)listener {
    NSNumber *notificationTypeNumber = [NSNumber numberWithUnsignedInteger:type];
    NSNumber *notificationIdNumber = [NSNumber numberWithUnsignedInteger:_notificationId];
    OPTLYNotificationHolder *notificationHoldersList = _notifications[notificationTypeNumber];
    
    if (![_notifications.allKeys containsObject:notificationTypeNumber] || notificationHoldersList.count == 0) {
        notificationHoldersList[notificationIdNumber] = listener;
    } else {
        for (GenericListener notificationListener in notificationHoldersList.allValues) {
            if (notificationListener == listener) {
                [_config.logger logMessage:@"The notification callback already exists." withLevel:OptimizelyLogLevelError];
                return -1;
            }
        }
        notificationHoldersList[notificationIdNumber] = listener;
    }
    
    return _notificationId++;
}

- (void)notifyActivateListener:(ActivateListener)listener args:(NSArray *)args {
    
    if(args.count < 5) {
        NSString *logMessage = [NSString stringWithFormat:@"Not enough arguments to call %@ for notification callback.", listener];
        [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return; // Not enough arguments in the array
    }
    
    OPTLYExperiment *experiment = (OPTLYExperiment *)args[0];
    assert(experiment);
    assert([experiment isKindOfClass:[OPTLYExperiment class]]);
    
    NSString *userId = (NSString *)args[1];
    assert(userId);
    assert([userId isKindOfClass:[NSString class]]);
    
    NSDictionary *attributes = (NSDictionary *)args[2];
    assert(attributes);
    assert([attributes isKindOfClass:[NSDictionary class]]);
    
    OPTLYVariation *variation = (OPTLYVariation *)args[3];
    assert(variation);
    assert([variation isKindOfClass:[OPTLYVariation class]]);
    
    NSDictionary *logEvent = (NSDictionary *)args[4];
    assert(logEvent);
    assert([logEvent isKindOfClass:[NSDictionary class]]);
    
    listener(experiment, userId, attributes, variation, logEvent);
}

- (void)notifyTrackListener:(TrackListener)listener args:(NSArray *)args {
    
    if(args.count < 5) {
        NSString *logMessage = [NSString stringWithFormat:@"Not enough arguments to call %@ for notification callback.", listener];
        [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return; // Not enough arguments in the array
    }
    
    NSString *eventKey = (NSString *)args[0];
    assert(eventKey);
    assert([eventKey isKindOfClass:[NSString class]]);
    
    NSString *userId = (NSString *)args[1];
    assert(userId);
    assert([userId isKindOfClass:[NSString class]]);
    
    NSDictionary *attributes = (NSDictionary *)args[2];
    assert(attributes);
    assert([attributes isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *eventTags = (NSDictionary *)args[3];
    assert(eventTags);
    assert([eventTags isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *logEvent = (NSDictionary *)args[4];
    assert(logEvent);
    assert([logEvent isKindOfClass:[NSDictionary class]]);
    
    listener(eventKey, userId, attributes, eventTags, logEvent);
}

@end
