/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                   *
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

#import "OPTLYControlAttributes.h"
#import "OPTLYEvent.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventFeature.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEventTagUtil.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYVariation.h"

NSString * const OptimizelyActivateEventKey = @"campaign_activated";

// --- Event URLs ----
NSString * const OPTLYEventBuilderEventsTicketURL   = @"https://logx.optimizely.com/v1/events";

@interface OPTLYEventBuilderDefault ()

@property (readonly, strong) OPTLYProjectConfig *config;

@end

@implementation OPTLYEventBuilderDefault : NSObject

-(instancetype)initWithConfig:(OPTLYProjectConfig *)config {
    self = [super init];
    if (self != nil) {
        _config = config;
    }
    return self;
}

// NOTE: A dictionary is used to build the decision event ticket object instead of
// OPTLYDecisionEventTicket object to simplify the logic. The OPTLYEventFeature value can be a
// string, double, float, int, or boolean.
// The OPTLYJSONModel cannot support a generic primitive/object type, so each event tag
// value would have to be manually checked and converted to the appropriate OPTLYEventFeature type.
-(NSDictionary *)buildImpressionEventForUser:(NSString *)userId
                                  experiment:(OPTLYExperiment *)experiment
                                   variation:(OPTLYVariation *)variation
                                  attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (!self.config) {
        return nil;
    }
    
    NSDictionary *commonParams = [self createCommonParamsForUser:userId attributes:attributes];
    NSDictionary *impressionOnlyParams = [self createImpressionParamsOfExperiment:experiment variation:variation];
    NSDictionary *impressionParams = [self createImpressionOrConversionParamsWithCommonParams:commonParams conversionOrImpressionOnlyParams:@[impressionOnlyParams]];
    
    return impressionParams;
}

-(NSDictionary *)buildConversionEventForUser:(NSString *)userId
                                       event:(OPTLYEvent *)event
                                   decisions:(NSArray<NSDictionary *> *)decisions
                                   eventTags:(NSDictionary *)eventTags
                                  attributes:(NSDictionary<NSString *,NSString *> *)attributes {

    if (!self.config) {
        return nil;
    }
    
    NSDictionary *commonParams = [self createCommonParamsForUser:userId attributes:attributes];
    NSArray *conversionOnlyParams = [self createConversionParamsOfEvent:event userId:userId
                                                              decisions:decisions eventTags:eventTags
                                                             attributes:attributes];
    NSDictionary *conversionParams = [self createImpressionOrConversionParamsWithCommonParams:commonParams conversionOrImpressionOnlyParams:conversionOnlyParams];
    
    return conversionParams;
}

- (NSDictionary *)createCommonParamsForUser:(NSString *)userId
                                 attributes:(NSDictionary<NSString *, NSString *> *)attributes {
    NSMutableDictionary *commonParams = [NSMutableDictionary new];
    
    NSMutableDictionary *visitor = [NSMutableDictionary new];
    visitor[OPTLYEventParameterKeysSnapshots] =  [NSMutableArray new];
    visitor[OPTLYEventParameterKeysVisitorId] = [OPTLYEventBuilderDefault stringOrEmpty:userId];
    visitor[OPTLYEventParameterKeysAttributes] = [self createUserFeatures:self.config attributes:attributes];

    commonParams[OPTLYEventParameterKeysVisitors] = @[visitor];
    commonParams[OPTLYEventParameterKeysProjectId] = [OPTLYEventBuilderDefault stringOrEmpty:self.config.projectId ];
    commonParams[OPTLYEventParameterKeysAccountId] = [OPTLYEventBuilderDefault stringOrEmpty:self.config.accountId];
    commonParams[OPTLYEventParameterKeysClientEngine] = [OPTLYEventBuilderDefault stringOrEmpty:[self.config clientEngine]];
    commonParams[OPTLYEventParameterKeysClientVersion] = [OPTLYEventBuilderDefault stringOrEmpty:[self.config clientVersion]];
    commonParams[OPTLYEventParameterKeysRevision] = [OPTLYEventBuilderDefault stringOrEmpty:self.config.revision];
    commonParams[OPTLYEventParameterKeysAnonymizeIP] = @(self.config.anonymizeIP.boolValue);
    
    return [commonParams copy];
}
    
- (NSDictionary *)createImpressionParamsOfExperiment:(OPTLYExperiment *)experiment variation:(OPTLYVariation *)variation {
    
    NSMutableDictionary *snapshot = [NSMutableDictionary new];
    
    NSMutableDictionary *decision = [NSMutableDictionary new];
    decision[OPTLYEventParameterKeysDecisionCampaignId]     = [OPTLYEventBuilderDefault stringOrEmpty:experiment.layerId];
    decision[OPTLYEventParameterKeysDecisionExperimentId]   = experiment.experimentId;
    decision[OPTLYEventParameterKeysDecisionVariationId]    = variation.variationId;
    NSArray *decisions = @[decision];

    NSMutableDictionary *event = [NSMutableDictionary new];
    event[OPTLYEventParameterKeysEntityId]      = [OPTLYEventBuilderDefault stringOrEmpty:experiment.layerId];
    event[OPTLYEventParameterKeysTimestamp]     = [self time] ? : @0;
    event[OPTLYEventParameterKeysKey]           = OptimizelyActivateEventKey;
    event[OPTLYEventParameterKeysUUID]          = [[NSUUID UUID] UUIDString];
    NSArray *events = @[event];

    snapshot[OPTLYEventParameterKeysDecisions]  = decisions;
    snapshot[OPTLYEventParameterKeysEvents]     = events;
    
    return snapshot;
}

