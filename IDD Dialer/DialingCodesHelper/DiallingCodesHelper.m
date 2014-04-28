//
//  DiallingCodesHelper.m
//  IDD Dialer
//
//  Created by Raymond Lee on 4/3/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

#import "DiallingCodesHelper.h"

@implementation DiallingCodesHelper
static DiallingCodesHelper *_helper;

+ (DiallingCodesHelper *)sharedHelper {
    if (!_helper) {
        _helper = [[DiallingCodesHelper alloc] init];
    }
    return _helper;
}

- (id)init {
    self.iddArray = [DiallingCodesHelper initialIDDs];
    self.countryCodeArray = [DiallingCodesHelper initialCountryCodes];
    self.disabledCountryCodeArray = [DiallingCodesHelper initialDisabledCountryCodes];
    return [super init];
}

#pragma mark - country codes

+ (NSArray *)countryNames {
    static NSArray *_countryNames = nil;
    if (!_countryNames) {
        _countryNames = [[[[self countryNamesByCode] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] copy];
    }
    return _countryNames;
}

+ (NSArray *)countryCodes {
    static NSArray *_countryCodes = nil;
    if (!_countryCodes) {
        _countryCodes = [[[self countryCodesByName] objectsForKeys:[self countryNames] notFoundMarker:@""] copy];
    }
    return _countryCodes;
}

+ (NSDictionary *)countryNamesByCode {
    static NSDictionary *_countryNamesByCode = nil;
    if (!_countryNamesByCode) {
        NSMutableDictionary *namesByCode = [NSMutableDictionary dictionary];
        for (NSString *code in [NSLocale ISOCountryCodes]) {
            NSString *identifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCountryCode : code}];
            NSString *countryName = [[NSLocale localeWithLocaleIdentifier:@"en_GB"] displayNameForKey:NSLocaleIdentifier value:identifier];
            if (countryName) namesByCode[code] = countryName;
        }
        _countryNamesByCode = [namesByCode copy];
    }
    return _countryNamesByCode;
}

+ (NSDictionary *)countryCodesByName {
    static NSDictionary *_countryCodesByName = nil;
    if (!_countryCodesByName) {
        NSDictionary *countryNamesByCode = [self countryNamesByCode];
        NSMutableDictionary *codesByName = [NSMutableDictionary dictionary];
        for (NSString *code in countryNamesByCode) {
            codesByName[countryNamesByCode[code]] = code;
        }
        _countryCodesByName = [codesByName copy];
    }
    return _countryCodesByName;
}

+ (NSDictionary *)diallingCodesByCode {
    static NSDictionary *_diallingCodesByCodeDict;
    if (!_diallingCodesByCodeDict) {
        NSString *path = [[NSBundle mainBundle] pathForResource:
                @"DiallingCodes"                         ofType:@"plist"];
        NSDictionary *diallingCodesDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        _diallingCodesByCodeDict = [diallingCodesDict copy];
    }
    return _diallingCodesByCodeDict;
}

#pragma mark - init data

+ (NSMutableArray *)initialIDDs {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"IDDData.plist"];
    NSMutableArray *iddArray = [NSArray arrayWithContentsOfFile:path];;
    //write default
    if (!iddArray || [iddArray count] == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:
                @"idd_data"                              ofType:@"plist"];

        iddArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    NSLog(@"INIT: idd = %lu", (unsigned long) iddArray.count);
    return iddArray;
}

+ (NSMutableArray *)initialCountryCodes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"CountryCodeData.plist"];
    NSMutableArray *countryArray = [NSMutableArray arrayWithContentsOfFile:path];

    //write default
    if (!countryArray || [countryArray count] == 0) {
        path = [[NSBundle mainBundle] pathForResource:
                @"countryCode_data"            ofType:@"plist"];
        countryArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    NSLog(@"INIT: enabled country = %lu", (unsigned long) countryArray.count);
    return countryArray;
}

+ (NSMutableArray *)initialDisabledCountryCodes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"DisabledCountryCodeData.plist"];
    NSMutableArray *dCountryArray = [NSMutableArray arrayWithContentsOfFile:path];

    NSMutableArray *countryArray = [self initialCountryCodes];
    if (!dCountryArray || [dCountryArray count] == 0) {
        dCountryArray = [NSMutableArray new];
        for (NSString *code in [self countryCodes]) {
            if (![countryArray containsObject:code]) {
                [dCountryArray addObject:code];
            }
        }
    }
    NSLog(@"INIT: disabled country = %lu", (unsigned long) dCountryArray.count);
    return dCountryArray;
}

+ (NSString *)countryNameByCode:(NSString *)code {
    return [self countryNamesByCode][code];
}

+ (NSString *)diallingCodeByCode:(NSString *)code {
    return [self diallingCodesByCode][code];
}


+ (NSString *)preferenceByCode:(NSString *)code {
    NSString *preference;
    NSDictionary *preferenceDict;
    NSString *path = [[NSBundle mainBundle] pathForResource:
            @"Perference"                            ofType:@"plist"];
    preferenceDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    preference = preferenceDict[code];
    return preference;
}

+ (void)setPreferenceByCode:(NSString *)code {

}

@end
