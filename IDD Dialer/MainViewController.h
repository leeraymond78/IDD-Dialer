//
//  ViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPopoverController.h"

@class SettingViewController;

#define IDD @"IDD"
#define IDD_WITH00 @"IDD00"
#define COUNTRY_CODE @"CC"
#define COUNTRY_NAME @"CN"

@interface MainViewController : UIViewController<UITextFieldDelegate, WYPopoverControllerDelegate>{
   
@private
    
    IBOutlet    UITextField*    inputTF;
    IBOutlet    UILabel*        resultLabel;
    IBOutlet    UIButton*       processBtn;
	IBOutlet	UIButton*		iddBtn;
	IBOutlet	UIButton*		countryBtn;
    
    SettingViewController* settingVC;
}

-(void)reloadInitialData;

-(NSString*)getClipboardText;

-(NSString*)processNumberWithIDD:(NSString*)idd countryCode:(NSString*)countryCode number:(NSString*)number;

-(IBAction)processAction:(id)sender;

-(IBAction)hideAndProcess:(id)sender;
@end
