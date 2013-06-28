//
//  ViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"

@interface MainViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    BOOL            _isDoubleZero;
    NSString*       _prefix;
    NSString*       _countryCode;
    NSString*       _number;
    
@private
    NSArray*  prefixArray;
    NSArray*  countryCodeArray;
    
    IBOutlet    UITextField*    inputTF;
    IBOutlet    UILabel*        resultLabel;
    IBOutlet    UIButton*       processBtn;
    IBOutlet    UITableView*    IDDTV;
    IBOutlet    UITableView*    countryCodeTV;
    
    SettingViewController* settingVC;
}

@property (nonatomic        ) BOOL			isDoubleZero;
@property (nonatomic, retain) NSString*	prefix;
@property (nonatomic, retain) NSString*  countryCode;
@property (nonatomic, retain) NSString*  number;


-(NSString*)getClipboardText;

-(NSString*)processNumberWithPrefix:(NSString*)prefix countryCode:(NSString*)countryCode number:(NSString*)number;

-(IBAction)processAction:(id)sender;

-(IBAction)hideAndProcess:(id)sender;
@end
