//
//  SelectorTableViewController.m
//  IDD Dialer
//
//  Created by Raymond Lee on 23/1/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

#import "SelectorTableViewController.h"

@interface SelectorTableViewController ()

@end

@implementation SelectorTableViewController

- (id)initWithDataSource:(NSArray *)dataSource defaultValue:(NSString *)value {
    self = [SelectorTableViewController new];
    self.dataSource = dataSource;
    self.selectedIndex = [self.dataSource indexOfObject:value];
    return self;
}

- (id)init {
    self = [super init];

    self.selectedIndex = IDNoSelection;

    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - public methods

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex + 1;
    [self.tableView reloadData];
}

- (NSInteger)selectedIndex {
    if (_selectedIndex == 0) {
        return IDNoSelection;
    } else if (_selectedIndex == IDNoSelection) {
        return IDNoSelection;
    } else {
        return _selectedIndex - 1;
    }
}

- (NSString *)selectedValue {
    if (_selectedIndex == IDNoSelection) {
        return nil;
    } else {
        NSString *result = _dataSource[_selectedIndex];
        return result;
    }
}

- (void)setDataSource:(NSArray *)dataSource {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:dataSource];
    [tempArray insertObject:@"None" atIndex:0];
    _dataSource = [[NSArray alloc] initWithArray:tempArray copyItems:YES];

    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width == 0 ? 200 : self.preferredContentSize.width, 30.f * (_dataSource ? _dataSource.count : 30));
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger num = self.dataSource ? self.dataSource.count : 0;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

        [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];

        [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
        [[cell textLabel] setTextColor:[UIColor redColor]];
    }
    if (_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *labelText;

    if ([self.dataSource count] > indexPath.row) {
        labelText = self.dataSource[indexPath.row];
    } else {
        labelText = @"";
    }
    [[cell textLabel] setText:labelText];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([[self delegate] respondsToSelector:@selector(selectorViewDidSelected:)]) {
        [[self delegate] selectorViewDidSelected:self];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
