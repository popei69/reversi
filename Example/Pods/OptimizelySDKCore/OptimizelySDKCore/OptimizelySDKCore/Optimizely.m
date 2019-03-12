/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                   *
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

#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYDecisionService.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYVariableUsage.h"
#import "OPTLYNotificationCenter.h"

// (DEPRECATED)
#import "OPTLYVariable.h"
#import "OPTLYVariationVariable.h"

NSString *const OptimizelyNotificationsUserDictionaryExperimentKey = @"experiment";
NSString *const OptimizelyNotificationsUserDictionaryVariationKey = @"variation";
NSString *const OptimizelyNotificationsUserDictionaryUserIdKey = @"userId";
NSString *const OptimizelyNotificationsUserDictionaryAttributesKey = @"attributes";
NSString *const OptimizelyNotificationsUserDictionaryEventNameKey = @"eventKey";
NSString *const OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey = @"ExperimentVariationMapping";

@implementation Optimizely

+ (instancetype)init:(OPTLYBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYBuilder *)builder {
    self = [super init];
    if (self != nil) {
        if (builder != nil) {
            _bucketer = builder.bucketer;
            _decisionService = builder.decisionService;
            _config = builder.config;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _userProfileService = builder.userProfileService;
            _notificationCenter = builder.notificationCenter;
        } else {
            // Provided OPTLYBuilder object is invalid
            if (_logger == nil) {
                _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
            }
            NSString *logMessage = NSLocalizedString(OPTLYErrorHandlerMessagesBuilderInvalid, nil);
            [_logger logMessage:logMessage
                      withLevel:OptimizelyLogLevelError];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesBuilderInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : logMessage}];
            if (_errorHandler == nil) {
                _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
            }
            [_errorHandler handleError:error];
            self = nil;
        }
    }
    return self;
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId {
    return [self activate:experimentKey
                   userId:userId
               attributes:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
{
    return [self activate:experimentKey userId:userId attributes:attributes callback:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
                    callback:(void (^)(NSError *))callback {
    
    __weak void (^_callback)(NSError *) = callback ? : ^(NSError *error) {};
    
    if ([Optimizely isEmptyString:experimentKey]) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesActivateExperimentKeyEmpty ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    if ([Optimizely isEmptyString:userId]) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get experiment
    OPTLYExperiment *experiment = [self.config getExperimentForKey:experimentKey];
    
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivateExperimentKeyInvalid, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get variation
    OPTLYVariation *variation = [self variation:experimentKey userId:userId attributes:attributes];

    if (!variation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }
    
    // send impression event
    __weak typeof(self) weakSelf = self;
    OPTLYVariation *sentVariation = [self sendImpressionEventFor:experiment
                                                       variation:variation
                                                          userId:userId
                                                      attributes:attributes
                                                        callback:^(NSError *error) {
        if (error) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
            [weakSelf handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        }
        _callback(error);
    }];
    
    if (!sentVariation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }

    return variation;
}

#pragma mark getVariation methods
- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId {
    return [self variation:experimentKey
                    userId:userId
                attributes:nil];
}

- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId
                   attributes:(NSDictionary<NSString *,NSString *> *)attributes
{
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:experimentKey
                                                                        userId:userId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    return bucketedVariation;
}

#pragma mark Forced variation methods
- (OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    return [self.config getForcedVariation:experimentKey
                                    userId:userId];
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    return [self.config setForcedVariation:experimentKey
                                    userId:userId
                              variationKey:variationKey];
}

#pragma mark - Feature Flag Methods

- (BOOL)isFeatureEnabled:(NSString *)featureKey userId:(NSString *)userId attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    if ([Optimizely isEmptyString:userId]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureDisabledUserIdInvalid withLevel:OptimizelyLogLevelError];
        return false;
    }
    if ([Optimizely isEmptyString:featureKey]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid withLevel:OptimizelyLogLevelError];
        return false;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([Optimizely isEmptyString:featureFlag.key]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid withLevel:OptimizelyLogLevelError];
        return false;
    }
    if (![featureFlag isValid:self.config]) {
        return false;
    }
    
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    if (decision) {
        if ([decision.source isEqualToString:DecisionSourceExperiment]) {
            [self sendImpressionEventFor:decision.experiment variation:decision.variation userId:userId attributes:attributes callback:nil];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabledNotExperimented, userId, featureKey];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }

        if (decision.variation.featureEnabled) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabled, featureKey, userId];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            return true;
        }
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureDisabled, featureKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    return false;
}

