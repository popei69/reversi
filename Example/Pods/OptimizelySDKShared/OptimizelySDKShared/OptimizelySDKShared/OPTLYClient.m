/****************************************************************************
 * Copyright 2016, 2018, Optimizely, Inc. and contributors                  *
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

#import "OPTLYClient.h"
#ifdef UNIVERSAL
    #import "OPTLYVariation.h"
    #import "OPTLYLogger.h"
    #import "OPTLYLoggerMessages.h"
#else
    #import <OptimizelySDKCore/OPTLYVariation.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#endif


/**
 * This class wraps the Optimizely class from the Core SDK.
 * Optimizely Client Instance
 */
@implementation OPTLYClient

+ (nonnull instancetype)init:(OPTLYClientBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:builderBlock]];
}

- (nonnull instancetype)init {
    return [self initWithBuilder:nil];
}

- (nonnull instancetype)initWithBuilder:(nullable OPTLYClientBuilder *)builder {
    self = [super init];
    if (self) {
        if (builder != nil) {
            _optimizely = builder.optimizely;
            if (builder.logger != nil) {
                _logger = builder.logger;
            }
        }
    }
    return self;
}

-(nullable OPTLYNotificationCenter *)notificationCenter {
    return self.optimizely.notificationCenter;
}

#pragma mark activate methods
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                      userId:(nonnull NSString *)userId {
    return [self activate:experimentKey userId:userId attributes:nil];
}

- (nullable OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely activate:experimentKey
                                  userId:userId
                              attributes:attributes];
    }
}

#pragma mark getVariation methods
- (nullable OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId {
    return [self variation:experimentKey
                    userId:userId
                attributes:nil];
}

- (nullable OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId
                   attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely variation:experimentKey
                                   userId:userId
                               attributes:attributes];
    }
}

#pragma mark Forced Variation Methods

- (nullable OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getForcedVariation:experimentKey
                                            userId:userId];
    }
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return NO;
    }
    else {
        return [self.optimizely setForcedVariation:experimentKey
                                            userId:userId
                                      variationKey:variationKey];
    }
}

#pragma mark Forced Variation Methods

- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey
                  userId:(nullable NSString *)userId
              attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    else {
        return [self.optimizely isFeatureEnabled:featureKey userId:userId attributes:attributes];
    }
}

-(NSNumber *)getFeatureVariableBoolean:(NSString *)featureKey
                     variableKey:(NSString *)variableKey
                          userId:(NSString *)userId
                      attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getFeatureVariableBoolean:featureKey
                                              variableKey:variableKey
                                                   userId:userId
                                               attributes:attributes];
    }
}

- (NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getFeatureVariableDouble:featureKey
                                             variableKey:variableKey
                                                  userId:userId
                                              attributes:attributes];
    }
}


- (NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getFeatureVariableInteger:featureKey
                                              variableKey:variableKey
                                                   userId:userId
                                               attributes:attributes];
    }
}
    
- (NSArray<NSString *> *)getEnabledFeatures:(nullable NSString *)userId
               attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return [NSArray new];
    }
    else {
        return [self.optimizely getEnabledFeatures:userId
                                        attributes:attributes];
    }
}


- (NSString * _Nullable)getFeatureVariableString:(nullable NSString *)featureKey
                                     variableKey:(nullable NSString *)variableKey
                                          userId:(nullable NSString *)userId
                                      attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getFeatureVariableString:featureKey
                                             variableKey:variableKey
                                                  userId:userId
                                              attributes:attributes];
    }
}

#pragma mark trackEvent methods
- (void)track:(NSString *)eventKey userId:(NSString *)userId {
    [self track:eventKey userId:userId attributes:nil eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, NSString *> * )attributes {
    [self track:eventKey userId:userId attributes:attributes eventTags:nil];
}

- (void)track:(NSString *)eventKey
      userId:(NSString *)userId
   eventTags:(NSDictionary<NSString *,id> *)eventTags {
    [self track:eventKey userId:userId attributes:nil eventTags:eventTags];
}

- (void)track:(NSString *)eventKey
      userId:(NSString *)userId
  attributes:(NSDictionary<NSString *,NSString *> *)attributes
   eventTags:(NSDictionary<NSString *,id> *)eventTags {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return;
    }
    [self.optimizely track:eventKey
                    userId:userId
                attributes:attributes
                 eventTags:eventTags];
}

#pragma mark - Live variable getters (DEPRECATED)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                   activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                        activateExperiment:activateExperiment];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                                error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment
                                     error:error];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
     activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                         activateExperiment:activateExperiment];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment
                  error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment
                                      error:error];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
          activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                         activateExperiment:activateExperiment];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment
                       error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment
                                      error:error];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
      activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                        activateExperiment:activateExperiment];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment
                   error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment
                                     error:error];
}
#pragma GCC diagnostic pop // "-Wdeprecated-declarations" "-Wdeprecated-implementations"

#pragma mark - description

- (NSString *)description {
    return [NSString stringWithFormat:@"Optimizely: %@ \nlogger:%@\n", self.optimizely, self.logger];
}

@end
