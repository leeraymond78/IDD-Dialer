//
//  ViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "WYPopoverController.h"
#import "SelectorTableViewController.h"

@class SettingViewController;

#define IDD @"IDD"
#define IDD_WITH00 @"IDD00"
#define COUNTRY_CODE @"CC"
#define COUNTRY_NAME @"CN"

@interface MainViewController : UIViewController<UITextFieldDelegate, WYPopoverControllerDelegate, SelectorTableViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate>{
   
@private
    IBOutlet	UITapGestureRecognizer * tapGesture;
    SettingViewController* settingVC;
}

@property (nonatomic, retain) IBOutlet        UIButton    *       callBtn;
@property (nonatomic, retain) IBOutlet		  UIButton    *		iddBtn;
@property (nonatomic, retain) IBOutlet        UIButton    *		countryBtn;
@property (nonatomic, retain) IBOutlet        UITextField *    inputTF;
@property (nonatomic, retain) IBOutlet        UILabel     *    resultLabel;
@property (nonatomic, retain) IBOutlet        UIButton    *    importBtn;
@property (nonatomic, strong) SelectorTableViewController * iddSelectionViewController;
@property (nonatomic, strong) SelectorTableViewController * countrySelectionViewController;

-(void)reloadInitialData;

-(NSString*)clipboardText;

-(IBAction)callAction:(id)sender;

-(IBAction)hideAndProcess:(id)sender;
@end

