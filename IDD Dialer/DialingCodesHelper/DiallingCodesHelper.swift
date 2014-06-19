//
//  DiallingCodesHelper.swift
//  IDD Dialer
//
//  Created by Raymond Lee on 18/6/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

@objc class IDDRecord{
    var iddCode:String
    var with00:Bool
    
    init(iddCode:String, with00:Bool){
        self.iddCode = iddCode
        self.with00 = with00
    }
}

@infix func == (left: IDDRecord, right: IDDRecord) -> Bool {
    if left.iddCode == right.iddCode{
        return true
    }else{return false}
}

@objc class DiallingCodesHelper {
    var iddArray:IDDRecord[] = []
    var countryCodeArray:String[] = []
    var disabledCountryCodeArray:String[] = []
    var preferenceDict = Dictionary<String, String>()
    
    var countryNamesByCode:Dictionary<String, String>{
        struct Static {
            static var instance : Dictionary<String, String>? = nil
            static var token : dispatch_once_t = 0
            }
            dispatch_once(&Static.token) {
                var countryDict = Dictionary<String, String>()
            for code : AnyObject in NSLocale.ISOCountryCodes() {
                let identifier = NSLocale.localeIdentifierFromComponents([NSLocaleCountryCode : code])
                let countryName = NSLocale(localeIdentifier: (NSLocale.preferredLanguages() as NSArray).objectAtIndex(0) as String).displayNameForKey(NSLocaleIdentifier, value: identifier)
                countryDict[code as String] = countryName
                Static.instance = countryDict
            }
        }
        return Static.instance!
    }
    
    var countryCodesByName:Dictionary<String, String>{
    struct Static {
        static var instance : Dictionary<String, String>? = nil
        static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            var _countryCodesByName = Dictionary<String, String>()
            for (code,name) in self.countryNamesByCode {
                _countryCodesByName[name] = code;
            }
            Static.instance = _countryCodesByName
        }
        return Static.instance!
    }
    
    var countryNames:String[]{
    struct Static {
        static var instance : String[]? = nil
        static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            var _countryNames : String[]
            _countryNames = sort(Array(self.countryNamesByCode.values), {(s1:String, s2:String) -> Bool in return s1.lowercaseString < s2.lowercaseString})
            Static.instance = _countryNames
        }
        return Static.instance!
    }
    
    var countryCodes:String[]{
    struct Static {
        static var instance : String[]? = nil
        static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            var _countryCodes = String[]()
            for name in self.countryNames{
                if let code = self.countryCodesByName[name]{
                    _countryCodes.append(code)
                }
            }
            Static.instance = _countryCodes
        }
        return Static.instance!
    }
    
    var diallingCodesByCode:Dictionary<String, String>{
    struct Static {
        static var instance : Dictionary<String, String>? = nil
        static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            var _diallingCodesByCodeDict = Dictionary<String, String>()
            let path = NSBundle.mainBundle().pathForResource("DiallingCodes", ofType: "plist")
            _diallingCodesByCodeDict = NSDictionary(contentsOfFile: path) as Dictionary<String, String>
            Static.instance = _diallingCodesByCodeDict
        }
        return Static.instance!
    }
    
    class var sharedHelper : DiallingCodesHelper {
        get {
            struct Static {
                static var instance : DiallingCodesHelper? = nil
                static var token : dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token) { Static.instance = DiallingCodesHelper() }
            
            return Static.instance!
    }
    }
    
    class func sharedHelperMethod() -> DiallingCodesHelper{
        return sharedHelper
    }
    
    init(){
        iddArray = initialIDDs()
        countryCodeArray = initialCountryCodes()
        disabledCountryCodeArray = initialDisabledCountryCodes()
        preferenceDict = initialPreference()
    }
    
    //    #pragma mark - convert data
    func convertToIDDRecords(array:Dictionary<String, AnyObject>[]) -> IDDRecord[]{
        var iddRecords = IDDRecord[]()
        for dict in array{
            var code = ""
            var with00 = false
            for (key, value : AnyObject) in dict{
                if key == "IDD"{
                    code = (value as String)
                }else if key == "IDD00"{
                    with00 = (value as NSNumber).boolValue
                }
            }
            iddRecords.append(IDDRecord(iddCode: code, with00: with00))
        }
        return iddRecords
    }
    
