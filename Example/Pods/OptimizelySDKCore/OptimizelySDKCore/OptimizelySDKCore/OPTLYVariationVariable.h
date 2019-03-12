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

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

/**
 * This class is a representation of an Optimizely live variable scoped within a variation:
 * "variations": [
 *           {
 *             "id": "6451680205",
 *             "key": "a",
 *             "variables": [
 *               {
 *                 "id": "73483201090",
 *                 "value": "testValue"
 *               },
 *               ...
 *               ]
 *           }
 */

@protocol OPTLYVariationVariable
@end

@interface OPTLYVariationVariable : OPTLYJSONModel

/// The variable's ID.
@property (nonatomic, strong) NSString *variableId;
/// The variable's assigned value within that variation
@property (nonatomic, strong) NSString *value;

@end
