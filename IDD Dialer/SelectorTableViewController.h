//
//  SelectorTableViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 23/1/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IDNoSelection -1

@protocol SelectorTableViewControllerDelegate;

@interface SelectorTableViewController : UITableViewController {
    NSInteger _selectedIndex;
}

@property(nonatomic, retain) id <SelectorTableViewControllerDelegate> delegate;

@property(nonatomic) NSInteger selectedIndex;

@property(nonatomic, strong) NSArray *dataSource;

- (id)initWithDataSource:(NSArray *)dataSource defaultValue:(NSString *)value;

- (NSString *)selectedValue;

@end

@protocol SelectorTableViewControllerDelegate <NSObject>

@optional
- (void)selectorViewDidSelected:(SelectorTableViewController *)selectorView;

@end