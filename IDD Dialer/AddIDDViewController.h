//
//  AddIDDViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@interface AddIDDViewController : UIViewController<UITextFieldDelegate>{
    UITextField* iddTF;
    UISwitch * with00Siwtch;
}

@property (nonatomic, retain) IBOutlet UITextField* iddTF;
@property (nonatomic, retain) IBOutlet UISwitch * with00Siwtch;

@end
