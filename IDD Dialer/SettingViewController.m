//
//  SettingViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 29/6/13.
//  Copyright (c) 2013 RayCom. All rights reserved.
//

#import "SettingViewController.h"
#import "MainViewController.h"
#import "DiallingCodesHelper.h"

@interface SettingViewController ()
@property(nonatomic, strong) NSArray *iddArray;
@property(nonatomic, strong) NSArray *countryArray;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *disabledCountryArray;
@property(nonatomic, strong) IBOutlet UITextView *aboutView;
@end

@implementation SettingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!sectionViewArray) {
        NSMutableArray *tempSectionViewArray = [NSMutableArray new];
        NSMutableArray *tempCenterViewArray = [NSMutableArray new];

        for (NSInteger x = 0; x < [self numberOfSectionsInTableView:self.tableView]; x++) {
            UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [self tableView:self.tableView heightForHeaderInSection:x])];
            [sectionView setBackgroundColor:[UIColor clearColor]];
            UILabel *centerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 20)];
            [centerView setBackgroundColor:[self colorForHeaderInSection:x]];
            [centerView setTextAlignment:NSTextAlignmentCenter];
            [[centerView layer] setCornerRadius:10];
            [centerView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.f]];
            [centerView setTextColor:[UIColor whiteColor]];
            [centerView setText:[self tableView:self.tableView titleForHeaderInSection:x]];
            [sectionView addSubview:centerView];
            [centerView setCenter:CGPointMake(sectionView.frame.size.width / 2, sectionView.frame.size.height / 2)];
            [tempSectionViewArray addObject:sectionView];
            [tempCenterViewArray addObject:centerView];
        }
        sectionViewArray = [NSArray arrayWithArray:tempSectionViewArray];
        centerViewArray = [NSArray arrayWithArray:tempCenterViewArray];
    }
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] infoDictionary][(NSString *) kCFBundleVersionKey];
    [self.aboutView setText:[NSString stringWithFormat:@"\n\n\n \
                             IDD Dialer\
                             Developed by Raymond Lee\
                             Version:%@\
                             Build:%@", appVersion, buildNumber]];

    [onAppCallSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"isOnAppCall"] boolValue]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addIDDDone:) name:@"AddIDDDone" object:nil];
    addIDDVC = [[AddIDDViewController alloc] initWithNibName:@"AddIDDViewController" bundle:nil];
    [self reloadInitialData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self scrollViewDidScroll:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadInitialData {
    self.iddArray = [DiallingCodesHelper initialIDDs];
    self.countryArray = [DiallingCodesHelper initialCountryCodes];
    self.disabledCountryArray = [DiallingCodesHelper initialDisabledCountryCodes];
}

- (IBAction)switchValueChanged:(id)sender {
    if (sender == onAppCallSwitch) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[onAppCallSwitch isOn]] forKey:@"isOnAppCall"];
    }
}

- (IBAction)addIDD:(id)sender {
    [self presentViewController:addIDDVC animated:YES completion:nil];
}

- (void)addIDDDone:(NSNotification *)notification {
    NSDictionary *infoDict = [notification userInfo];
    NSString *targetIDD = [infoDict objectForKey:IDD];
    if (![targetIDD isEqual:@""]) {
        for (NSDictionary *IDDDict in self.iddArray) {
            if ([[IDDDict objectForKey:IDD] isEqual:targetIDD]) {
                return;
            }
        }
        NSMutableArray *tempiddArray = [NSMutableArray arrayWithArray:self.iddArray];
        [tempiddArray addObject:infoDict];
        self.iddArray = tempiddArray;
        [self.tableView reloadData];
    }
}

- (IBAction)editTV:(id)sender {
    [self.tableView setEditing:!isEditing animated:YES];
    isEditing = !isEditing;
    [backBtn setHidden:isEditing];
    [((UIBarButtonItem *) sender) setTitle:isEditing ? @"Done" : @"Edit"];
    [((UIBarButtonItem *) sender) setTintColor:isEditing ? [UIColor redColor] : nil];
}

- (IBAction)back:(id)sender {
    [self updatePlits];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingBackPressed" object:nil];
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:trans forView:[self.view window] cache:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView commitAnimations];

}

- (void)updatePlits {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"idd_data.plist"];
    [self.iddArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"countryCode_data.plist"];
    [self.countryArray writeToFile:path atomically:YES];
    path = [documentsDirectory stringByAppendingPathComponent:@"disabled_countryCode_data.plist"];
    self.disabledCountryArray = [self.disabledCountryArray sortedArrayUsingSelector:@selector(compare:)];
    [self.disabledCountryArray writeToFile:path atomically:YES];
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"IDD Codes";
    } else if (section == 1) {
        return @"Country Codes - Enabled";
    } else if (section == 2) {
        return @"Country Codes - Disabled";
    }
    return @"";
}