- (NSString *)getFeatureVariableValueForType:(NSString *)variableType
                                  featureKey:(nullable NSString *)featureKey
                                 variableKey:(nullable NSString *)variableKey
                                      userId:(nullable NSString *)userId
                                  attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    if ([Optimizely isEmptyString:featureKey]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureVariableValueFlagKeyInvalid withLevel:OptimizelyLogLevelError];
        return nil;
    }
    if ([Optimizely isEmptyString:variableKey]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureVariableValueVariableKeyInvalid withLevel:OptimizelyLogLevelError];
        return nil;
    }
    if ([Optimizely isEmptyString:userId]) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureVariableValueUserIdInvalid withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([Optimizely isEmptyString:featureFlag.key]) {
        return nil;
    }
    
    OPTLYFeatureVariable *featureVariable = [featureFlag getFeatureVariableForKey:variableKey];
    if (!featureVariable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableInvalid, variableKey, featureKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    } else if (![featureVariable.type isEqualToString:variableType]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableTypeInvalid, featureVariable.type, variableType];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    NSString *variableValue = featureVariable.defaultValue;
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    if (decision) {
        OPTLYVariation *variation = decision.variation;
        OPTLYVariableUsage *featureVariableUsage = [variation getVariableUsageForVariableId:featureVariable.variableId];
        
        if (featureVariableUsage) {
            variableValue = featureVariableUsage.value;
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableType, variableValue, variation.variationKey, featureFlag.key];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotUsed, variableKey, variation.variationKey, variableValue];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
    } else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotBucketed, userId, featureFlag.key, variableValue];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    
    return variableValue;
}

- (NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeBoolean
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* booleanValue = nil;
    if (variableValue) {
        booleanValue = @([variableValue boolValue]);
    }
    return booleanValue;
}

- (NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeDouble
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* doubleValue = nil;
    if (variableValue) {
        doubleValue = @([variableValue doubleValue]);
    }
    return doubleValue;
}


- (NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeInteger
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* intValue = nil;
    if (variableValue) {
        intValue = @([variableValue intValue]);
    }
    return intValue;
}

- (NSString *)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes {
    return [self getFeatureVariableValueForType:FeatureVariableTypeString
                                     featureKey:featureKey
                                    variableKey:variableKey
                                         userId:userId
                                     attributes:attributes];
}
    
-(NSArray<NSString *> *)getEnabledFeatures:(NSString *)userId
                                attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    
    NSMutableArray<NSString *> *enabledFeatures = [NSMutableArray new];
    for (OPTLYFeatureFlag *feature in self.config.featureFlags) {
        NSString *featureKey = feature.key;
        if ([self isFeatureEnabled:featureKey userId:userId attributes:attributes]) {
            [enabledFeatures addObject:featureKey];
        }
    }
    return enabledFeatures;
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
    
    if ([Optimizely isEmptyString:eventKey]) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesTrackEventKeyEmpty ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    if ([Optimizely isEmptyString:userId]) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    OPTLYEvent *event = [self.config getEventForKey:eventKey];
    
    if (!event) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSArray *decisions = [self decisionsFor:event userId:userId attributes:attributes];
    
    if ([Optimizely isEmptyArray:decisions]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesConversionFailure, eventKey];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSDictionary *conversionEventParams = [self.eventBuilder buildConversionEventForUser:userId
                                                                                   event:event
                                                                               decisions:decisions
                                                                               eventTags:eventTags
                                                                              attributes:attributes];
    if ([Optimizely isEmptyDictionary:conversionEventParams]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, eventKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchConversionEvent:conversionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
                                                 [weakSelf handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
                                             } else {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherTrackingSuccess, eventKey, userId];
                                                 [weakSelf.logger logMessage:logMessage
                                                                     withLevel:OptimizelyLogLevelInfo];
                                             }
                                         }];
    
    NSArray *args = @[eventKey, userId ? : @"", attributes ? : [NSDictionary new], eventTags ? : [NSDictionary new], conversionEventParams];
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:args];
}

