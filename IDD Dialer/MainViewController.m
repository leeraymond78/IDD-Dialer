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

#define BACKGROUND_CHANGE_INTERVAL 3

#define PRETTY_FUNCTION [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:[NSString defaultCStringEncoding]]
#define isEmptyString(str) ((str == nil)|| [@"" isEqual:str])

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
    [[callBtn layer] setCornerRadius:40];
    [[iddBtn layer] setCornerRadius:6];
    [[countryBtn layer] setCornerRadius:6];
    
    settingVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillInputWithClipboard) name:UIApplicationDidBecomeActiveNotification object:nil];
    
	self.iddSelectionViewController = [SelectorTableViewController new];
	self.countrySelectionViewController = [SelectorTableViewController new];
	[self checkButtonTitle];
    [self reloadInitialData];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]){
        [self call];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInitialData) name:@"settingBackPressed" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:BACKGROUND_CHANGE_INTERVAL target:self selector:@selector(changeBackgroundColor) userInfo:nil repeats:YES];
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

-(NSDictionary*)getInfoWithNumber:(NSString*)number{
    number = [self plainNumberByPhone:number];
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
    NSLog(@"%@ calling %@",PRETTY_FUNCTION ,resultLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",resultLabel.text]]];
}

-(NSString*)plainNumberByPhone:(NSString*)phone{
	NSString * number = @"";
	if(!isEmptyString(phone)){
		char * numberStr = malloc([phone length]);
		numberStr[0] = '\0';
		for (int x = 0; x < [phone length]; x++) {
			unichar aChar = [phone characterAtIndex:x];
			if ((aChar >= '0' && aChar <= '9')) {
				numberStr[strlen(numberStr)] = aChar;
				numberStr[strlen(numberStr)+1] = '\0';
			}
		}
		number = [NSString stringWithCString:numberStr encoding:[NSString defaultCStringEncoding]];
	}
	return number;
}

-(NSString *)clipboardText{
    NSString* clipboardText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    NSLog(@"clipboard = %@",clipboardText);
    return [self plainNumberByPhone:clipboardText];
}

-(void)fillInputWithClipboard{
    NSString* number = [self clipboardText];
    if(number){
        [inputTF setText:number];
        [self process];
    }
}

-(void)process{
    [inputTF resignFirstResponder];
	[self reloadOutputForScreenReloadSection:YES];
}

-(IBAction)hideAndProcess:(id)sender{
    [self process];
}

-(void)processForSelectingCell{
	[self reloadOutputForScreenReloadSection:NO];
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

-(void)changeBackgroundColor{
    [UIView animateWithDuration:BACKGROUND_CHANGE_INTERVAL-.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void){
		[self.view setBackgroundColor:[UIColor colorWithRed:0.86+((CGFloat)rand()/RAND_MAX)*0.1
													  green:0.86+((CGFloat)rand()/RAND_MAX)*0.1
													   blue:0.86+((CGFloat)rand()/RAND_MAX)*0.1 alpha:1]];} completion:nil];
	
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


#pragma mark - processing

- (NSInteger)iddIndexByPhone:(NSString*)phone{
	NSInteger index = -1;
	if(!isEmptyString(phone) && phone.length > 5){
		NSString * plain = [self plainNumberByPhone:phone];
		for(NSDictionary* iddObj in self.iddArray){
			NSString * idd = iddObj[IDD];
			if([[plain substringToIndex:5] rangeOfString:idd].location != NSNotFound){
				index = [self.iddArray indexOfObject:iddObj];
			}
		}
	}
	NSLog(@"%@ index = %ld", PRETTY_FUNCTION, (long)index);
	return index;
}

- (NSInteger)countryIndexByPhone:(NSString*)phone{
	NSInteger index = -1;
	if(!isEmptyString(phone) && phone.length > 5){
		BOOL hasIdd = ([self iddIndexByPhone:phone] != -1);
		
		NSString * plain = [self plainNumberByPhone:phone];
		for(NSDictionary* countryObj in self.countryArray){
			NSString * country = countryObj[COUNTRY_CODE];
			NSRange range = hasIdd?NSMakeRange(3, 5):NSMakeRange(0, 3);
			if([[plain substringWithRange:range] rangeOfString:country].location != NSNotFound){
				index = [self.countryArray indexOfObject:countryObj];
			}
		}
	}
	NSLog(@"%@ index = %ld", PRETTY_FUNCTION, (long)index);
	return index;
}

- (NSString*)numberByPhone:(NSString*)phone{
	NSInteger iddIndex = [self iddIndexByPhone:phone];
	NSInteger countryIndex = [self countryIndexByPhone:phone];
	NSString * result = [self plainNumberByPhone:phone];
	
    if(isEmptyString(result) || [result length] < 7){
		return result;
	}
	
	// remove first 0s
	BOOL haveZeroOnFirstCharater = YES;
	while (haveZeroOnFirstCharater) {
		unichar temp_firstChar = [result characterAtIndex:0];
		if(temp_firstChar != '0'){
			haveZeroOnFirstCharater = NO;
		}else{
			result = [result substringFromIndex:1];
		}
	}
	
	// remove idd
	if(iddIndex != -1){
		NSString * idd = self.iddArray[iddIndex][IDD];
		NSLog(@"%@ idd found = %@", PRETTY_FUNCTION, idd);
		result = [result stringByReplacingOccurrencesOfString:idd withString:@""];
	}
	
	// remove country code
	if(countryIndex != -1){
		NSString * country = self.countryArray[countryIndex][COUNTRY_CODE];
		NSLog(@"%@ country found = %@", PRETTY_FUNCTION, country);
		result = [result stringByReplacingOccurrencesOfString:country withString:@""];
	}
	NSLog(@"%@ result = %@", PRETTY_FUNCTION, result);
	return result;
}

- (NSString*)phoneByIdd:(NSString*)idd country:(NSString*)country number:(NSString*)number{
	return [self _phoneByIdd:idd country:country number:number divider:@""];
}

- (NSString*)formattedPhoneByIdd:(NSString*)idd country:(NSString*)country number:(NSString*)number{
	return [self _phoneByIdd:idd country:country number:number divider:@"-"];
}

- (NSString*)_phoneByIdd:(NSString*)idd country:(NSString*)country number:(NSString*)number divider:(NSString*)divider{
	NSString* result = @"";
	divider = divider?divider:@"";
	NSString * outIdd = @"";
	NSString * outCountry = @"";
	if(!isEmptyString(number)){
		NSString* doubleZero = @"";
		if(!isEmptyString(idd)){
			BOOL withDoubleZero = [[self getObjectFromArrayWithValue:idd Key:IDD wantedKey:IDD_WITH00 array:self.iddArray] boolValue];
			doubleZero = withDoubleZero?@"00":@"";
			outIdd = [idd stringByAppendingString:divider];
		}
		if(!isEmptyString(country)){
			outCountry = [country stringByAppendingString:divider];
		}else{
			doubleZero = @"";
		}
		result = [NSString stringWithFormat:@"%@%@%@%@",idd,doubleZero,country,number];
		
	}
	NSLog(@"%@ result = %@", PRETTY_FUNCTION, result);
	return result;
}

-(void)reloadOutputForScreenReloadSection:(BOOL)isReload{
	NSInteger indexIDD;
	NSInteger indexCC;
	if(isReload){
		indexIDD = [self iddIndexByPhone:inputTF.text];
		indexCC = [self countryIndexByPhone:inputTF.text];
		
		if(indexIDD != -1){
			[self.iddSelectionViewController setSelectedIndex:indexIDD];
		}
		if(indexCC != -1){
			[self.countrySelectionViewController setSelectedIndex:indexCC];
		}
		[self checkButtonTitle];
	}
    NSString* number = [self numberByPhone:inputTF.text];
	
    NSString * idd = @"";
	NSString * country = @"";
	indexIDD = self.iddSelectionViewController.selectedIndex;
	indexCC = self.countrySelectionViewController.selectedIndex;
	if(self.iddSelectionViewController.selectedIndex != -1){
		idd = self.iddArray[self.iddSelectionViewController.selectedIndex][IDD];
	}
	if(self.countrySelectionViewController.selectedIndex != -1){
		country = self.countryArray[self.countrySelectionViewController.selectedIndex][COUNTRY_CODE];
	}
	[resultLabel setText:[self formattedPhoneByIdd:idd country:country number:number]];
}

@end
