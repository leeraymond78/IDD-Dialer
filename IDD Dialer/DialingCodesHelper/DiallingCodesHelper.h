//
//  DiallingCodesHelper.h
//  IDD Dialer
//
//  Created by Raymond Lee on 4/3/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//
#define idds [DiallingCodesHelper sharedHelper].iddArray
#define countries [DiallingCodesHelper sharedHelper].countryCodeArray
#define disabledCountries [DiallingCodesHelper sharedHelper].disabledCountryCodeArray

@interface DiallingCodesHelper : NSObject

@property(nonatomic, strong) NSMutableArray *iddArray;
@property(nonatomic, strong) NSMutableArray *countryCodeArray;
@property(nonatomic, strong) NSMutableArray *disabledCountryCodeArray;

+ (DiallingCodesHelper *)sharedHelper;

+ (NSArray *)countryNames;

+ (NSArray *)countryCodes;

+ (NSDictionary *)countryNamesByCode;

+ (NSDictionary *)countryCodesByName;

+ (NSDictionary *)diallingCodesByCode;

+ (NSMutableArray *)initialIDDs;

+ (NSMutableArray *)initialCountryCodes;

+ (NSMutableArray *)initialDisabledCountryCodes;

+ (NSString *)countryNameByCode:(NSString *)code;

+ (NSString *)diallingCodeByCode:(NSString *)code;

+ (NSString *)preferenceByCode:(NSString *)code;

+ (void)setPreferenceByCode:(NSString *)code;
@end
