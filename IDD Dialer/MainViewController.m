//
//  ViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize isDoubleZero    = _isDoubleZero;
@synthesize prefix          = _prefix;
@synthesize countryCode     = _countryCode;
@synthesize number          = _number;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupInitialData];
    [self setDefaultSelections];
    [self fillInputTF];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - methods

-(void)setupInitialData{
    countryCodeDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"852"   , @"Hong Kong",
                       @"86"    , @"China",
                       @"886"   , @"Taiwan",
                       @"81"    , @"Japan",
                       @"65"    , @"Singapore",
                       @"44"    , @"United Kingdom",
                       @"1"     , @"United State",
                       nil];
    prefixArray = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                   [NSNumber numberWithBool:NO]     ,@"1678",
                   [NSNumber numberWithBool:YES]    ,@"12593",
                   nil];
}

-(void)setDefaultSelections{
    [IDDTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
     [countryCodeTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(IBAction)processAction:(id)sender{
    [self process];
}

-(NSString *)processNumberWithPrefix:(NSString *)prefix countryCode:(NSString *)countryCode number:(NSString *)number{
    NSString* result = @"";
    BOOL withDoubleZero = [[prefixArray objectForKey:prefix] boolValue];
    NSString* doubleZero = withDoubleZero?@"00":@"";
    
    NSString* finalNumber = [self removeFirstZero:number];
    
    result = [NSString stringWithFormat:@"%@%@%@%@",prefix,doubleZero,countryCode,finalNumber];
    return result;
}

-(NSString*)removeFirstZero:(NSString*)number{
    NSString* result = @"";
    BOOL haveZeroOnFirstCharater = YES;
    if(![number isEqualToString:@""]){
        result = number;
        while (haveZeroOnFirstCharater) {
            unichar firstChar = [result characterAtIndex:0];
            if(firstChar != '0' && firstChar != '+'){
                haveZeroOnFirstCharater = NO;
            }else{
                result = [result substringFromIndex:1];
            }
        }
    }
    return result;
}

-(NSString *)getClipboardText{
    NSString* clipboardText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    NSLog(@"clipboard = %@",clipboardText);
    BOOL isValidNumber = YES;
    for (int x = 0; x < [clipboardText length]; x++) {
        unichar aChar = [clipboardText characterAtIndex:x];
        if (aChar == '+' || (aChar >= '0' && aChar <= '9')) {
        }else{
            isValidNumber = NO;
        }
    }
    if(isValidNumber)
        return clipboardText;
    return nil;
}

-(void)fillInputTF{
    [inputTF setText:[self getClipboardText]];
    [self processWithoutChecking];
}

-(void)process{
    [inputTF resignFirstResponder];
    if ([inputTF.text isEqualToString:@""]){
        [self showAlertViewWithTitle:@"Uh oh!" msg:@"Enter something plz >_<"];
        [resultLabel setText:@"Enter again plz~"];
    }else{
        [self processWithoutChecking];
    }
}

-(void)processWithoutChecking{
    NSString* prefix;
    NSString* countryCode;
    prefix = [[[IDDTV cellForRowAtIndexPath:[IDDTV indexPathForSelectedRow]]textLabel]text];
    
    NSString* countryCodeKey = [[[countryCodeTV cellForRowAtIndexPath:[countryCodeTV indexPathForSelectedRow]]textLabel]text];
    countryCode = [countryCodeDict objectForKey:countryCodeKey];
    [resultLabel setText:[self processNumberWithPrefix:prefix countryCode:countryCode number:inputTF.text]];
}

-(IBAction)hideAndProcess:(id)sender{
    if([inputTF isFirstResponder]){
        [self process];
    }
}

-(void)processForSelectingCell{
    if([[inputTF text] isEqualToString:@""]){
        
    }else{
        [self processWithoutChecking];
    }
}


-(void)showAlertViewWithTitle:(NSString*)title msg:(NSString*)msg{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"I got it" otherButtonTitles:nil];
    [alertView show];
}
#pragma mark - textfield delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self process];
    return YES;
}

#pragma mark - table view delegates


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == IDDTV){
        return [prefixArray count];
    }else if(tableView == countryCodeTV){
        return [countryCodeDict count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == IDDTV){
        return 1;
    }else if(tableView == countryCodeTV){
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier;
    MyIdentifier = tableView==IDDTV?@"IDD":@"CC";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
        if(tableView == IDDTV){
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30]];
        }else{            
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];
        }
        [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
        [[cell textLabel] setTextColor:[UIColor redColor]];
    }
    
    if(tableView == IDDTV){
        [[cell textLabel] setText:[[prefixArray allKeys] objectAtIndex:indexPath.row]];
    }else if(tableView == countryCodeTV){
        [[cell textLabel] setText:[[countryCodeDict allKeys] objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self processForSelectingCell];
}
@end