- (UIColor *)colorForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [UIColor colorWithRed:.5 green:.7 blue:.9 alpha:1.];
    } else if (section == 1) {
        return [UIColor colorWithRed:.1 green:0.9 blue:0.2 alpha:1.];
    } else if (section == 2) {
        return [UIColor colorWithRed:1 green:.4 blue:.5 alpha:1.];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return sectionViewArray[section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UIView *sectionView in sectionViewArray) {
        NSInteger section = [sectionViewArray indexOfObject:sectionView];

        CGFloat offset = [sectionView frame].origin.y - scrollView.contentOffset.y;
        if (offset < 0) {
            offset = 0;
        } else if (offset >= 80) {
            offset = 80.f;
        }
        UIView *centerView = centerViewArray[section];
        CGRect frame = [centerView frame];
        frame.size.width = 160.f + (offset * 0.5f);
        [centerView setFrame:frame];
        [centerView setAlpha:1.f - offset * 0.3f / 80.f];
        [centerView setCenter:CGPointMake([sectionView frame].size.width / 2, [sectionView frame].size.height / 2)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRow = 0;
    if (section == 0) {
        numberOfRow = [self.iddArray count];
    }
    else if (section == 1) {
        numberOfRow = [self.countryArray count];
    }
    else if (section == 2) {
        numberOfRow = [self.disabledCountryArray count];
    }
    if (numberOfRow == 0) {
        [sectionViewArray[section] setHidden:YES];
    } else {
        [sectionViewArray[section] setHidden:NO];
    }
    return numberOfRow;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 0) {
        NSMutableArray *tempiddArray = [NSMutableArray arrayWithArray:self.iddArray];
        [tempiddArray removeObjectAtIndex:indexPath.row];
        self.iddArray = tempiddArray;

        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    } else {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSMutableArray *tempCountryArray = [NSMutableArray arrayWithArray:self.countryArray];
            NSMutableArray *tempDisabledCountryArray = [NSMutableArray arrayWithArray:self.disabledCountryArray];
            NSDictionary *removingObj = [tempCountryArray objectAtIndex:indexPath.row];
            [tempDisabledCountryArray insertObject:removingObj atIndex:0];
            self.disabledCountryArray = tempDisabledCountryArray;
            [tempCountryArray removeObjectAtIndex:indexPath.row];
            self.countryArray = tempCountryArray;
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            NSMutableArray *tempdisabledCountryArray = [NSMutableArray arrayWithArray:self.disabledCountryArray];
            NSMutableArray *tempcountryArray = [NSMutableArray arrayWithArray:self.countryArray];
            NSDictionary *removingObj = [tempdisabledCountryArray objectAtIndex:indexPath.row];
            [tempcountryArray insertObject:removingObj atIndex:0];
            self.countryArray = tempcountryArray;
            [tempdisabledCountryArray removeObjectAtIndex:indexPath.row];
            self.disabledCountryArray = tempdisabledCountryArray;
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSInteger source = sourceIndexPath.section;
    NSInteger des = destinationIndexPath.section;
    if (source == 0 && des == 0) {
        NSMutableArray *tempIDDArray = [NSMutableArray arrayWithArray:self.iddArray];
        NSDictionary *removingObj = [tempIDDArray objectAtIndex:sourceIndexPath.row];
        [tempIDDArray removeObjectAtIndex:sourceIndexPath.row];
        [tempIDDArray insertObject:removingObj atIndex:destinationIndexPath.row];
        self.iddArray = tempIDDArray;
    } else if (source != 0 && des != 0) {
        if (source == des) {
            NSMutableArray *tempSourceCountryArray = [NSMutableArray arrayWithArray:source == 1 ? self.countryArray : self.disabledCountryArray];
            NSDictionary *removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];
            [tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];
            [tempSourceCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];
            if (source == 1)
                self.countryArray = tempSourceCountryArray;
            if (source == 2)
                self.disabledCountryArray = tempSourceCountryArray;
        } else {
            NSMutableArray *tempSourceCountryArray;
            NSMutableArray *tempDestinationCountryArray;
            tempSourceCountryArray = [NSMutableArray arrayWithArray:source == 1 ? self.countryArray : self.disabledCountryArray];
            tempDestinationCountryArray = [NSMutableArray arrayWithArray:des == 1 ? self.countryArray : self.disabledCountryArray];
            NSDictionary *removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];

            [tempDestinationCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];

            if (source == 1)
                self.countryArray = tempSourceCountryArray;
            if (source == 2)
                self.disabledCountryArray = tempSourceCountryArray;

            [tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];

            if (des == 1)
                self.countryArray = tempDestinationCountryArray;
            if (des == 2)
                self.disabledCountryArray = tempDestinationCountryArray;
        }
    }
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier;
    MyIdentifier = indexPath.section == 0 ? @"IDD" : @"CC";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        if (indexPath.section == 0) {
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:26]];
        } else {
            [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:25]];
        }
        [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
        [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];

        [cell setBackgroundColor:[UIColor clearColor]];
    }
    [[cell textLabel] setTextColor:[self colorForHeaderInSection:indexPath.section]];
    if (indexPath.section == 0) {
        [[cell textLabel] setText:[[self.iddArray objectAtIndex:indexPath.row] objectForKey:IDD]];
    } else if (indexPath.section == 1) {
        [[cell textLabel] setText:[DiallingCodesHelper countryNameByCode:self.countryArray[indexPath.row]]];
    } else if (indexPath.section == 2) {
        [[cell textLabel] setText:[DiallingCodesHelper countryNameByCode:self.disabledCountryArray[indexPath.row]]];
    }

    return cell;
}
@end
