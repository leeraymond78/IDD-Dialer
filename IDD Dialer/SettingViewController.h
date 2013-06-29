//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface SettingViewController : MainViewController{
    IBOutlet UISwitch * onAppCallSiwtch;
    BOOL isEditing;
    
    IBOutlet UIButton * backbtn;
    
    NSArray* _disabledCountryCodeArray;
    
}

@property (nonatomic, retain) NSArray* disabledCountryCodeArray;

@end
