/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

#import "OPTLYExperiment.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYVariation.h"

NSString * const OPTLYExperimentStatusRunning = @"Running";

@interface OPTLYExperiment()
/// A mapping of an experiment's variation's ID to the matching variation.
/// @{NSString *variationId : OPTLYVariation *variation}
@property (nonatomic, strong) NSDictionary<Ignore> *variationIdToVariationMap;
/// A mapping of an experiment's variation's Key to the matching variation.
/// @{NSString *variationKey : OPTLYVariation *variation}
@property (nonatomic, strong) NSDictionary<Ignore> *variationKeyToVariationMap;
@end

@implementation OPTLYExperiment

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysExperimentId   : @"experimentId",
                                                        OPTLYDatafileKeysExperimentKey  : @"experimentKey",
                                                        OPTLYDatafileKeysExperimentTrafficAllocation : @"trafficAllocations"
                                                        }];
}

- (void)setGroupId:(NSString *)groupId {
    _groupId = groupId;
}

# pragma mark - Variation Mappings and Getters

- (OPTLYVariation *)getVariationForVariationId:(NSString *)variationId
{
    OPTLYVariation *variation = nil;
    if (variationId) {
        variation = self.variationIdToVariationMap[variationId];
    }
    
    return variation;
}

- (NSDictionary *)variationIdToVariationMap
{
    if (!_variationIdToVariationMap) {
        _variationIdToVariationMap = [OPTLYExperiment generateVariationIdMapFromVariationsArray:self.variations];
    }
    return _variationIdToVariationMap;
}

+ (NSDictionary *)generateVariationIdMapFromVariationsArray:(NSArray *)variations {
    NSMutableDictionary *variationIdsToVariationsMap = [[NSMutableDictionary alloc] initWithCapacity:variations.count];
    for (OPTLYVariation *variation in variations) {
        variationIdsToVariationsMap[variation.variationId] = variation;
    }
    return [NSDictionary dictionaryWithDictionary:variationIdsToVariationsMap];
}

- (OPTLYVariation *)getVariationForVariationKey:(NSString *)variationKey
{
    OPTLYVariation *variation = self.variationKeyToVariationMap[variationKey];
    return variation;
}

- (NSDictionary *)variationKeyToVariationMap
{
    if (!_variationKeyToVariationMap) {
        _variationKeyToVariationMap = [OPTLYExperiment generateVariationKeyMapFromVariationsArray:self.variations];
    }
    return _variationKeyToVariationMap;
}

+ (NSDictionary *)generateVariationKeyMapFromVariationsArray:(NSArray *)variations {
    NSMutableDictionary *variationKeysToVariationsMap = [[NSMutableDictionary alloc] initWithCapacity:variations.count];
    for (OPTLYVariation * variation in variations) {
        variationKeysToVariationsMap[variation.variationKey] = variation;
    }
    return [NSDictionary dictionaryWithDictionary:variationKeysToVariationsMap];
}

- (BOOL)isExperimentRunning
{
    BOOL isRunning = [self.status isEqualToString:OPTLYExperimentStatusRunning];
    return isRunning;
}

@end
