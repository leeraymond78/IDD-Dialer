//
//  AddIDDViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "AddIDDViewController.h"

@implementation AddIDDViewController

@synthesize iddTF;
@synthesize with00Siwtch;

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

-(void)viewDidAppear:(BOOL)animated{
    [iddTF becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)hideAndBack:(id)sender{
    NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              iddTF.text, @"IDD",
                              [NSNumber numberWithBool:[self.with00Siwtch isOn]], @"IDD00",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddIDDDone" object:nil userInfo:infoDict];
    [iddTF resignFirstResponder];
    [iddTF setText:@""];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
