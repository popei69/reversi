/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                        *
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

#import "OPTLYCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYErrorHandlerMessages.h"

@implementation OPTLYCondition

+ (NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSONArray:(NSArray *)jsonArray {
    return [OPTLYCondition deserializeJSONArray:jsonArray error:nil];
}

// example jsonArray:
//  [“and", [“or", [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": “a”}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "b"}], [“or", {"name": "sample_attribute_key", "type": "custom_attribute", "value": "c"}]
+ (NSArray<OPTLYCondition *><OPTLYCondition> *)deserializeJSONArray:(NSArray *)jsonArray
                                            error:(NSError * __autoreleasing *)error {
    
    // need to check if the jsonArray is actually an array, otherwise, something is wrong with the audience condition
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        NSError *err = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                           code:OPTLYErrorTypesDatafileInvalid
                                       userInfo:@{NSLocalizedDescriptionKey : OPTLYErrorHandlerMessagesProjectConfigInvalidAudienceCondition}];
        if (error && err) {
            *error = err;
        }
        return nil;
    }
    
    if (jsonArray.count > 1 && [OPTLYBaseCondition isBaseConditionJSON:jsonArray[1]]) { //base case condition
        
        // generate all base conditions
        NSMutableArray<OPTLYCondition *><OPTLYCondition> *conditions = (NSMutableArray<OPTLYCondition *><OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(jsonArray.count - 1)];
        for (int i = 1; i < jsonArray.count; i++) {
            NSDictionary *info = jsonArray[i];
            NSError *err = nil;
            OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:info
                                                                                     error:&err];
            if (error && err) {
                *error = err;
            } else {
                if (condition != nil) {
                    [conditions addObject:condition];
                }
            }
        }
        
        // return an (And/Or/Not) Condition handling the base conditions
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:jsonArray[0]
                                                                              withConditions:conditions];
        return (NSArray<OPTLYCondition *><OPTLYCondition> *)@[condition];
    }
    else { // further condition arrays to deserialize
        NSMutableArray<OPTLYCondition *><OPTLYCondition> *subConditions = (NSMutableArray<OPTLYCondition *><OPTLYCondition> *)[[NSMutableArray alloc] initWithCapacity:(jsonArray.count - 1)];
        for (int i = 1; i < jsonArray.count; i++) {
            NSError *err = nil;
            NSArray *deserializedJsonObject = [OPTLYCondition deserializeJSONArray:jsonArray[i] error:&err];
            
            if (err) {
                *error = err;
                return nil;
            }

            if (deserializedJsonObject != nil) {
                [subConditions addObjectsFromArray:deserializedJsonObject];
            }
        }
        NSObject<OPTLYCondition> *condition = [OPTLYCondition createConditionInstanceOfClass:jsonArray[0]
                                                                              withConditions:subConditions];
        return (NSArray<OPTLYCondition *><OPTLYCondition> *)@[condition];
    }
}

+ (NSObject<OPTLYCondition> *)createConditionInstanceOfClass:(NSString *)conditionClass withConditions:(NSArray<OPTLYCondition *><OPTLYCondition> *)conditions {
    if ([conditionClass isEqualToString:OPTLYDatafileKeysAndCondition]) {
        OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
        andCondition.subConditions = conditions;
        return andCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysOrCondition]) {
        OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
        orCondition.subConditions = conditions;
        return orCondition;
    }
    else if ([conditionClass isEqualToString:OPTLYDatafileKeysNotCondition]) {
        OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
        notCondition.subCondition = conditions[0];
        return notCondition;
    }
    else {
        NSString *exceptionDescription = [NSString stringWithFormat:@"Condition Class `%@` is not a recognized Optimizely Condition Class", conditionClass];
        NSException *exception = [[NSException alloc] initWithName:@"Condition Class Exception"
                                                            reason:@"Unrecognized Condition Class"
                                                          userInfo:@{OPTLYErrorHandlerMessagesDataFileInvalid : exceptionDescription}];
        @throw exception;
    }
    return nil;
}

@end

@implementation OPTLYAndCondition

- (BOOL)evaluateConditionsWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        // if any of our sub conditions are false
        if (![condition evaluateConditionsWithAttributes:attributes]) {
            // short circuit and return false
            return false;
        }
    }
    // if all sub conditions are true, return true.
    return true;
}

@end

@implementation OPTLYOrCondition

- (BOOL)evaluateConditionsWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    for (NSObject<OPTLYCondition> *condition in self.subConditions) {
        // if any of our sub conditions are true
        if ([condition evaluateConditionsWithAttributes:attributes]) {
            // short circuit and return true
            return true;
        }
    }
    // if all of the sub conditions are false, return false
    return false;
}

@end

@implementation OPTLYNotCondition

- (BOOL)evaluateConditionsWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    // return the negative of the subcondition
    return ![self.subCondition evaluateConditionsWithAttributes:attributes];
}

@end
