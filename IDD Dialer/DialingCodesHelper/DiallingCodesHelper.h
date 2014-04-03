//
//  DiallingCodesHelper.h
//  IDD Dialer
//
//  Created by Raymond Lee on 4/3/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

@interface DiallingCodesHelper : NSObject

+ (NSArray *)countryNames;

+ (NSArray *)countryCodes;

+ (NSDictionary *)countryNamesByCode;

+ (NSDictionary *)countryCodesByName;

+ (NSDictionary *)diallingCodesByCode;

+ (NSArray *)initialIDDs;

+ (NSArray *)initialCountryCodes;

+ (NSMutableArray *)initialDisabledCountryCodes;

+ (NSString *)countryNameByCode:(NSString *)code;

+ (NSString *)diallingCodeByCode:(NSString *)code;

@end