////////////////////////////////////////////////////////////////
//
//      Mobile 1.x Live Variables are DEPRECATED
//
// Optimizely Mobile 1.x Projects creating Mobile 1.x Experiments that
// contain Mobile 1.x Variables should migrate to Mobile 2.x Projects
// creating Mobile 2.x Experiments that utilize Optimizely Full Stack 2.0
// Feature Management which is more capable and powerful than Mobile 1.x
// Live Variables.  Please check Full Stack 2.0 Feature Management online
// at OPTIMIZELY.COM .
////////////////////////////////////////////////////////////////

#pragma mark - Live variable getters (DEPRECATED)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

/**
 * Finds experiment(s) that contain the live variable.
 * If live variable is in an experiment, it will be in all variations for that experiment.
 * Therefore, we only need to check the variables from the first variation in the array of variations for experiments.
 *
 * @param variableId ID of the live variable
 * @return Array of experiment key(s) that contain the live variable
 */
- (NSArray *)getExperimentKeysForLiveVariable:(NSString *)variableId
{
    NSArray *allExperiments = self.config.allExperiments;
    NSMutableArray *experimentsForLiveVariable = [NSMutableArray new];
    
    for (OPTLYExperiment *experiment in allExperiments) {
        OPTLYVariation *firstVariation = [experiment.variations objectAtIndex:0];
        NSArray *firstVariationVariables = firstVariation.variables;
        
        for (OPTLYVariationVariable *firstVariationVariable in firstVariationVariables) {
            NSString *firstVariationVariableId = firstVariationVariable.variableId;
            if ([firstVariationVariableId isEqualToString:variableId]) {
                NSString *experimentKey = experiment.experimentKey;
                [experimentsForLiveVariable addObject:experimentKey];
            }
        }
    }
    
    return experimentsForLiveVariable;
}

/**
 * Gets the stringified value of the live variable that is stored in the datafile.
 *
 * @param variableId ID of the live variable
 * @param variation Variation of the experiment that the user has been bucketed into
 * @return Stringified value of the variation's live variable
 */
- (NSString *)getValueForLiveVariable:(NSString *)variableId
                            variation:(OPTLYVariation *)variation {
    for (OPTLYVariationVariable *variable in variation.variables) {
        NSString *variationVariableId = variable.variableId;
        if ([variationVariableId isEqualToString:variableId]) {
            NSString *variableValue = variable.value;
            return variableValue;
        }
    }
    
    return nil;
}

- (nullable NSString *)variableString:(NSString *)variableKey
                               userId:(NSString *)userId {
    return [self variableString:variableKey
                         userId:userId
                     attributes:nil
             activateExperiment:NO
                          error:nil];
}

- (nullable NSString *)variableString:(NSString *)variableKey
                               userId:(NSString *)userId
                   activateExperiment:(BOOL)activateExperiment {
    return [self variableString:variableKey
                         userId:userId
                     attributes:nil
             activateExperiment:activateExperiment
                          error:nil];
}

- (nullable NSString *)variableString:(NSString *)variableKey
                               userId:(NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment {
    return [self variableString:variableKey
                         userId:userId
                     attributes:attributes
             activateExperiment:activateExperiment
                          error:nil];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                                error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self variableString:variableKey
                         userId:userId
                     attributes:attributes
             activateExperiment:activateExperiment
                       callback:^(NSError *e) {
                           if (error && e) {
                                *error = e;
                           }
                       }];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                             callback:(void (^)(NSError *))callback {
    [_logger logMessage:OPTLYLoggerMessagesLiveVariablesDeprecated
              withLevel:OptimizelyLogLevelWarning];
    OPTLYVariable *variable = [self.config getVariableForVariableKey:variableKey];
    
    if (!variable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey];
        [_logger logMessage:logMessage
                  withLevel:OptimizelyLogLevelError];
        
        NSError *variableUnknownForVariableKey = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                                     code:OPTLYLiveVariableErrorKeyUnknown
                                                                 userInfo:@{NSLocalizedDescriptionKey :
                                                                                [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesLiveVariableKeyUnknown, nil), variableKey]}];
    
        [self.errorHandler handleError:variableUnknownForVariableKey];
    
        if (callback) {
            callback(variableUnknownForVariableKey);
        }
        
        return nil;
    }
    
    NSString *variableId = variable.variableId;
    
    NSArray *experimentKeysForLiveVariable = [self getExperimentKeysForLiveVariable:variableId];
    
    if ([experimentKeysForLiveVariable count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNoExperimentsContainVariable, variableKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        
        if (callback) {
            callback(nil);
        }
        
        return variable.defaultValue;
    }
    
    for (NSString *experimentKey in experimentKeysForLiveVariable) {
        
        OPTLYVariation *variation = [self variation:experimentKey
                                             userId:userId
                                         attributes:attributes];
        
        
        if (variation) {
            NSString *valueForLiveVariable = [self getValueForLiveVariable:variableId variation:variation];
            
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariableValue, variableId, valueForLiveVariable];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            
            if (activateExperiment) {
                [self activate:experimentKey
                        userId:userId
                    attributes:attributes
                      callback:callback];
            } else {
                if (callback) {
                    callback(nil);
                }
            }
            
            return valueForLiveVariable;
        } else {
            // If user is not bucketed into experiment, then continue to another experiment
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable, userId, experimentKey, variableKey];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
    }
    
    if (callback) {
        callback(nil);
    }
    
    return variable.defaultValue;
}

