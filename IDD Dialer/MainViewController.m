//
//  ViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"

#define BACKGROUND_CHANGE_INTERVAL 3

#define PRETTY_FUNCTION [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:[NSString defaultCStringEncoding]]
#define isEmptyString(str) ((str == nil)|| [@"" isEqual:str])

@interface MainViewController()
@property (nonatomic, strong) WYPopoverController * iddPopoverController;
@property (nonatomic, strong) WYPopoverController * countryPopOverController;
@property (nonatomic, strong) NSArray * iddArray;
@property (nonatomic, strong) NSArray * countryArray;
@property (nonatomic, strong) ASCScreenBrightnessDetector * brightnessDetector;
@end

@implementation MainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.brightnessDetector = [[ASCScreenBrightnessDetector alloc] init];
    [self.brightnessDetector setDelegate:self];
    [[self.callBtn layer] setCornerRadius:40];
    [[self.iddBtn layer] setCornerRadius:6];
    [[self.countryBtn layer] setCornerRadius:6];
    settingVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fillInputWithClipboard) name:UIApplicationDidBecomeActiveNotification object:nil];
    
	self.iddSelectionViewController = [SelectorTableViewController new];
	self.countrySelectionViewController = [SelectorTableViewController new];
	[self.iddSelectionViewController setDelegate:self];
	[self.countrySelectionViewController setDelegate:self];
	[self checkButtonTitle];
    [self reloadInitialData];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.callBtn addGestureRecognizer:longPress];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]){
        [self call];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInitialData) name:@"settingBackPressed" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:BACKGROUND_CHANGE_INTERVAL target:self selector:@selector(changeBackgroundColor) userInfo:nil repeats:YES];
    
    [self setStyle:ASCScreenBrightnessStyleLight];
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
                          @"idd_data" ofType:@"plist"];
        
        self.iddArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    if(!self.countryArray || [self.countryArray count] == 0){
        path = [[NSBundle mainBundle] pathForResource:
                @"countryCode_data" ofType:@"plist"];
        
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
		[self.iddBtn setTitle:idd forState:UIControlStateNormal];
	}else{
		[self.iddBtn setTitle:@"IDD" forState:UIControlStateNormal];
	}
	if(self.countrySelectionViewController.selectedIndex!=-1){
		NSString * country = self.countryArray[self.countrySelectionViewController.selectedIndex][COUNTRY_NAME];
		[self.countryBtn setTitle:country forState:UIControlStateNormal];
	}else{
		[self.countryBtn setTitle:@"Country" forState:UIControlStateNormal];
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

-(IBAction)callAction:(id)sender{
    [self call];
}

-(void)call{
    NSLog(@"%@ calling %@",PRETTY_FUNCTION ,self.resultLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.resultLabel.text]]];
}

