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

#define IDD @"IDD"
#define IDD_WITH00 @"IDD00"
#define COUNTRY_CODE @"CC"
#define COUNTRY_NAME @"CN"
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    settingVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillInputTF) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setupInitialData];
    [self fillInputTF];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]){
        [self call];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - methods

-(void)setupInitialData{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"prefix" ofType:@"plist"];
    
    prefixArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:
            @"countryCode" ofType:@"plist"];
    
    countryCodeArray = [[NSMutableArray alloc] initWithContentsOfFile:path];}

-(id)getObjectFromArrayWithValue:(NSString*)value Key:(NSString*)key wantedKey:(NSString*)wantedKey array:(NSArray*)array{
    id result = nil;
    for(NSDictionary* dict in array){
        id dictFromKey = [dict objectForKey:key];
        if(dictFromKey){
            if([dictFromKey isEqualToString:value]){
                result = [dict objectForKey:wantedKey];
                break;
            }
        }
    }
    return result;
}
-(void)setDefaultSelections:(NSString*)number{
    NSInteger targetIndexIDD = 0;
    NSInteger targetIndexCC = 0;
    NSString* targetCountryCode;
    NSString* targetPrefix;
    if(number){
        NSRange range;// non-plain number
        if([number characterAtIndex:0] == '+'){
            range.location = 1;
        }else if([[number substringToIndex:2] isEqualToString:@"00"]){
            range.location = 2;
        }
        if(range.location == 1 || range.location == 2){
            for (int x = 3; x > 0; x--) {
                range.length = x;
                NSString* firstChars = [number substringWithRange:range];
                for(NSDictionary* countryCodeDict in countryCodeArray){
                    NSString* countryCode = [countryCodeDict objectForKey:COUNTRY_CODE];
                    if ([firstChars isEqualToString:countryCode]) {
                        targetCountryCode = countryCode;
                        targetIndexCC = [countryCodeArray indexOfObject:countryCodeDict];
                        break;
                    }
                }
            }
        }
        NSDictionary* infoDict = [self getInfoWithNumber:number];
        if(infoDict){//plain number
            targetCountryCode = [infoDict objectForKey:COUNTRY_CODE];
            targetPrefix = [infoDict objectForKey:IDD];
            
            for(NSDictionary* countryCodeDict in countryCodeArray){
                NSString* countryCode = [countryCodeDict objectForKey:COUNTRY_CODE];
                if ([targetCountryCode isEqualToString:countryCode]) {
                    targetIndexCC = [countryCodeArray indexOfObject:countryCodeDict];
                    break;
                }
            }
            for(NSDictionary* prefixDict in prefixArray){
                NSString* prefix = [prefixDict objectForKey:IDD];
                if ([targetPrefix isEqualToString:prefix]) {
                    targetIndexIDD = [prefixArray indexOfObject:prefixDict];
                    break;
                }
            }
        }
    }
    NSLog(@"selected idd for row %d %@, cc for row %d %@", targetIndexIDD,targetPrefix, targetIndexCC,targetCountryCode);
    [IDDTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:targetIndexIDD inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [countryCodeTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:targetIndexCC inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    

}

-(NSDictionary*)getInfoWithNumber:(NSString*)number{
    number = [self getNormalNumber:number];
    if(number){
        NSMutableDictionary* resultDict = nil;
        unichar firstChar = [number characterAtIndex:0];
        if([number length] == 8 && (firstChar == '3' || firstChar == '2' || firstChar == '6' || firstChar == '9')){
            resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"852",COUNTRY_CODE,
                          @"12593",IDD,nil];
        }else if([number length] == 11 && (firstChar == '1')){
            resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"86",COUNTRY_CODE,
                          @"1678",IDD,nil];
        }else if([number length] == 11 && (firstChar == '0')){
            resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"44",COUNTRY_CODE,
                          @"1678",IDD,nil];
        }else if([number length] == 10 && (firstChar == '0')){
            resultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"886",COUNTRY_CODE,
                          @"1678",IDD,nil];
        }
        return resultDict;
    }
    return nil;
}

-(IBAction)processAction:(id)sender{
    [self process];
    [self call];
}

