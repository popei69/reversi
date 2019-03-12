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

#import <Foundation/Foundation.h>

@class OPTLYExperiment, OPTLYVariation;

extern NSString * const DecisionSourceExperiment;
extern NSString * const DecisionSourceRollout;

/**
 * This class determines how the Optimizely SDK will handle exceptions and errors.
 */
@interface OPTLYFeatureDecision : NSObject

/// an OPTLYExperiment associated with the decision.
@property (nonatomic, strong) OPTLYExperiment *experiment;
/// an OPTLYVariation associated with the decision.
@property (nonatomic, strong) OPTLYVariation *variation;
/// an NSString to hold the source of the decision. Either experiment or rollout
@property (nonatomic, strong) NSString *source;

/*
 * Initializes the FeatureDecision with an experiment id, variation id & source.
 *
 * @param experimentId The id of experiment.
 * @param variationId The id of variation.
 * @param source The source for which the decision made.
 * @return An instance of the FeatureDecision.
 */
- (instancetype)initWithExperiment:(OPTLYExperiment *)experiment variation:(OPTLYVariation *)variation source:(NSString *)source;

@end