- (NSDictionary *)createImpressionOrConversionParamsWithCommonParams:(NSDictionary *)commonParams
                                 conversionOrImpressionOnlyParams:(NSArray *)conversionOrImpressionOnlyParams {
    
    NSMutableArray *visitors = commonParams[OPTLYEventParameterKeysVisitors];
    if(visitors.count > 0) {
        visitors[0][OPTLYEventParameterKeysSnapshots] = conversionOrImpressionOnlyParams;
    }
    return commonParams;
}

- (NSArray *)createConversionParamsOfEvent:(OPTLYEvent *)event
                                    userId:(NSString *)userId
                                 decisions:(NSArray<NSDictionary *> *)decisions
                                 eventTags:(NSDictionary *)eventTags
                                attributes:(NSDictionary *)attributes {
    
    NSMutableArray *conversionEventParams = [NSMutableArray new];
    NSMutableDictionary *snapshot = [NSMutableDictionary new];
    
    NSMutableDictionary *eventDict = [NSMutableDictionary new];
    eventDict[OPTLYEventParameterKeysEntityId]      = [OPTLYEventBuilderDefault stringOrEmpty:event.eventId];
    eventDict[OPTLYEventParameterKeysTimestamp]     = [self time] ? : @0;
    eventDict[OPTLYEventParameterKeysKey]           = event.eventKey;
    eventDict[OPTLYEventParameterKeysUUID]          = [[NSUUID UUID] UUIDString];
    
    if (eventTags) {
        // remove tags if their types are not supported
        NSDictionary *filteredEventTags = [self filterEventTags:eventTags];
        
        // Allow only 'revenue' eventTags with integer values (max long long); otherwise the value will be cast to an integer
        NSNumber *revenueValue = [OPTLYEventTagUtil getRevenueValue:filteredEventTags logger:self.config.logger];
        if (revenueValue != nil) {
            eventDict[OPTLYEventMetricNameRevenue] = revenueValue;
        }
        // Allow only 'value' eventTags with double values; otherwise the value will be cast to a double
        NSNumber *numericValue = [OPTLYEventTagUtil getNumericValue:filteredEventTags logger:self.config.logger];
        if (numericValue != nil) {
            eventDict[OPTLYEventMetricNameValue] = numericValue;
        }
        
        if (filteredEventTags.count > 0) {
            eventDict[OPTLYEventParameterKeysTags] = filteredEventTags;
        }
    }
    
    snapshot[OPTLYEventParameterKeysDecisions] = decisions;
    snapshot[OPTLYEventParameterKeysEvents] = @[eventDict];
    
    [conversionEventParams addObject:snapshot];
    
    return [conversionEventParams copy];
}

- (NSDictionary *)filterEventTags:(NSDictionary *)eventTags {
    NSMutableDictionary *mutableEventTags = [[NSMutableDictionary alloc] initWithDictionary:eventTags];
    
    for (NSString *tagKey in [eventTags allKeys]) {
        id tagValue = eventTags[tagKey];
        
        // only string, long, int, double, float, and booleans are supported
        if (![tagValue isKindOfClass:[NSString class]] && ![tagValue isKindOfClass:[NSNumber class]]) {
            [mutableEventTags removeObjectForKey:tagKey];
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventTagValueInvalid, tagKey];
            [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
    }
    return mutableEventTags;
}

- (NSArray *)createUserFeatures:(OPTLYProjectConfig *)config
                     attributes:(NSDictionary *)attributes {
    
    NSNumber *botFiltering = config.botFiltering;
    NSMutableArray *features = [NSMutableArray new];
    NSArray *attributeKeys = [attributes allKeys];
    
    for (NSString *attributeKey in attributeKeys) {
        NSString *attributeValue = attributes[attributeKey];
        if ([OPTLYEventBuilderDefault isEmptyString:attributeValue]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeValueInvalidFormat, attributeKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        NSString *attributeId = [config getAttributeIdForKey:attributeKey];
        if ([OPTLYEventBuilderDefault isEmptyString:attributeId]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeInvalidFormat, attributeKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        } else {
            [features addObject: @{ OPTLYEventParameterKeysFeaturesId           : attributeId,
                                    OPTLYEventParameterKeysFeaturesKey          : attributeKey,
                                    OPTLYEventParameterKeysFeaturesType         : OPTLYEventFeatureFeatureTypeCustomAttribute,
                                    OPTLYEventParameterKeysFeaturesValue        : attributeValue,
                                    OPTLYEventParameterKeysFeaturesShouldIndex  : @YES }];
        }
    }
    //check for botFiltering value in the project config file.
    if (botFiltering) {
        [features addObject:@{ OPTLYEventParameterKeysFeaturesId           : OptimizelyBotFiltering,
                               OPTLYEventParameterKeysFeaturesKey          : OptimizelyBotFiltering,
                               OPTLYEventParameterKeysFeaturesType         : OPTLYEventFeatureFeatureTypeCustomAttribute,
                               OPTLYEventParameterKeysFeaturesValue        : @(botFiltering.boolValue),
                               OPTLYEventParameterKeysFeaturesShouldIndex  : @YES }];
    }
    return [features copy];
}

// time in milliseconds
- (NSNumber *)time
{
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    // need to cast this since the event class expects a long long (results will reject this value otherwise)
    long long currentTimeIntervalCast = currentTimeInterval;
    NSNumber *timestamp = [NSNumber numberWithLongLong:currentTimeIntervalCast];

    return timestamp;
}

+ (NSString *)stringOrEmpty:(NSString *)str {
    NSString *string = str != nil ? str : @"";
    return string;
}

+ (BOOL)isEmptyString:(NSString*)str {
    return (str == nil
            || [str isKindOfClass:[NSNull class]]
            || [str length] == 0);
}

@end