- (BOOL)variableBoolean:(NSString *)variableKey
                 userId:(NSString *)userId {
    return [self variableBoolean:variableKey
                          userId:userId
                      attributes:nil
              activateExperiment:NO
                           error:nil];
}

- (BOOL)variableBoolean:(NSString *)variableKey
                 userId:(NSString *)userId
     activateExperiment:(BOOL)activateExperiment {
    return [self variableBoolean:variableKey
                          userId:userId
                      attributes:nil
              activateExperiment:activateExperiment
                           error:nil];
}

- (BOOL)variableBoolean:(NSString *)variableKey
                 userId:(NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment {
    return [self variableBoolean:variableKey
                          userId:userId
                      attributes:attributes
              activateExperiment:activateExperiment
                           error:nil];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment
                  error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    [_logger logMessage:OPTLYLoggerMessagesLiveVariablesDeprecated
              withLevel:OptimizelyLogLevelWarning];
    BOOL variableValue = false;
    NSString *variableValueStringOrNil = [self variableString:variableKey
                                                       userId:userId
                                                   attributes:attributes
                                           activateExperiment:activateExperiment
                                                        error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil boolValue];
    }
    
    return variableValue;
}

- (NSInteger)variableInteger:(NSString *)variableKey
                      userId:(NSString *)userId {
    return [self variableInteger:variableKey
                          userId:userId
                      attributes:nil
              activateExperiment:NO
                           error:nil];
}

- (NSInteger)variableInteger:(NSString *)variableKey
                      userId:(NSString *)userId
          activateExperiment:(BOOL)activateExperiment {
    return [self variableInteger:variableKey
                          userId:userId
                      attributes:nil
              activateExperiment:activateExperiment
                           error:nil];
}

- (NSInteger)variableInteger:(NSString *)variableKey
                      userId:(NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment {
    return [self variableInteger:variableKey
                          userId:userId
                      attributes:attributes
              activateExperiment:activateExperiment
                           error:nil];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment
                       error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    [_logger logMessage:OPTLYLoggerMessagesLiveVariablesDeprecated
              withLevel:OptimizelyLogLevelWarning];
    NSInteger variableValue = 0;
    NSString *variableValueStringOrNil = [self variableString:variableKey
                                                       userId:userId
                                                   attributes:attributes
                                           activateExperiment:activateExperiment
                                                        error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil intValue];
    }
    
    return variableValue;
}

- (double)variableDouble:(NSString *)variableKey
                  userId:(NSString *)userId {
    return [self variableDouble:variableKey
                         userId:userId
                     attributes:nil
             activateExperiment:NO
                          error:nil];
}

- (double)variableDouble:(NSString *)variableKey
                  userId:(NSString *)userId
      activateExperiment:(BOOL)activateExperiment {
    return [self variableDouble:variableKey
                         userId:userId
                     attributes:nil
             activateExperiment:activateExperiment
                          error:nil];
}

- (double)variableDouble:(NSString *)variableKey
                  userId:(NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment {
    return [self variableDouble:variableKey
                         userId:userId
                     attributes:attributes
             activateExperiment:activateExperiment
                          error:nil];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment
                   error:(out NSError * _Nullable __autoreleasing * _Nullable)error {
    [_logger logMessage:OPTLYLoggerMessagesLiveVariablesDeprecated
              withLevel:OptimizelyLogLevelWarning];
    double variableValue = 0.0;
    NSString *variableValueStringOrNil = [self variableString:variableKey
                                                       userId:userId
                                                   attributes:attributes
                                           activateExperiment:activateExperiment
                                                        error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil doubleValue];
    }
    
    return variableValue;
}

#pragma GCC diagnostic pop // "-Wdeprecated-declarations" "-Wdeprecated-implementations"

# pragma mark - Helper methods
// log and propagate error for a track failure
- (void)handleErrorLogsForTrack:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesEventTrack
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
}

