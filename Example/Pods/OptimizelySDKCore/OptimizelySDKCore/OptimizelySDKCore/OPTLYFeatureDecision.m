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

#import "OPTLYFeatureDecision.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"

NSString * const DecisionSourceExperiment = @"experiment";
NSString * const DecisionSourceRollout = @"rollout";

@implementation OPTLYFeatureDecision

- (instancetype)initWithExperiment:(OPTLYExperiment *)experiment variation:(OPTLYVariation *)variation source:(NSString *)source {
    self = [super init];
    if (self) {
        _experiment = experiment;
        _variation = variation;
        _source = source;
    }
    return self;
}

@end