-(IBAction)longPressAction:(id)sender{
    if([(UILongPressGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan){
        NSLog(@"long press");
        ABRecordRef aContact = ABPersonCreate();
        CFErrorRef anError = NULL;
        const CFStringRef customLabel = CFSTR( "IDD" );
        ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        bool didAdd = ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)([self.inputTF.text copy]), customLabel, NULL);
        
        if (didAdd == YES)
        {
            ABRecordSetValue(aContact, kABPersonPhoneProperty, phone, &anError);
            if (anError == NULL)
            {
                ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
                picker.unknownPersonViewDelegate = self;
                picker.displayedPerson = aContact;
                picker.allowsAddingToAddressBook = YES;
                picker.allowsActions = YES;
                picker.title = @"Add an IDD Number";
                
                picker.alternateName = @"Choose one option below";
                UINavigationController * navC = [[UINavigationController alloc] initWithRootViewController:picker];
                UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
                [picker.navigationItem setRightBarButtonItem:doneBtn];
       
                [self presentViewController:navC animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not create unknown user"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        CFRelease(phone);
        CFRelease(aContact);
    }
}

-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSString *)clipboardText{
    NSString* clipboardText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    NSLog(@"clipboard = %@",clipboardText);
    return [self plainNumberByPhone:clipboardText];
}

-(void)fillInputWithClipboard{
    NSString* number = [self clipboardText];
    if(!isEmptyString(number)){
        [self.inputTF setText:number];
        [self process];
    }
}

-(void)process{
    [self.inputTF resignFirstResponder];
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

-(void)setStyle:(ASCScreenBrightnessStyle)style{
    [self.inputTF.layer setBorderWidth:1];
    switch (style) {
        case ASCScreenBrightnessStyleDark:
            [self.inputTF setTextColor:[UIColor whiteColor]];
            [self.inputTF.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [self.resultLabel setTextColor:[UIColor whiteColor]];
            [self.settingBtn setTitleColor:[UIColor colorWithRed:50.f/150.f green:79.f/150.f blue:133.f/150.f alpha:1] forState:UIControlStateNormal];
            break;
        case ASCScreenBrightnessStyleLight:
            [self.inputTF setTextColor:[UIColor blackColor]];
            [self.inputTF.layer setBorderColor:[[UIColor blackColor] CGColor]];
            [self.resultLabel setTextColor:[UIColor blackColor]];
            [self.settingBtn setTitleColor:[UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self changeBackgroundColor];
}
-(void)changeBackgroundColor{
    CGFloat offset;
    switch (self.brightnessDetector.screenBrightnessStyle) {
        case ASCScreenBrightnessStyleDark:
            offset = 0.25;
            break;
        case ASCScreenBrightnessStyleLight:
            offset = 0.86;
        default:
            break;
    }
    [UIView animateWithDuration:BACKGROUND_CHANGE_INTERVAL-.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^(void){
		[self.view setBackgroundColor:[UIColor colorWithRed:offset+((CGFloat)rand()/RAND_MAX)*0.1
													  green:offset+((CGFloat)rand()/RAND_MAX)*0.1
													   blue:offset+((CGFloat)rand()/RAND_MAX)*0.1 alpha:1]];} completion:nil];
}

#pragma mark - processing

- (BOOL)isInternationByPhone:(NSString*)phone{
    NSRange plusRange = [phone rangeOfString:@"+"];
    NSString * noIddPhone = [self removeIddByPhone:phone];
    NSRange zeroRange = [noIddPhone rangeOfString:@"00"];
    if(plusRange.location == 0 || zeroRange.location == 0){
        return YES;
    }
    return NO;
}

- (NSInteger)iddIndexByPhone:(NSString*)phone{
	NSInteger index = -1;
	if(!isEmptyString(phone) && phone.length > 5){
		NSString * plain = [self plainNumberByPhone:phone];
		for(NSDictionary* iddObj in self.iddArray){
			NSString * idd = iddObj[IDD];
			if([[plain substringToIndex:5] rangeOfString:idd].location != NSNotFound){
				index = [self.iddArray indexOfObject:iddObj];
                break;
			}
		}
	}
	NSLog(@"%@ index = %ld", PRETTY_FUNCTION, (long)index);
	return index;
}

- (NSInteger)countryIndexByPhone:(NSString*)phone{
	NSInteger index = -1;
	if(!isEmptyString(phone) && phone.length > 5){
       NSString * noIddPhone = [self removeIddByPhone:phone];
        BOOL isInternation = [self isInternationByPhone:phone];
		
		NSString * plain = [self noZeroNumberByPhone:[self plainNumberByPhone:noIddPhone]];
		for(NSDictionary* countryObj in self.countryArray){
			NSString * country = countryObj[COUNTRY_CODE];
            if(isInternation){
                NSRange range = NSMakeRange(0, 3);
                if([[plain substringWithRange:range] rangeOfString:country].location == 0){
                    index = [self.countryArray indexOfObject:countryObj];
                    break;
                }
            }
		}
	}
	NSLog(@"%@ index = %ld", PRETTY_FUNCTION, (long)index);
	return index;
}

- (NSString*)removeIddByPhone:(NSString*)phone{
    NSString * result = @"";
	NSInteger iddIndex = [self iddIndexByPhone:phone];
    if(iddIndex != -1){
		NSString * idd = self.iddArray[iddIndex][IDD];
		NSLog(@"%@ idd found = %@", PRETTY_FUNCTION, idd);
		result = [phone stringByReplacingOccurrencesOfString:idd withString:@""];
	}else{
		NSLog(@"%@ idd not found", PRETTY_FUNCTION);
        result = phone;
    }
    return result;
}

- (NSString*)numberByPhone:(NSString*)phone{
	NSInteger countryIndex = [self countryIndexByPhone:phone];
	NSString * result = [self plainNumberByPhone:phone];
	
    if(isEmptyString(result) || [result length] < 7){
		return result;
	}
    
	// remove idd
	result = [self removeIddByPhone:result];
	
	result = [self noZeroNumberByPhone:result];
    
	// remove country code
	if(countryIndex != -1){
		NSString * country = self.countryArray[countryIndex][COUNTRY_CODE];
		NSLog(@"%@ country found = %@", PRETTY_FUNCTION, country);
		result = [result stringByReplacingOccurrencesOfString:country withString:@""];
	}
    
	result = [self noZeroNumberByPhone:result];
    
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
        if(!isEmptyString(doubleZero)){
            doubleZero = [doubleZero stringByAppendingString:divider];
        }
		result = [NSString stringWithFormat:@"%@%@%@%@",outIdd,doubleZero,outCountry,number];
		
	}
	NSLog(@"%@ result = %@", PRETTY_FUNCTION, result);
	return result;
}

-(void)reloadOutputForScreenReloadSection:(BOOL)isReload{
	NSInteger indexIDD;
	NSInteger indexCC;
	if(isReload){
		indexIDD = [self iddIndexByPhone:self.inputTF.text];
		indexCC = [self countryIndexByPhone:self.inputTF.text];
		
		if(indexIDD != -1){
			[self.iddSelectionViewController setSelectedIndex:indexIDD];
		}
		if(indexCC != -1){
			[self.countrySelectionViewController setSelectedIndex:indexCC];
		}
		[self checkButtonTitle];
	}
    NSString* number = [self numberByPhone:self.inputTF.text];
	
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
    NSString * result = [self formattedPhoneByIdd:idd country:country number:number];
    NSLog(@"%@ Final Output = %@", PRETTY_FUNCTION,result);
	[self.resultLabel setText:result];
}


-(NSString*)plainNumberByPhone:(NSString*)phone{
	NSMutableString * number = [NSMutableString stringWithString:@""];
	if(!isEmptyString(phone)){
		for (int x = 0; x < [phone length]; x++) {
			unichar aChar = [phone characterAtIndex:x];
			if ((aChar >= '0' && aChar <= '9')) {
                [number appendString:[NSString stringWithCharacters:&aChar length:1]];
			}
		}
	}
	return number;
}

-(NSString*)noZeroNumberByPhone:(NSString*)phone{
    // remove first 0s
    NSString * result = phone;
    if(!isEmptyString(result)){
        BOOL haveZeroOnFirstCharater = YES;
        while (haveZeroOnFirstCharater) {
            unichar temp_firstChar = [result characterAtIndex:0];
            if(temp_firstChar != '0'){
                haveZeroOnFirstCharater = NO;
            }else{
                result = [result substringFromIndex:1];
            }
        }
        return result;
    }else{
        return @"";
    }
}

#pragma mark - textfield delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField{
	[tapGesture setEnabled:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self process];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
	[tapGesture setEnabled:NO];
}

- (IBAction)popSelection:(id)sender{
	WYPopoverController * popoverController;
	if(sender == self.iddBtn){
		if(!self.iddPopoverController){
			self.iddPopoverController = [[WYPopoverController alloc] initWithContentViewController:self.iddSelectionViewController];
		}else if([self.iddPopoverController isPopoverVisible]){
			return;
		}
		popoverController = self.iddPopoverController;
       
	}else if (sender == self.countryBtn){
		if(!self.countryPopOverController){
			self.countryPopOverController = [[WYPopoverController alloc] initWithContentViewController:self.countrySelectionViewController];
		}else if([self.countryPopOverController isPopoverVisible]){
			return;
		}
		popoverController = self.countryPopOverController;
	}
	popoverController.delegate = self;
	popoverController.passthroughViews = @[sender];
	popoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
	popoverController.wantsDefaultContentAppearance = NO;
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
	[self checkButtonTitle];
	[self processForSelectingCell];
}

-(void)selectorViewDidSelected:(SelectorTableViewController *)selectorView{
	if(selectorView == self.iddSelectionViewController){
		[self.iddPopoverController dismissPopoverAnimated:YES];
		[self popoverControllerDidDismissPopover:self.iddPopoverController];
	}else if (selectorView == self.countrySelectionViewController){
		[self.countryPopOverController dismissPopoverAnimated:YES];
		[self popoverControllerDidDismissPopover:self.countryPopOverController];
	}
}

#pragma mark - address book


-(IBAction)importAction:(id)sender{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
//    ABPersonViewController * personView = [[ABPersonViewController alloc] init];
//    [personView setAllowsEditing:NO];
//    [personView setAllowsActions:NO];
//    [personView setPersonViewDelegate:self];
//    [personView setDisplayedPerson:person];
//    [personView setDisplayedProperties:@[@(kABPersonPhoneProperty)]];
//    [peoplePicker pushViewController:personView animated:YES];
    
    return YES;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonPhoneProperty)
    {
        ABMultiValueRef numbers = ABRecordCopyValue(person, property);
        NSString* targetNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(numbers, ABMultiValueGetIndexForIdentifier(numbers, identifier));
        NSString *firstname = (__bridge NSString *)ABRecordCopyValue(person
                                                       , kABPersonFirstNameProperty);
        [self.inputTF setText:targetNumber];
        [self process];
        NSLog(@"%@ get imported number from %@ with %@", PRETTY_FUNCTION, firstname, targetNumber);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

-(BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES;
}

#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return YES;
}

#pragma mark - brightness

-(void)screenBrightnessStyleDidChange:(ASCScreenBrightnessStyle)style{
    NSLog(@"brightness has changed");
    [self setStyle:style];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    switch (self.brightnessDetector.screenBrightnessStyle) {
        case ASCScreenBrightnessStyleDark:
            return UIStatusBarStyleLightContent;
            break;
        case ASCScreenBrightnessStyleLight:
            return UIStatusBarStyleDefault;
        default:
            break;
    }
}

@end
