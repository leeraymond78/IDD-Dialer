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
#define preferenceIDDs [DiallingCodesHelper sharedHelper].preferenceDict


#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define isEmptyString(str) ((str == nil)|| [@"" isEqual:str])

@interface DiallingCodesHelper : NSObject

@property(nonatomic, strong) NSMutableArray *iddArray;
@property(nonatomic, strong) NSMutableArray *countryCodeArray;
@property(nonatomic, strong) NSMutableArray *disabledCountryCodeArray;
@property(nonatomic, strong) NSMutableDictionary *preferenceDict;

+ (DiallingCodesHelper *)sharedHelper;

+ (NSArray *)countryNames;

+ (NSArray *)countryCodes;

+ (NSDictionary *)countryNamesByCode;

+ (NSDictionary *)countryCodesByName;

+ (NSDictionary *)diallingCodesByCode;

+ (NSString *)countryNameByCode:(NSString *)code;

+ (NSString *)diallingCodeByCode:(NSString *)code;

+ (NSString *)preferenceByCode:(NSString *)code;

+ (void)setPreference:(NSString *)preference code:(NSString *)code;

+ (NSString *)documentsDirectory;
@end
