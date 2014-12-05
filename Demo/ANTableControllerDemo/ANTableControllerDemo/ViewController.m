//
//  ViewController.m
//  ANTableControllerDemo
//
//  Created by Oksana Kovalchuk on 5/12/14.
//  Copyright (c) 2014 Oks. All rights reserved.
//

#import "ViewController.h"
#import "TableController.h"

@interface ViewController ()

@property (nonatomic, strong) TableController* controller;
@property (nonatomic, strong) UITableView* view;

@end

@implementation ViewController

- (void)loadView
{
    self.view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controller = [[TableController alloc] initWithTableView:self.view];
}

@end
