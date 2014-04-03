//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddIDDViewController.h"

@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UISwitch *onAppCallSwitch;
    BOOL isEditing;

    IBOutlet UIButton *backBtn;

    AddIDDViewController *addIDDVC;

    NSArray *sectionViewArray;
    NSArray *centerViewArray;
}

@end
