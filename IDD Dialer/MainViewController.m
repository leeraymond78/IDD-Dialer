//
//  ViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "DiallingCodesHelper.h"
#import "GHContextMenuView.h"
#import "IDNumPadView.h"

#define BACKGROUND_CHANGE_INTERVAL 3

#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define isEmptyString(str) ((str == nil)|| [@"" isEqual:str])

@interface MainViewController()
@property (nonatomic, strong) WYPopoverController * iddPopoverController;
@property (nonatomic, strong) WYPopoverController * countryPopOverController;
@property (nonatomic, strong) NSArray * iddArray;
@property (nonatomic, strong) NSArray * countryArray;
@property (nonatomic, strong) ASCScreenBrightnessDetector * brightnessDetector;
@property (nonatomic)         ASCScreenBrightnessStyle brightnessStyle;
@property (nonatomic, strong) IDNumPadView * numpadView;
@end

@implementation MainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.brightnessDetector = [ASCScreenBrightnessDetector new];
    [self.brightnessDetector setDelegate:self];
    self.brightnessStyle = self.brightnessDetector.screenBrightnessStyle;
    [self setStyle];
    [[self.callBtn layer] setCornerRadius:45];
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
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]){
        [self call];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInitialData) name:@"settingBackPressed" object:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:BACKGROUND_CHANGE_INTERVAL target:self selector:@selector(changeBackgroundColor) userInfo:nil repeats:YES];
    
    GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.callBtn addGestureRecognizer:longPress];
    
    _numpadView = [[IDNumPadView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 400)];
    [self.inputTF setInputView:_numpadView];
    [_numpadView setTextField:self.inputTF];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:self.inputTF];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - methods

-(void)reloadInitialData{
    self.iddArray = [DiallingCodesHelper initialIDDs];
	self.countryArray = [DiallingCodesHelper initialCountryCodes];
    
	NSMutableArray * iddValueArray = [NSMutableArray new];
	for (NSDictionary * dict in self.iddArray) {
		[iddValueArray addObject:dict[IDD]];
	}
	NSMutableArray * countryValueArray = [NSMutableArray new];
    [DiallingCodesHelper countryNamesByCode];
	for (NSString * code in self.countryArray) {
		[countryValueArray addObject:[DiallingCodesHelper countryNameByCode:code]];
	}
    [self.iddSelectionViewController setPreferredContentSize:CGSizeMake(140,0)];
    [self.countrySelectionViewController setPreferredContentSize:CGSizeMake(250,0)];
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
		NSString * country = [DiallingCodesHelper countryNameByCode:self.countryArray[self.countrySelectionViewController.selectedIndex]];
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

-(IBAction)callAction:(id)sender{
    [self popUpViewAnimation:sender];
    [self call];
}

-(void)call{
    BLog(@"calling %@",self.resultLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.resultLabel.text]]];
}

-(void)addContactMenu{
        if(isEmptyString(self.resultLabel.text)){
            [[[UIAlertView alloc] initWithTitle:@"Oppps" message:@"Please generate a number to continue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        BLog(@"long press");
        ABRecordRef aContact = ABPersonCreate();
        CFErrorRef anError = NULL;
        const CFStringRef customLabel = CFSTR( "IDD" );
        ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        bool didAdd = ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)([self.resultLabel.text copy]), customLabel, NULL);
        
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oppps"
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

-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSString *)clipboardText{
    NSString* clipboardText = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"public.utf8-plain-text"];
    BLog(@"clipboard = %@",clipboardText);
    return [self plainNumberByPhone:clipboardText];
}

-(void)fillInputWithClipboard{
    if(isEmptyString(self.inputTF.text)){
        NSString* number = [self clipboardText];
        if(!isEmptyString(number)){
            [self.inputTF setText:number];
            [self process];
        }
    }
}

-(void)process{
	[self reloadOutputForScreenReloadSection:YES];
}

-(IBAction)hideAndProcess:(id)sender{
    [self.inputTF resignFirstResponder];
    [self process];
}

-(void)processForSelectingCell{
	[self reloadOutputForScreenReloadSection:NO];
}

