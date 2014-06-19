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

- (instancetype)init {
    self.iddArray = [DiallingCodesHelper initialIDDs];
    self.countryCodeArray = [DiallingCodesHelper initialCountryCodes];
    self.disabledCountryCodeArray = [DiallingCodesHelper initialDisabledCountryCodes:self.countryCodeArray];
    self.preferenceDict = [DiallingCodesHelper initialPreference];
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
            NSString *countryName = [[NSLocale localeWithLocaleIdentifier:[NSLocale preferredLanguages][0]] displayNameForKey:NSLocaleIdentifier value:identifier];
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
    static NSString *fileName = @"idd_record.plist";
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    NSMutableArray *iddArray = [NSMutableArray arrayWithContentsOfFile:path];;
    //write default
    if (!iddArray || [iddArray count] == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"IDDData"                              ofType:@"plist"];
        
        iddArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        NSLog(@"INIT: %@ not exsist, creat default with size = %lu", fileName, iddArray.count);
    }else{
        NSLog(@"INIT: idd code = %lu", (unsigned long) iddArray.count);
    }
    return iddArray;
}

+ (NSMutableArray *)initialCountryCodes {
    static NSString *fileName = @"cc_record.plist";
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    NSMutableArray *countryArray = [NSMutableArray arrayWithContentsOfFile:path];
    
    //write default
    if (!countryArray || [countryArray count] == 0) {
        path = [[NSBundle mainBundle] pathForResource:
                @"CountryCodeData"            ofType:@"plist"];
        countryArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        NSLog(@"INIT: %@ not exsist, creat default with size = %lu",fileName, countryArray.count);
    }else{
        NSLog(@"INIT: enabled country = %lu", (unsigned long) countryArray.count);
    }
    return countryArray;
}

+ (NSMutableArray *)initialDisabledCountryCodes:(NSArray*) countryArray {
    static NSString *fileName = @"dcc_record.plist";
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    NSMutableArray *dCountryArray = [NSMutableArray arrayWithContentsOfFile:path];
    
    if (!dCountryArray || [dCountryArray count] == 0) {
        dCountryArray = [NSMutableArray new];
        for (NSString *code in [self countryCodes]) {
            if (![countryArray containsObject:code]) {
                [dCountryArray addObject:code];
            }
        }
        NSLog(@"INIT: %@ not exsist, creat default with size = %lu",fileName, dCountryArray.count);
    }else{
        NSLog(@"INIT: disabled country = %lu", (unsigned long) dCountryArray.count);
    }
    return dCountryArray;
}

+ (NSMutableDictionary *)initialPreference {
    static NSString *fileName = @"preference.plist";
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    NSMutableDictionary *preDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!preDict) {
        preDict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSLog(@"INIT: %@ not exsist",fileName);
    }else{
        NSLog(@"INIT: preference = %lu", (unsigned long) preDict.count);
    }
    return preDict;
}

+ (NSString *)countryNameByCode:(NSString *)code {
    return [self countryNamesByCode][code];
}

+ (NSString *)diallingCodeByCode:(NSString *)code {
    return [self diallingCodesByCode][code];
}


+ (NSString *)preferenceByCode:(NSString *)code {
    @synchronized (preferenceIDDs) {
        NSString *preference;
        preference = preferenceIDDs[code];
        if (preference) {
            NSInteger index = NSNotFound;
            for (NSDictionary *dict in idds) {
                if ([preference isEqual:dict[@"IDD"]]) {
                    index = [idds indexOfObject:dict];
                    break;
                }
            }
            if (index != NSNotFound) {
                return preference;
            } else {
                [self setPreference:nil code:code];
                
            }
        }
    }
    return nil;
}

+ (void)setPreference:(NSString *)preference code:(NSString *)code {
    if (code) {
        @synchronized (preferenceIDDs) {
            if (preference) {
                preferenceIDDs[code] = preference;
            } else {
                [preferenceIDDs removeObjectForKey:code];
            }
            NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:@"preference.plist"];
            [preferenceIDDs writeToFile:path atomically:YES];
            NSLog(@"preference saved");
        }
    } else {
        BLog(@"code is nil");
    }
}

#pragma mark - others

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

@end
