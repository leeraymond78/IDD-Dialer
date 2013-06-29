//
//  ViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingViewController;

#define IDD @"IDD"
#define IDD_WITH00 @"IDD00"
#define COUNTRY_CODE @"CC"
#define COUNTRY_NAME @"CN"

@interface MainViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{

    
    IBOutlet    UITableView*    IDDTV;
    IBOutlet    UITableView*    countryCodeTV;
    
@private
    NSArray*  _prefixArray;
    NSArray*  _countryCodeArray;
    
    IBOutlet    UITextField*    inputTF;
    IBOutlet    UILabel*        resultLabel;
    IBOutlet    UIButton*       processBtn;
    
    SettingViewController* settingVC;
}

@property (nonatomic, retain) NSArray* prefixArray;

@property (nonatomic, retain) NSArray* countryCodeArray;

-(void)reloadInitialData;

-(NSString*)getClipboardText;

-(NSString*)processNumberWithPrefix:(NSString*)prefix countryCode:(NSString*)countryCode number:(NSString*)number;

-(IBAction)processAction:(id)sender;

-(IBAction)hideAndProcess:(id)sender;
@end
