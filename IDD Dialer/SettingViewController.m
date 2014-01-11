//
//  SettingViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "SettingViewController.h"

@implementation SectionView

-(void)setSectionTitle:(NSString*)title{
    [titleLabel setText:title];
}

@end

@implementation SettingViewController

@synthesize disabledCountryCodeArray = _disabledCountryCodeArray;

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
    [super reloadInitialData];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"disabled_countryCode_data.plist"];
    self.disabledCountryCodeArray = [NSArray arrayWithContentsOfFile:path];
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
        for(NSDictionary* IDDDict in self.prefixArray){
            if([[IDDDict objectForKey:IDD] isEqual:targetIDD]){
                return;
            }
        }
        NSMutableArray* tempPrefixArray = [NSMutableArray arrayWithArray:self.prefixArray];
        [tempPrefixArray addObject:infoDict];
        self.prefixArray = tempPrefixArray;
        [IDDTV reloadData];
    }
}

-(IBAction)editTV:(id)sender{
    [IDDTV setEditing:!isEditing animated:YES];
    [countryCodeTV setEditing:!isEditing animated:YES];
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
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"prefix_data.plist"];
    [self.prefixArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"countryCode_data.plist"];
    [self.countryCodeArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"disabled_countryCode_data.plist"];
    [self.disabledCountryCodeArray writeToFile:path atomically:YES];
}

#pragma mark - table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(countryCodeTV == tableView){
        return 2;
    }
    return [super numberOfSectionsInTableView:tableView];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(tableView == IDDTV){
        return sectionViewIDD;
    }else if(tableView == countryCodeTV){
        if(section == 0){
            return sectionViewCCE;
        }else if(section == 1){
            return sectionViewCCD;
        }
    }
    return nil;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(countryCodeTV == tableView){
        if(section == 0){
            return @"Enabled";
        }else if(section == 1){
            return @"Disabled";
        }
    }
    return @"";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == countryCodeTV){
        if(section == 0){
            return [self.countryCodeArray count];
        }else if(section == 1){
            return [self.disabledCountryCodeArray count];
        }
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == IDDTV){
        return UITableViewCellEditingStyleDelete;
    }else{
        return (indexPath.section == 0) ?  UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleInsert;
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == IDDTV){
        NSMutableArray* tempPrefixArray = [NSMutableArray arrayWithArray:self.prefixArray];
        [tempPrefixArray removeObjectAtIndex:indexPath.row];
        self.prefixArray = tempPrefixArray;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
    }else{
        if(editingStyle == UITableViewCellEditingStyleDelete){
            NSMutableArray* tempCountryCodeArray = [NSMutableArray arrayWithArray:self.countryCodeArray];
            NSMutableArray* tempDisabledCountryCodeArray = [NSMutableArray arrayWithArray:self.disabledCountryCodeArray];
            NSDictionary* removingObj = [tempCountryCodeArray objectAtIndex:indexPath.row];
            [tempDisabledCountryCodeArray insertObject:removingObj atIndex:0];
            self.disabledCountryCodeArray = tempDisabledCountryCodeArray;
            [tempCountryCodeArray removeObjectAtIndex:indexPath.row];
            self.countryCodeArray = tempCountryCodeArray;
        }else if(editingStyle == UITableViewCellEditingStyleInsert){
            NSMutableArray* tempDisabledCountryCodeArray = [NSMutableArray arrayWithArray:self.disabledCountryCodeArray];
            NSMutableArray* tempCountryCodeArray = [NSMutableArray arrayWithArray:self.countryCodeArray];
            NSDictionary* removingObj = [tempDisabledCountryCodeArray objectAtIndex:indexPath.row];
            [tempCountryCodeArray insertObject:removingObj atIndex:0];
            self.countryCodeArray = tempCountryCodeArray;
            [tempDisabledCountryCodeArray removeObjectAtIndex:indexPath.row];
            self.disabledCountryCodeArray = tempDisabledCountryCodeArray;
        }
        [tableView reloadData];
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if(tableView == IDDTV){
        NSMutableArray* tempPrefixArray = [NSMutableArray arrayWithArray:self.prefixArray];
        NSDictionary* removingObj = [tempPrefixArray objectAtIndex:sourceIndexPath.row];
        [tempPrefixArray removeObjectAtIndex:sourceIndexPath.row];
        [tempPrefixArray insertObject:removingObj atIndex:destinationIndexPath.row];
        self.prefixArray = tempPrefixArray;
    }else{
        if(sourceIndexPath.section == destinationIndexPath.section){
            NSMutableArray* tempSourceCountryCodeArray = [NSMutableArray arrayWithArray:sourceIndexPath.section == 0?self.countryCodeArray:self.disabledCountryCodeArray];
            NSDictionary* removingObj = [tempSourceCountryCodeArray objectAtIndex:sourceIndexPath.row];
            [tempSourceCountryCodeArray removeObjectAtIndex:sourceIndexPath.row];
            [tempSourceCountryCodeArray insertObject:removingObj atIndex:destinationIndexPath.row];
            if(sourceIndexPath.section == 0)
                self.countryCodeArray = tempSourceCountryCodeArray;
            if(sourceIndexPath.section == 1)
                self.disabledCountryCodeArray = tempSourceCountryCodeArray;
            
        }else{
        NSMutableArray* tempSourceCountryCodeArray;
        NSMutableArray* tempDistinationCountryCodeArray;
        tempSourceCountryCodeArray = [NSMutableArray arrayWithArray:sourceIndexPath.section == 0?self.countryCodeArray:self.disabledCountryCodeArray];
        tempDistinationCountryCodeArray = [NSMutableArray arrayWithArray:destinationIndexPath.section==0?self.countryCodeArray:self.disabledCountryCodeArray];
        NSDictionary* removingObj = [tempSourceCountryCodeArray objectAtIndex:sourceIndexPath.row];
        
        [tempDistinationCountryCodeArray insertObject:removingObj atIndex:destinationIndexPath.row];
        
        if(sourceIndexPath.section == 0)
            self.countryCodeArray = tempSourceCountryCodeArray;
        if(sourceIndexPath.section == 1)
            self.disabledCountryCodeArray = tempSourceCountryCodeArray;
        
        [tempSourceCountryCodeArray removeObjectAtIndex:sourceIndexPath.row];
        
        if(destinationIndexPath.section == 0)
            self.countryCodeArray = tempDistinationCountryCodeArray;
        if(destinationIndexPath.section == 1)
            self.disabledCountryCodeArray = tempDistinationCountryCodeArray;
        }
    }
    [tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(tableView == countryCodeTV && indexPath.section == 1){
        [[cell textLabel] setText:[[self.disabledCountryCodeArray objectAtIndex:indexPath.row] objectForKey:COUNTRY_NAME]];
    }
    return cell;
}
@end
