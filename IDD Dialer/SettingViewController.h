//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AddIDDViewController.h"

@interface SectionView : UIView{
    IBOutlet UILabel* titleLabel;
}

@end

@interface SettingViewController : MainViewController{
    IBOutlet UISwitch * onAppCallSiwtch;
    BOOL isEditing;
    
    IBOutlet UIButton * backbtn;
    
    NSArray* _disabledCountryCodeArray;
    
    AddIDDViewController * addIDDVC;
    
    IBOutlet SectionView* sectionViewIDD;
    IBOutlet SectionView* sectionViewCCE;
    IBOutlet SectionView* sectionViewCCD;
    
}

@property (nonatomic, retain) NSArray* disabledCountryCodeArray;

@end
