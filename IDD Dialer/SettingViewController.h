//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "IDDDialer-Swift.h"
#import "AddIDDViewController.h"
#import "SelectorTableViewController.h"


@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SelectorTableViewControllerDelegate, UISearchBarDelegate> {
    
    BOOL isEditing;
    IBOutlet UISwitch *onAppCallSwitch;
    IBOutlet UIButton *backBtn;
    IBOutlet UISearchBar *searchBar;

    NSArray *sectionViewArray;
    NSArray *centerViewArray;
    
    AddIDDViewController *addIDDVC;
    SelectorTableViewController *preferenceViewController;
}

@end