-(void)call{
    NSLog(@"calling %@",resultLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",resultLabel.text]]];
}

-(NSString *)processNumberWithPrefix:(NSString *)prefix countryCode:(NSString *)countryCode number:(NSString *)number{
    NSString* result = @"";
    BOOL withDoubleZero = [[self getObjectFromArrayWithValue:prefix Key:IDD wantedKey:IDD_WITH00 array:prefixArray] boolValue];
    NSString* doubleZero = withDoubleZero?@"00":@"";
    
    NSString* finalNumber = [self changeNumberToPlainNumber:number];
    if(prefix && countryCode && ![finalNumber isEqualToString:@""]){
        result = [NSString stringWithFormat:@"%@-%@%@-%@",prefix,doubleZero,countryCode,finalNumber];
    }
    return result;
}

-(NSString*)changeNumberToPlainNumber:(NSString*)number{
    NSString* result = @"";
    if(number && [number length] >= 7){
        BOOL haveZeroOnFirstCharater = YES;
        NSRange range;
        if([number characterAtIndex:0] == '+'){
            range.location = 1;
        }else if([[number substringToIndex:2] isEqualToString:@"00"]){
            range.location = 2;
        }
        if(range.location == 1 || range.location == 2){
            for (int x = 3; x > 0; x--) {
                range.length = x;
                NSString* firstChars = [number substringWithRange:range];
                for(NSDictionary* countryCodeDict in countryCodeArray){
                    NSString* countryCode = [countryCodeDict objectForKey:COUNTRY_CODE];
                    if ([firstChars isEqualToString:countryCode]) {
                        number = [number substringFromIndex:range.location + x];
                        break;
                    }
                }
            }
        }
        if(![number isEqualToString:@""]){
            result = number;
            while (haveZeroOnFirstCharater) {
                unichar temp_firstChar = [result characterAtIndex:0];
                if(temp_firstChar != '0'){
                    haveZeroOnFirstCharater = NO;
                }else{
                    result = [result substringFromIndex:1];
                }
            }
        }
    }
    
    NSLog(@"plain = %@",result);
    return result;
}

-(NSString*)getNormalNumber:(NSString*)number{
    BOOL isValidNumber = YES;
    for (int x = 0; x < [number length]; x++) {
        unichar aChar = [number characterAtIndex:x];
        if (aChar == '+' || aChar == ' ' || aChar == '-' ||  (aChar >= '0' && aChar <= '9')) {
        }else{
            isValidNumber = NO;
        }
    }
    if(isValidNumber){
        number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
        number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        return number;
    }
    return nil;
}
-(NSString *)getClipboardText{
    NSString* clipboardText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    NSLog(@"clipboard = %@",clipboardText);
    return [self getNormalNumber:clipboardText];
}

-(void)fillInputTF{
    NSString* number = [self getClipboardText];
    if(number){
        [inputTF setText:[self getClipboardText]];
        [self processWithoutChecking:NO];
    }
}

-(void)process{
    [inputTF resignFirstResponder];
    if ([inputTF.text isEqualToString:@""]){
        [self showAlertViewWithTitle:@"Uh oh!" msg:@"Enter something plz >_<"];
        [resultLabel setText:@"Enter again plz~"];
    }else{
        [self processWithoutChecking:NO];
    }
}

-(void)processWithoutChecking:(BOOL)isFromCell{
    NSString* prefix;
    NSString* countryCode;
    NSString* normalNumber = [self getNormalNumber:inputTF.text];
    if(!isFromCell){
    [self setDefaultSelections:normalNumber];
    }
    [inputTF setText:normalNumber];
    prefix = [[[IDDTV cellForRowAtIndexPath:[IDDTV indexPathForSelectedRow]]textLabel]text];
    
    countryCode = [[countryCodeArray objectAtIndex:[countryCodeTV indexPathForSelectedRow].row] objectForKey:COUNTRY_CODE];
    
    [resultLabel setText:[self processNumberWithPrefix:prefix countryCode:countryCode number:normalNumber]];
}

-(IBAction)hideAndProcess:(id)sender{
    if([inputTF isFirstResponder]){
        [self process];
    }
}

-(void)processForSelectingCell{
    if([[inputTF text] isEqualToString:@""]){
        
    }else{
        [self processWithoutChecking:YES];
    }
}


-(void)showAlertViewWithTitle:(NSString*)title msg:(NSString*)msg{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"I got it" otherButtonTitles:nil];
    [alertView show];
}

-(IBAction)gotoSetting:(id)sender{
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromLeft;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache: YES];
    [self presentViewController:settingVC animated:NO completion:nil];
    [UIView commitAnimations];
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
        return [countryCodeArray count];
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
        [[cell textLabel] setText:[[prefixArray objectAtIndex:indexPath.row] objectForKey:IDD]];
    }else if(tableView == countryCodeTV){
        [[cell textLabel] setText:[[countryCodeArray objectAtIndex:indexPath.row] objectForKey:COUNTRY_NAME]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self processForSelectingCell];
}
@end