-(void)showAlertViewWithTitle:(NSString*)title msg:(NSString*)msg{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

-(void)setStyle{
//    [self.inputTF.layer setBorderWidth:1];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.inputTF.placeholder];
    NSDictionary* attributes;
    switch (self.brightnessStyle) {
        case ASCScreenBrightnessStyleDark:
            [self.inputTF setTextColor:[UIColor colorWithWhite:.8 alpha:1]];
//            [self.inputTF.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            attributes = @{NSForegroundColorAttributeName:[UIColor colorWithWhite:.7f alpha:.8f]};
            [self.resultLabel setTextColor:[UIColor whiteColor]];
            [self.settingBtn setTitleColor:[UIColor colorWithRed:50.f/150.f green:79.f/150.f blue:133.f/150.f alpha:1] forState:UIControlStateNormal];
            break;
        case ASCScreenBrightnessStyleLight:
            [self.inputTF setTextColor:[UIColor colorWithWhite:.2 alpha:1]];
//            [self.inputTF.layer setBorderColor:[[UIColor blackColor] CGColor]];
            attributes = @{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.3f alpha:.5f]};
            [self.resultLabel setTextColor:[UIColor blackColor]];
            [self.settingBtn setTitleColor:[UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    [self.inputTF setAttributedPlaceholder:attributedString];
    [self.inputTF setNeedsDisplay];
    [[UIApplication sharedApplication] setStatusBarStyle:self.brightnessStyle==ASCScreenBrightnessStyleLight?UIStatusBarStyleDefault:UIStatusBarStyleLightContent animated:YES];
    [self changeBackgroundColor];
}
-(void)changeBackgroundColor{
    CGFloat offset;
    switch (self.brightnessStyle) {
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
	BLog(@"index = %ld", (long)index);
	return index;
}

- (NSInteger)countryIndexByPhone:(NSString*)phone{
	NSInteger index = -1;
	if(!isEmptyString(phone) && phone.length > 5){
       NSString * noIddPhone = [self removeIddByPhone:phone];
        BOOL isInternation = [self isInternationByPhone:phone];
		
		NSString * plain = [self noZeroNumberByPhone:[self plainNumberByPhone:noIddPhone]];
		for(NSString * code in self.countryArray){
			NSString * diallingCode = [DiallingCodesHelper diallingCodeByCode:code];
            if(isInternation){
                NSRange range = NSMakeRange(0, 3);
                if([[plain substringWithRange:range] rangeOfString:diallingCode].location == 0){
                    index = [self.countryArray indexOfObject:code];
                    break;
                }
            }
		}
	}
	BLog(@"index = %ld", (long)index);
	return index;
}

- (NSString*)removeIddByPhone:(NSString*)phone{
    NSString * result = @"";
	NSInteger iddIndex = [self iddIndexByPhone:phone];
    if(iddIndex != -1){
		NSString * idd = self.iddArray[iddIndex][IDD];
		BLog(@"idd found = %@", idd);
		result = [phone stringByReplacingOccurrencesOfString:idd withString:@""];
	}else{
		BLog(@"idd not found");
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
		NSString * country = [DiallingCodesHelper countryNameByCode:self.countryArray[countryIndex]];
		BLog(@"%country found = %@", country);
		result = [result stringByReplacingOccurrencesOfString:country withString:@""];
	}
    
	result = [self noZeroNumberByPhone:result];
    
	BLog(@"result = %@", result);
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
	BLog(@"result = %@", result);
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
		country = [DiallingCodesHelper diallingCodeByCode:self.countryArray[self.countrySelectionViewController.selectedIndex]];
	}
    NSString * result = [self formattedPhoneByIdd:idd country:country number:number];
    BLog(@"Final Output = %@",result);
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

-(void)textFieldDidChange{
    [self process];
}

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
    
    [self popUpViewAnimation:sender];
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
        BLog(@"get imported number from %@ with %@", firstname, targetNumber);
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
    BLog(@"brightness has changed");
    self.brightnessStyle = style;
    [self setStyle];
}

#pragma mark - animation 

-(void)popUpViewAnimation:(UIView*)view{
    CGAffineTransform transform= CGAffineTransformMakeScale(1.2, 1.2);
    [view setTransform:transform];
    [UIView animateWithDuration:0.15f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGAffineTransform transform= CGAffineTransformMakeScale(0.92, 0.92);
        [view setTransform:transform];
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration: 0.07f animations:^{
                CGAffineTransform transform= CGAffineTransformMakeScale(1.05, 1.05);
                [view setTransform:transform];
            } completion:^(BOOL finished){
                if(finished){
                    [UIView animateWithDuration: 0.07f animations:^{
                        CGAffineTransform transform= CGAffineTransformMakeScale(1, 1);
                        [view setTransform:transform];
                    } completion:^(BOOL finished){
                        if(finished){
                        }
                    }];
                }
            }];
        }
    }];
}

#pragma mark GHContextMenu


- (NSInteger) numberOfMenuItems
{
    return 3;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
    switch (index) {
        case 0:
            imageName = @"contextMenu_contacts@2x";
            break;
        case 1:
            imageName = @"contextMenu_add_user@2x";
            break;
        case 2:
            imageName = @"contextMenu_phone@2x";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    switch (selectedIndex) {
        case 0:
            [self importAction:nil];
            break;
        case 1:
            [self addContactMenu];
            break;
        case 2:
            [self callAction:nil];
            break;
        default:
            break;
    }
}

@end
