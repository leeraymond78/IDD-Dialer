//
//  ViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "MainViewController.h"

#import "SettingViewController.h"
#import "SelectorTableViewController.h"

@interface MainViewController()
@property (nonatomic, strong) SelectorTableViewController * iddSelectionViewController;
@property (nonatomic, strong) SelectorTableViewController * countrySelectionViewController;
@property (nonatomic, strong) WYPopoverController * iddPopoverController;
@property (nonatomic, strong) WYPopoverController * countryPopOverController;
@property (nonatomic, strong) NSArray * iddArray;
@property (nonatomic, strong) NSArray * countryArray;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
    settingVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillInputTF) name:UIApplicationDidBecomeActiveNotification object:nil];
    
	self.iddSelectionViewController = [SelectorTableViewController new];
	self.countrySelectionViewController = [SelectorTableViewController new];
	[self checkButtonTitle];
    [self reloadInitialData];
	
    [self fillInputTF];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]){
        [self call];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInitialData) name:@"settingBackPressed" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - methods

-(void)reloadInitialData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"idd_data.plist"];
    self.iddArray = [NSArray arrayWithContentsOfFile:path];
    path = [documentsDirectory stringByAppendingPathComponent:@"countryCode_data.plist"];
    self.countryArray = [NSArray arrayWithContentsOfFile:path];
    
        //write default
    if(!self.iddArray || [self.iddArray count] == 0){
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"idd" ofType:@"plist"];
        
        self.iddArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    if(!self.countryArray || [self.countryArray count] == 0){
        path = [[NSBundle mainBundle] pathForResource:
                @"countryCode" ofType:@"plist"];
        
        self.countryArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
	
	NSMutableArray * iddValueArray = [NSMutableArray new];
	for (NSDictionary * dict in self.iddArray) {
		[iddValueArray addObject:dict[IDD]];
	}
	NSMutableArray * countryValueArray = [NSMutableArray new];
	for (NSDictionary * dict in self.countryArray) {
		[countryValueArray addObject:dict[COUNTRY_NAME]];
	}
	[self.iddSelectionViewController setDataSource:iddValueArray];
	[self.countrySelectionViewController setDataSource:countryValueArray];
}

-(void)checkButtonTitle{
	if(self.iddSelectionViewController.selectedIndex!=-1){
		NSString * idd = self.iddArray[self.iddSelectionViewController.selectedIndex][IDD];
		[iddBtn setTitle:idd forState:UIControlStateNormal];
	}else{
		[iddBtn setTitle:@"IDD" forState:UIControlStateNormal];
	}
	if(self.countrySelectionViewController.selectedIndex!=-1){
		NSString * country = self.countryArray[self.countrySelectionViewController.selectedIndex][COUNTRY_NAME];
		[countryBtn setTitle:country forState:UIControlStateNormal];
	}else{
		[countryBtn setTitle:@"Country" forState:UIControlStateNormal];
	}
}

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
    NSInteger targetIndexIDD = -1;
    NSInteger targetIndexCC = -1;
    NSString* targetCountryCode;
    NSString* targetIDD;
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
                for(NSDictionary* countryCodeDict in self.countryArray){
                    NSString* countryCode = [countryCodeDict objectForKey:COUNTRY_CODE];
                    if ([firstChars isEqualToString:countryCode]) {
                        targetCountryCode = countryCode;
                        targetIndexCC = [self.countryArray indexOfObject:countryCodeDict];
                        break;
                    }
                }
            }
        }
        NSDictionary* infoDict = [self getInfoWithNumber:number];
        if(infoDict){//plain number
            targetCountryCode = [infoDict objectForKey:COUNTRY_CODE];
            targetIDD = [infoDict objectForKey:IDD];
            
            for(NSDictionary* countryCodeDict in self.countryArray){
                NSString* countryCode = [countryCodeDict objectForKey:COUNTRY_CODE];
                if ([targetCountryCode isEqualToString:countryCode]) {
                    targetIndexCC = [self.countryArray indexOfObject:countryCodeDict];
                    break;
                }
            }
            for(NSDictionary* iddDict in self.iddArray){
                NSString* idd = [iddDict objectForKey:IDD];
                if ([targetIDD isEqualToString:idd]) {
                    targetIndexIDD = [self.iddArray indexOfObject:iddDict];
                    break;
                }
            }
        }
    }
    NSLog(@"selected idd for row %d %@, cc for row %d %@", targetIndexIDD,targetIDD, targetIndexCC,targetCountryCode);
	if(targetIndexIDD != -1){
		[self.iddSelectionViewController setSelectedIndex:targetIndexIDD];
	}
	if(targetIndexCC != -1){
		[self.countrySelectionViewController setSelectedIndex:targetIndexCC];
	}
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
    [self call];
}

