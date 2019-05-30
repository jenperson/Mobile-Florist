//
//  STPPaymentMethodCardParams.m
//  Stripe
//
//  Created by Yuki Tokuhiro on 3/6/19.
//  Copyright © 2019 Stripe, Inc. All rights reserved.
//

#import "STPPaymentMethodCardParams.h"

#import "STPCardParams.h"

@implementation STPPaymentMethodCardParams

@synthesize additionalAPIParameters = _additionalAPIParameters;

- (instancetype)initWithCardSourceParams:(STPCardParams *)cardSourceParams {
    self = [self init];
    if (self) {
        _number = [cardSourceParams.number copy];
        _expMonth = @(cardSourceParams.expMonth);
        _expYear = @(cardSourceParams.expYear);
        _cvc = [cardSourceParams.cvc copy];
    }

    return self;
}

#pragma mark - STPFormEncodable


+ (NSString *)rootObjectName {
    return @"card";
}

+ (NSDictionary *)propertyNamesToFormFieldNamesMapping {
    return @{
             NSStringFromSelector(@selector(number)): @"number",
             NSStringFromSelector(@selector(expMonth)): @"exp_month",
             NSStringFromSelector(@selector(expYear)): @"exp_year",
             NSStringFromSelector(@selector(cvc)): @"cvc",
             NSStringFromSelector(@selector(token)): @"token",
             };
}

@end
