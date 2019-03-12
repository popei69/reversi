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

#import "OPTLYBaseCondition.h"
#import "OPTLYDatafileKeys.h"

@implementation OPTLYBaseCondition

+ (BOOL) isBaseConditionJSON:(NSData *)jsonData {
    if (![jsonData isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    else {
        NSDictionary *dict = (NSDictionary *)jsonData;
        
        if (dict[OPTLYDatafileKeysConditionName] != nil &&
            dict[OPTLYDatafileKeysConditionType] != nil &&
            dict[OPTLYDatafileKeysConditionValue] != nil) {
            return true;
        }
        return false;
    }
}

- (BOOL)evaluateConditionsWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (attributes == nil) {
        // if the user did not pass in attributes, return false
        return false;
    }
    else {
        // check user attribute value for the condition against our condition value 
        return [self.value isEqualToString:attributes[self.name]];
    }
}

@end