// log and propagate error for a activate failure
- (NSError *)handleErrorLogsForActivate:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesUserActivate
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
    return error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"config:%@\nlogger:%@\nerrorHandler:%@\neventDispatcher:%@\nuserProfile:%@", self.config, self.logger, self.errorHandler, self.eventDispatcher, self.userProfileService];
}

- (OPTLYVariation *)sendImpressionEventFor:(OPTLYExperiment *)experiment
                                 variation:(OPTLYVariation *)variation
                                    userId:(NSString *)userId
                                attributes:(NSDictionary<NSString *,NSString *> *)attributes
                                  callback:(void (^)(NSError *))callback {
    
    // send impression event
    NSDictionary *impressionEventParams = [self.eventBuilder buildImpressionEventForUser:userId
                                                                              experiment:experiment
                                                                               variation:variation
                                                                              attributes:attributes];
    
    if ([Optimizely isEmptyDictionary:impressionEventParams]) {
        return nil;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent, userId, experiment.experimentKey];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchImpressionEvent:impressionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (!error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationSuccess, userId, experiment.experimentKey];
                                                 [weakSelf.logger logMessage:logMessage
                                                                   withLevel:OptimizelyLogLevelInfo];
                                             }
                                             if (callback) {
                                                 callback(error);
                                             }
                                         }];
    
    NSArray *args = @[experiment, userId ? : @"", attributes ? : [NSDictionary new], variation, impressionEventParams];
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:args];
    return variation;
}

/**
 Helper method to retrieve decisions for the user from the provided event.

 @param event The event which needs to be recorded.
 @param userId Id for user.
 @param attributes The user's attributes.
 @return Array of dictionaries containing valid experiment Ids, variation Ids and layer Ids into which the user is bucketed.
 */
- (NSArray<NSDictionary *> *)decisionsFor:(OPTLYEvent *)event
                                   userId:(NSString *)userId
                               attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    
    NSArray *experimentIds = event.experimentIds;
    
    if ([experimentIds count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesTrackEventNoAssociation, event.eventKey];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    NSMutableArray *decisions = [NSMutableArray new];
    
    for (NSString *experimentId in experimentIds) {
        OPTLYExperiment *experiment = [self.config getExperimentForId:experimentId];
        
        // if the experiment is nil, then it is not part of the project's list of experiments
        if (!experiment) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesTrackExperimentNoAssociation, experiment.experimentKey, event.eventKey];
            [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        // bucket user into a variation
        OPTLYVariation *variation = [self variation:experiment.experimentKey userId:userId attributes:attributes];
        
        // if the variation is nil, then experiment should not be tracked
        if (!variation) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesTrackExperimentNotTracked, userId, experiment.experimentKey];
            [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        NSMutableDictionary *decision = [NSMutableDictionary new];
        decision[OPTLYEventParameterKeysDecisionCampaignId]         = [Optimizely stringOrEmpty:experiment.layerId];
        decision[OPTLYEventParameterKeysDecisionExperimentId]       = experiment.experimentId;
        decision[OPTLYEventParameterKeysDecisionVariationId]        = variation.variationId;
        [decisions addObject:decision];
    }
    return decisions;
}

+ (BOOL)isEmptyArray:(NSObject*)array {
    return (!array
            || ![array isKindOfClass:[NSArray class]]
            || (((NSArray *)array).count == 0));
}

+ (BOOL)isEmptyString:(NSObject*)string {
    return (!string
            || ![string isKindOfClass:[NSString class]]
            || [(NSString *)string isEqualToString:@""]);
}

+ (BOOL)isEmptyDictionary:(NSObject*)dict {
    return (!dict
            || ![dict isKindOfClass:[NSDictionary class]]
            || (((NSDictionary *)dict).count == 0));
}

+ (NSString *)stringOrEmpty:(NSString *)str {
    NSString *string = str != nil ? str : @"";
    return string;
}
@end
