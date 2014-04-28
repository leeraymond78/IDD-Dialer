//
//  IDD_Dialer_Tests.m
//  IDD Dialer Tests
//
//  Created by Raymond Lee on 11/2/14.
//  Copyright (c) 2014 RayCom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainViewController.h"

@interface IDD_Dialer_Tests : XCTestCase
@end

@implementation IDD_Dialer_Tests

MainViewController *main;

- (void)setUp {
    [super setUp];
    main = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [main view];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1 {
    [self testNumbersWithInput:@"+85264882201" iddIndex:0 countryIndex:0 output:@"1678-852-64882201"];
}

- (void)test2 {
    [self testNumbersWithInput:@"0085264882201" iddIndex:1 countryIndex:1 output:@"12593-00-86-64882201"];
}

- (void)test3 {
    [self testNumbersWithInput:@"+85264882201" iddIndex:-1 countryIndex:-1 output:@"64882201"];
}

- (void)test3_5 {
    [self testNumbersWithInput:@"008613537882288" iddIndex:0 countryIndex:0 output:@"1678-852-13537882288"];
}

- (void)test4 {
    [self testNumbersWithInput:@"1259300447932958585" iddIndex:0 countryIndex:0 output:@"1678-852-7932958585"];
}

- (void)test5 {
    [self testNumbersWithInput:@"1259300447932958585" iddIndex:1 countryIndex:5 output:@"12593-00-44-7932958585"];
}

- (void)test6 {
    [self testNumbersWithInput:@"+8613537882288" iddIndex:1 countryIndex:5 output:@"12593-00-44-13537882288"];
}

- (void)test7 {
    [self testNumbersWithInput:@"+8613537882288" iddIndex:0 countryIndex:1 output:@"1678-86-13537882288"];
}

- (void)test8 {
    [self testNumbersWithInput:@"+86 158-0848-8837" iddIndex:0 countryIndex:1 output:@"1678-86-15808488837"];
}

- (void)testNumbersWithInput:(NSString *)input iddIndex:(NSInteger)iddIndex countryIndex:(NSInteger)countryIndex output:(NSString *)output {
    [main.inputTF setText:input];
    [main textFieldShouldReturn:main.inputTF];
    [main.iddBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    [main.iddSelectionViewController tableView:main.iddSelectionViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:iddIndex inSection:0]];
    [main.countryBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    [main.countrySelectionViewController tableView:main.countrySelectionViewController.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:countryIndex inSection:0]];
    XCTAssertTrue([output isEqualToString:main.resultLabel.text], @"Assert Failed with input %@ output %@ actual %@", input, output, main.resultLabel.text);
}

@end
