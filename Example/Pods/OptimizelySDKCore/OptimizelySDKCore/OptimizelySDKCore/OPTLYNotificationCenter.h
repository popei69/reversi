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

#import <Foundation/Foundation.h>

@class OPTLYProjectConfig, OPTLYExperiment, OPTLYVariation;

/// Enum representing notification types.
typedef NS_ENUM(NSUInteger, OPTLYNotificationType) {
    OPTLYNotificationTypeActivate,
    OPTLYNotificationTypeTrack
};

typedef void (^ActivateListener)(OPTLYExperiment * _Nonnull experiment,
                                 NSString * _Nonnull userId,
                                 NSDictionary<NSString *,NSString *> * _Nonnull attributes,
                                 OPTLYVariation * _Nonnull variation,
                                 NSDictionary<NSString *,NSObject *> * _Nonnull event);

typedef void (^TrackListener)(NSString * _Nonnull eventKey,
                              NSString * _Nonnull userId,
                              NSDictionary<NSString *,NSString *> * _Nonnull attributes,
                              NSDictionary * _Nonnull eventTags,
                              NSDictionary<NSString *,NSObject *> * _Nonnull event);

typedef void (^GenericListener)(NSArray * _Nonnull args);

typedef NSMutableDictionary<NSNumber *, GenericListener > OPTLYNotificationHolder;

@interface OPTLYNotificationCenter : NSObject

// Notification Id represeting id of notification.
@property (nonatomic, readonly) NSUInteger notificationId;

/**
 * Initializer for the Notification Center.
 *
 * @param config The project configuration.
 * @return An instance of the notification center.
 */
- (nullable instancetype)initWithProjectConfig:(nonnull OPTLYProjectConfig *)config;

/**
 * Add an activate notification listener to the notification center.
 *
 * @param activateListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addActivateNotificationListener:(nonnull ActivateListener)activateListener;

/**
 * Add a track notification listener to the notification center.
 *
 * @param trackListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addTrackNotificationListener:(TrackListener _Nonnull )trackListener;

/**
 * Remove the notification listener based on the notificationId passed back from addNotification.
 * @param notificationId the id passed back from add notification.
 * @return true if removed otherwise false (if the notification is already removed, it returns false).
 */
- (BOOL)removeNotificationListener:(NSUInteger)notificationId;

/**
 * Clear notification listeners by notification type.
 * @param type type of OPTLYNotificationType to remove.
 */
- (void)clearNotificationListeners:(OPTLYNotificationType)type;

/**
 * Clear out all the notification listeners.
 */
- (void)clearAllNotificationListeners;

//
/**
 * fire notificaitons of a certain type.
 * @param type type of OPTLYNotificationType to fire.
 * @param args The arg list changes depending on the type of notification sent.
 */
- (void)sendNotifications:(OPTLYNotificationType)type args:(nullable NSArray *)args;
@end