    func convertToDictionaries(iddRecords:IDDRecord[]) -> Dictionary<String, AnyObject>[]{
        var dictionaries = Dictionary<String, AnyObject>[]()
        for iddRecord in iddRecords{
            dictionaries.append(["IDD":iddRecord.iddCode, "IDD00":NSNumber(bool: iddRecord.with00)])
        }
        return dictionaries
    }
    
    //    #pragma mark - init data
    
    func initialIDDs() -> IDDRecord[]{
        var path = DiallingCodesHelper.documentsDirectory().stringByAppendingPathComponent("idd_record.plist")
        var tempIddArray = NSArray(contentsOfFile: path)
        //write default
        if tempIddArray.count == 0 {
            path = NSBundle.mainBundle().pathForResource("IDDData", ofType: "plist")
            tempIddArray = NSArray(contentsOfFile: path)
            NSLog("INIT: idd_record.plist not exsist, creat default with size = %lu", tempIddArray.count)
        }else{
            NSLog("INIT: idd = %lu", tempIddArray.count)
        }
        return convertToIDDRecords(tempIddArray as Dictionary<String, AnyObject>[]);
    }
    
    func initialCountryCodes() -> String[]{
        var path = DiallingCodesHelper.documentsDirectory().stringByAppendingPathComponent("cc_record.plist")
        var tempCountryArray = NSArray(contentsOfFile: path)
        //write default
        if tempCountryArray.count == 0 {
            path = NSBundle.mainBundle().pathForResource("CountryCodeData", ofType: "plist")
            tempCountryArray = NSArray(contentsOfFile: path)
            NSLog("INIT: cc_record.plist not exsist, creat default with size = %lu", tempCountryArray.count)
        }else{
            NSLog("INIT: enabled country = %lu", tempCountryArray.count)
        }
        return tempCountryArray as String[]
    }
    
    func initialDisabledCountryCodes() -> String[]{
        let path = DiallingCodesHelper.documentsDirectory().stringByAppendingPathComponent("dcc_record.plist")
        var dCountryArray = NSArray(contentsOfFile: path)
        //write default
        if dCountryArray.count == 0 {
            var dCountries = String[]()
            for code in countryCodes{
                if (!contains(countryCodeArray, code)) {
                    dCountries.append(code)
                }
            }
            NSLog("INIT: dcc_record.plist not exsist, creat default with size = %lu", dCountries.count)
            return dCountries
        }else{
            NSLog("INIT: disabled country = %lu", dCountryArray.count)            
        }
        return dCountryArray as String[]
    }
    
    func initialPreference() -> Dictionary<String, String>{
        let path = DiallingCodesHelper.documentsDirectory().stringByAppendingPathComponent("preference.plist")
        var preDict = NSDictionary(contentsOfFile: path)
        if preDict.count == 0 {
            preDict = NSDictionary()
            NSLog("INIT: preference.plist not exsist")
        }else{
            NSLog("INIT: preference = %lu", preDict.count)
        }
        return preDict as Dictionary<String, String>
    }
    
    func countryNameByCode(code:String) -> String?{
        return countryNamesByCode[code]
    }
    
    func diallingCodeByCode(code:String) -> String?{
        return diallingCodesByCode[code]
    }
    
    func preferenceByCode(code:String) -> String?{
        let preference = preferenceDict[code]
        var index = -1
        for i in 0..iddArray.count {
            if iddArray[i].iddCode == preference {
                index = i
                break
            }
        }
        if index != -1 {
            return preference;
        } else {
            setPreference(nil, code: code)
            return nil;
        }
    }
    
    func setPreference(preference:String?, code:String){
        if preference {
            preferenceDict[code] = preference
        } else {
            preferenceDict.removeValueForKey(code)
        }
        let path = DiallingCodesHelper.documentsDirectory().stringByAppendingPathComponent("preference.plist")
        preferenceDict.bridgeToObjectiveC().writeToFile(path, atomically: true)
    }
    
    
    class func documentsDirectory() -> String{
        struct Static {
            static var instance : String? = nil
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            Static.instance = paths[0] as? String
        }
        return Static.instance!
    }
}

