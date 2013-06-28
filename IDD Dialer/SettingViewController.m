//
//  SettingViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [onAppCallSiwtch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchValueChanged:(id)sender{
    if(sender == onAppCallSiwtch){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[onAppCallSiwtch isOn]] forKey:@"isOnAppCall"];
    }
}
-(IBAction)back:(id)sender{
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache: YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView commitAnimations];
}
@end
