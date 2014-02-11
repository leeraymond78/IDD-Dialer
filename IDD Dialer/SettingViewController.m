//
//  SettingViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController()
@property (nonatomic, strong) NSArray * iddArray;
@property (nonatomic, strong) NSArray * countryArray;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSArray * disabledCountryArray;
@end

@implementation SettingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addIDDDone:) name:@"AddIDDDone" object:nil];
    addIDDVC = [[AddIDDViewController alloc] initWithNibName:@"AddIDDViewController" bundle:nil];
	[self reloadInitialData];
}

-(void)viewWillAppear:(BOOL)animated{
    [onAppCallSiwtch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    path = [documentsDirectory stringByAppendingPathComponent:@"disabled_countryCode_data.plist"];
	
    self.disabledCountryArray = [NSArray arrayWithContentsOfFile:path];
}

-(IBAction)switchValueChanged:(id)sender{
    if(sender == onAppCallSiwtch){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[onAppCallSiwtch isOn]] forKey:@"isOnAppCall"];
    }
}

-(IBAction)addIDD:(id)sender{
    [self presentViewController:addIDDVC animated:YES completion:nil];
}

-(void)addIDDDone:(NSNotification*)notification{
    NSDictionary* infoDict = [notification userInfo];
    NSString* targetIDD = [infoDict objectForKey:IDD];
    if(![targetIDD isEqual:@""]){
        for(NSDictionary* IDDDict in self.iddArray){
            if([[IDDDict objectForKey:IDD] isEqual:targetIDD]){
                return;
            }
        }
        NSMutableArray* tempiddArray = [NSMutableArray arrayWithArray:self.iddArray];
        [tempiddArray addObject:infoDict];
        self.iddArray = tempiddArray;
        [self.tableView reloadData];
    }
}

-(IBAction)editTV:(id)sender{
    [self.tableView setEditing:!isEditing animated:YES];
    isEditing = !isEditing;
    [backbtn setHidden:isEditing];
    
}
-(IBAction)back:(id)sender{
    [self updatePlits];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingBackPressed" object:nil];
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache: YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView commitAnimations];
    
}

-(void)updatePlits{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"idd_data.plist"];
    [self.iddArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"countryCode_data.plist"];
    [self.countryArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"disabled_countryCode_data.plist"];
    [self.disabledCountryArray writeToFile:path atomically:YES];
}

#pragma mark - table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0){
		return @"IDD Codes";
	}else if(section == 1){
		return @"Country Codes - Enabled";
	}else if(section == 2){
		return @"Country Codes - Disabled";
	}
    return @"";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if(section == 1){
		return [self.countryArray count];
	}else if(section == 2){
		return [self.disabledCountryArray count];
	}
	return [self.iddArray count];
	
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==2){
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	NSInteger section = indexPath.section;
    if(section == 0){
        NSMutableArray* tempiddArray = [NSMutableArray arrayWithArray:self.iddArray];
        [tempiddArray removeObjectAtIndex:indexPath.row];
        self.iddArray = tempiddArray;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
    }else{
        if(editingStyle == UITableViewCellEditingStyleDelete){
            NSMutableArray* tempcountryArray = [NSMutableArray arrayWithArray:self.countryArray];
            NSMutableArray* tempdisabledCountryArray = [NSMutableArray arrayWithArray:self.disabledCountryArray];
            NSDictionary* removingObj = [tempcountryArray objectAtIndex:indexPath.row];
            [tempdisabledCountryArray insertObject:removingObj atIndex:0];
            self.disabledCountryArray = tempdisabledCountryArray;
            [tempcountryArray removeObjectAtIndex:indexPath.row];
            self.countryArray = tempcountryArray;
        }else if(editingStyle == UITableViewCellEditingStyleInsert){
            NSMutableArray* tempdisabledCountryArray = [NSMutableArray arrayWithArray:self.disabledCountryArray];
            NSMutableArray* tempcountryArray = [NSMutableArray arrayWithArray:self.countryArray];
            NSDictionary* removingObj = [tempdisabledCountryArray objectAtIndex:indexPath.row];
            [tempcountryArray insertObject:removingObj atIndex:0];
            self.countryArray = tempcountryArray;
            [tempdisabledCountryArray removeObjectAtIndex:indexPath.row];
            self.disabledCountryArray = tempdisabledCountryArray;
        }
//        [tableView reloadData];
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
	NSInteger source = sourceIndexPath.section;
	NSInteger des = destinationIndexPath.section;
    if(source == 0 && des == 0){
        NSMutableArray* tempiddArray = [NSMutableArray arrayWithArray:self.iddArray];
        NSDictionary* removingObj = [tempiddArray objectAtIndex:sourceIndexPath.row];
        [tempiddArray removeObjectAtIndex:sourceIndexPath.row];
        [tempiddArray insertObject:removingObj atIndex:destinationIndexPath.row];
        self.iddArray = tempiddArray;
    }else if (source != 0 && des != 0){
        if(source == des){
            NSMutableArray* tempSourceCountryArray = [NSMutableArray arrayWithArray:source == 1?self.countryArray:self.disabledCountryArray];
            NSDictionary* removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];
            [tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];
            [tempSourceCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];
            if(source == 1)
                self.countryArray = tempSourceCountryArray;
            if(source == 2)
                self.disabledCountryArray = tempSourceCountryArray;
        }else{
			NSMutableArray* tempSourceCountryArray;
			NSMutableArray* tempDestinationCountryArray;
			tempSourceCountryArray = [NSMutableArray arrayWithArray:source == 1?self.countryArray:self.disabledCountryArray];
			tempDestinationCountryArray = [NSMutableArray arrayWithArray:des==1?self.countryArray:self.disabledCountryArray];
			NSDictionary* removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];
			
			[tempDestinationCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];
			
			if(source == 1)
				self.countryArray = tempSourceCountryArray;
			if(source == 2)
				self.disabledCountryArray = tempSourceCountryArray;
			
			[tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];
			
			if(des == 1)
				self.countryArray = tempDestinationCountryArray;
			if(des == 2)
				self.disabledCountryArray = tempDestinationCountryArray;
        }
    }
	[tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
	[tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *MyIdentifier;
    MyIdentifier = indexPath.section==0?@"IDD":@"CC";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
        if(indexPath.section==0){
            [[cell textLabel] setTextColor:[UIColor colorWithRed:.5 green:.7 blue:.9 alpha:1.]];
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25]];
        }else{
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25]];
        }
        [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
        
        [cell setBackgroundColor:[UIColor darkGrayColor]];
    }
	if(indexPath.section==0){
		[[cell textLabel] setText:[[self.iddArray objectAtIndex:indexPath.row] objectForKey:IDD]];
	}else if(indexPath.section == 1){
		[[cell textLabel] setTextColor:[UIColor colorWithRed:.1 green:0.9 blue:0.2 alpha:1.]];
		[[cell textLabel] setText:[[self.countryArray objectAtIndex:indexPath.row] objectForKey:COUNTRY_NAME]];
	}else if(indexPath.section == 2){
		[[cell textLabel] setTextColor:[UIColor colorWithRed:1 green:.4 blue:.5 alpha:1.]];
		[[cell textLabel] setText:[[self.disabledCountryArray objectAtIndex:indexPath.row] objectForKey:COUNTRY_NAME]];
	}
    
    return cell;
}
@end