-(void)call{
    NSLog(@"calling %@",resultLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",resultLabel.text]]];
}

-(NSString *)processNumberWithIDD:(NSString *)idd countryCode:(NSString *)countryCode number:(NSString *)number{
    NSString* result = @"";
	NSString* doubleZero = @"";
	if(![@"" isEqualToString:idd]){
		BOOL withDoubleZero = [[self getObjectFromArrayWithValue:idd Key:IDD wantedKey:IDD_WITH00 array:self.iddArray] boolValue];
		doubleZero = withDoubleZero?@"00":@"";
		idd = [idd stringByAppendingString:@"-"];
    }
	if(![@"" isEqualToString:countryCode]){
		countryCode = [countryCode stringByAppendingString:@"-"];
	}else{
		doubleZero = @"";
	}
    NSString* finalNumber = [self changeNumberToPlainNumber:number];
    if(idd && countryCode && ![finalNumber isEqualToString:@""]){
        result = [NSString stringWithFormat:@"%@%@%@%@",idd,doubleZero,countryCode,finalNumber];
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
                for(NSDictionary* countryCodeDict in self.countryArray){
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
        [self showAlertViewWithTitle:@"Warning" msg:@"Please enter the number you want to dial"];
        [resultLabel setText:@"Please enter again"];
    }else{
        [self processWithoutChecking:NO];
    }
}

-(void)processWithoutChecking:(BOOL)isFromCell{
    NSString* normalNumber = [self getNormalNumber:inputTF.text];
    if(!isFromCell){
    [self setDefaultSelections:normalNumber];
    }
    [inputTF setText:normalNumber];
	
    NSString * idd = @"";
	NSString * country = @"";
	
	if(self.iddSelectionViewController.selectedIndex != -1){
		idd = self.iddArray[self.iddSelectionViewController.selectedIndex][IDD];
	}
	if(self.countrySelectionViewController.selectedIndex != -1){
		country = self.countryArray[self.countrySelectionViewController.selectedIndex][COUNTRY_CODE];
	}
	
    [resultLabel setText:[self processNumberWithIDD:idd
										   countryCode:country
												number:normalNumber]];
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

- (IBAction)popSelection:(id)sender{
	WYPopoverController * popoverController;
	if(sender == iddBtn){
		if(!self.iddPopoverController){
			self.iddPopoverController = [[WYPopoverController alloc] initWithContentViewController:self.iddSelectionViewController];
		}
		popoverController = self.iddPopoverController;
       
	}else if (sender == countryBtn){
		if(!self.countryPopOverController){
			self.countryPopOverController = [[WYPopoverController alloc] initWithContentViewController:self.countrySelectionViewController];
		}
		popoverController = self.countryPopOverController;
	}
	popoverController.delegate = self;
	popoverController.passthroughViews = @[sender];
	popoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
	popoverController.wantsDefaultContentAppearance = NO;
	[sender setEnabled:NO];
	[popoverController presentPopoverFromRect:((UIButton*)sender).bounds
									   inView:sender
					 permittedArrowDirections:WYPopoverArrowDirectionAny
									 animated:YES
									  options:WYPopoverAnimationOptionFadeWithScale];
}

#pragma mark - WYPopoverControllerDelegate


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
	[controller.passthroughViews[0] setEnabled:YES];
	[self checkButtonTitle];
	[self processForSelectingCell];
}

@end
