//
//  MenuViewController.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/16/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "MenuViewController.h"
#import "DetailViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.preferredContentSize = CGSizeMake(320.0f, 202.0f);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  if (indexPath.row == 0) {
    cell.textLabel.text = NSLocalizedString(@"Send Support Email", @"Menu: Email support");
  } else if (indexPath.row == 1) {
    cell.textLabel.text = NSLocalizedString(@"Rate This App", @"Menu: Rate app");
  } else {
    cell.textLabel.text = NSLocalizedString(@"About", @"Menu: About");
  }
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (indexPath.row == 0) {
    [self.detailViewController sendSupportEmail];
  }
}

@end
