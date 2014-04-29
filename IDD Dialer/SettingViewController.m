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
#import "WYPopoverController.h"

@interface SettingViewController ()<WYPopoverControllerDelegate>{
    NSInteger selectedCell;
}
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UITextView *aboutView;
@property (nonatomic, strong) WYPopoverController * preferPopoverController;
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
    
    preferenceViewController = [SelectorTableViewController new];
    [preferenceViewController setDelegate:self];
    [preferenceViewController setPreferredContentSize:CGSizeMake(140, 0)];
    
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

- (IBAction)switchValueChanged:(id)sender {
    if (sender == onAppCallSwitch) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[onAppCallSwitch isOn]] forKey:@"isOnAppCall"];
    }
}

- (IBAction)addIDD:(id)sender {
    [self presentViewController:addIDDVC animated:YES completion:nil];
}

- (void)addIDDDone:(NSNotification *)notification {
    @synchronized (idds) {
        NSDictionary *infoDict = [notification userInfo];
        NSString *targetIDD = [infoDict objectForKey:IDD];
        if (![targetIDD isEqual:@""]) {
            for (NSDictionary *IDDDict in idds) {
                if ([[IDDDict objectForKey:IDD] isEqual:targetIDD]) {
                    return;
                }
            }
            [idds addObject:infoDict];
        }
    }
    [self.tableView reloadData];
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
    NSString *path = [[DiallingCodesHelper documentsDirectory] stringByAppendingPathComponent:@"IDDData.plist"];
    @synchronized (idds) {
        [idds writeToFile:path atomically:YES];
    }
    path = [[DiallingCodesHelper documentsDirectory] stringByAppendingPathComponent:@"CountryCodeData.plist"];
    @synchronized (countries) {
        [countries writeToFile:path atomically:YES];
    }
    path = [[DiallingCodesHelper documentsDirectory] stringByAppendingPathComponent:@"DisabledCountryCodeData.plist"];
    @synchronized (disabledCountries) {
        [disabledCountries sortUsingSelector:@selector(compare:)];
        [disabledCountries writeToFile:path atomically:YES];
    }
}

#pragma mark - delegates

- (void)popSelection:(NSIndexPath*)indexPath {
    if(!self.preferPopoverController){
        self.preferPopoverController =[[WYPopoverController alloc] initWithContentViewController:preferenceViewController];
    }
    if ([self.preferPopoverController isPopoverVisible]) {
        [self.preferPopoverController dismissPopoverAnimated:YES];
        return;
    }
    UIView * theView =[self.tableView cellForRowAtIndexPath:indexPath];
    selectedCell = indexPath.row;
    NSString * code = countries[selectedCell];
    NSString * preference = [DiallingCodesHelper preferenceByCode:code];
    NSInteger selectedIndex = -1;
    
    NSMutableArray *iddValueArray = [NSMutableArray new];
    for (NSUInteger x = 0 ; x < [idds count] ; x++) {
        NSDictionary * dict = idds[x];
        if([preference isEqual:dict[IDD]]){
            selectedIndex = x;
        }
        [iddValueArray addObject:dict[IDD]];
    }
    [preferenceViewController setSelectedIndex:selectedIndex];
    
    [preferenceViewController setDataSource:iddValueArray];
    self.preferPopoverController.delegate = self;
    self.preferPopoverController.passthroughViews = @[theView];
    self.preferPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
    self.preferPopoverController.wantsDefaultContentAppearance = NO;
    [self.preferPopoverController presentPopoverFromRect:theView.bounds
                                            inView:theView
                          permittedArrowDirections:WYPopoverArrowDirectionAny
                                          animated:YES
                                           options:WYPopoverAnimationOptionFadeWithScale];
}

- (void)selectorViewDidSelected:(SelectorTableViewController *)selectorView {
    if (selectorView == preferenceViewController) {
        [self.preferPopoverController dismissPopoverAnimated:YES];
        
        NSInteger selectedIndex = [preferenceViewController selectedIndex];
        if(selectedIndex != -1){
            NSString * code = countries[selectedCell];
            [DiallingCodesHelper setPreference:idds[selectedIndex][@"IDD"] code:code];
        }
    }
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
        @synchronized (idds) {
            numberOfRow = [idds count];
        }
    }
    else if (section == 1) {
        @synchronized (countries) {
            numberOfRow = [countries count];
        }
    }
    else if (section == 2) {
        @synchronized (disabledCountries) {
            numberOfRow = [disabledCountries count];
        }
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
        @synchronized (idds) {
            [idds removeObjectAtIndex:indexPath.row];
        }

        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    } else {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            @synchronized (countries) {
                @synchronized (disabledCountries) {
                    NSDictionary *removingObj = [countries objectAtIndex:indexPath.row];
                    [disabledCountries insertObject:removingObj atIndex:0];
                    [countries removeObjectAtIndex:indexPath.row];
                }
            }
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            @synchronized (countries) {
                @synchronized (disabledCountries) {
                    NSDictionary *removingObj = [disabledCountries objectAtIndex:indexPath.row];
                    [countries insertObject:removingObj atIndex:0];
                    [disabledCountries removeObjectAtIndex:indexPath.row];
                }
            }
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
        @synchronized (idds) {
            NSDictionary *removingObj = [idds objectAtIndex:sourceIndexPath.row];
            [idds removeObjectAtIndex:sourceIndexPath.row];
            [idds insertObject:removingObj atIndex:destinationIndexPath.row];
        }
    } else if (source != 0 && des != 0) {
        if (source == des) {
            @synchronized (source == 1 ? countries : disabledCountries) {
                NSMutableArray *tempSourceCountryArray = source == 1 ? countries : disabledCountries;
                NSDictionary *removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];
                [tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];
            [tempSourceCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];
            }
        } else {

            @synchronized (source == 1 ? countries : disabledCountries) {
                NSMutableArray *tempSourceCountryArray;
                NSMutableArray *tempDestinationCountryArray;
                tempSourceCountryArray = source == 1 ? countries : disabledCountries;
                tempDestinationCountryArray = des == 1 ? countries : disabledCountries;
                NSDictionary *removingObj = [tempSourceCountryArray objectAtIndex:sourceIndexPath.row];

                [tempDestinationCountryArray insertObject:removingObj atIndex:destinationIndexPath.row];

                [tempSourceCountryArray removeObjectAtIndex:sourceIndexPath.row];

            }
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
        @synchronized (idds) {
            [[cell textLabel] setText:[[idds objectAtIndex:indexPath.row] objectForKey:IDD]];
        }
    } else if (indexPath.section == 1) {
        @synchronized (countries) {
            [[cell textLabel] setText:[DiallingCodesHelper countryNameByCode:countries[indexPath.row]]];
        }
    } else if (indexPath.section == 2) {
        @synchronized (disabledCountries) {
            [[cell textLabel] setText:[DiallingCodesHelper countryNameByCode:disabledCountries[indexPath.row]]];
        }
    }
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        return YES;
    }else{
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self popSelection:indexPath];
}
@end
