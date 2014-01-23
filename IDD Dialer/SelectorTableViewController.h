//
//  SelectorTableViewController.h
//  IDD Dialer
//
//  Created by Raymond Lee on 23/1/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectorTableViewController : UITableViewController

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray * dataSource;

-(id)initWithDataSource:(NSArray*)dataSource defaultValue:(NSString*)value;

@end
