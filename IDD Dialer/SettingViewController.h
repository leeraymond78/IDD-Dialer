//
//  SettingViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDDDialer-Swift.h"
#import "SelectorTableViewController.h"


@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SelectorTableViewControllerDelegate, UISearchBarDelegate> {
    IBOutlet UISwitch *onAppCallSwitch;
    BOOL isEditing;

    IBOutlet UIButton *backBtn;
    IBOutlet UISearchBar *searchBar;

    AddIDDViewController *addIDDVC;

    NSArray *sectionViewArray;
    NSArray *centerViewArray;
    SelectorTableViewController *preferenceViewController;
}

@end
