//
//  AddIDDViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddIDDViewController : UIViewController <UITextFieldDelegate> {
    UITextField *iddTF;
    UISwitch *with00Siwtch;
}

@property(nonatomic, strong) IBOutlet UITextField *iddTF;
@property(nonatomic, strong) IBOutlet UISwitch *with00Siwtch;

@end
