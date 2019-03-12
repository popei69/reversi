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

#import "OPTLYAudience.h"
#import "OPTLYDatafileKeys.h"

@implementation OPTLYAudience

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysAudienceId   : @"audienceId",
                                                             OPTLYDatafileKeysAudienceName : @"audienceName"
                                                        }];
}

- (void)setConditionsWithNSString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingAllowFragments
                                                       error:&err];
    if (err != nil) {
        NSException *exception = [[NSException alloc] initWithName:err.domain reason:err.localizedFailureReason userInfo:@{@"Error" : err}];
        @throw exception;
    }
    
    self.conditions = [OPTLYCondition deserializeJSONArray:array error:&err];
    
    if (err != nil) {
        NSException *exception = [[NSException alloc] initWithName:err.domain reason:err.localizedFailureReason userInfo:@{@"Error" : err}];
        @throw exception;
    }
}

- (BOOL)evaluateConditionsWithAttributes:(NSDictionary<NSString *,NSString *> *)attributes {
    for (NSObject<OPTLYCondition> *condition in self.conditions) {
        if ([condition evaluateConditionsWithAttributes:attributes]) {
            // if user satisfies any conditions, return true.
            return true;
        }
    }
    // if user doesn't satisfy any conditions, return false.
    return false;
}

@end
