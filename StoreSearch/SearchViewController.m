//
//  SearchViewController.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/12/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import <AFNetworking/AFNetworking.h>
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation SearchViewController
{
  Search *_search;
  LandscapeViewController *_landscapeViewController;
  UIStatusBarStyle _statusBarStyle;
  DetailViewController *_detailViewController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.contentInset = UIEdgeInsetsMake(108.0f, 0.0f, 0.0f, 0.0f); // Search bar 64pt, segmented control 44pt
  self.tableView.rowHeight = 80.0f;
  _statusBarStyle = UIStatusBarStyleDefault;
  
  UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
  cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
  cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
  
  [self.searchBar becomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return _statusBarStyle;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
    [self hideLandscapeViewWithDuration:duration];
  } else {
    [self showLandscapeViewWithDuration:duration];
  }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
  if (!_landscapeViewController) {
    _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
    _landscapeViewController.view.frame = self.view.bounds;
    _landscapeViewController.view.alpha = 0.0f;
    _landscapeViewController.search = _search;
    
    [self.view addSubview:_landscapeViewController.view];
    [self addChildViewController:_landscapeViewController];
    
    [UIView animateWithDuration:duration animations:^{
      _landscapeViewController.view.alpha = 1.0f;
      
      _statusBarStyle = UIStatusBarStyleLightContent;
      [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
      [_landscapeViewController didMoveToParentViewController:self];
    }];
    
    [self.searchBar resignFirstResponder];
    [_detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
    _detailViewController = nil;
  }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
  if (_landscapeViewController) {
    [_landscapeViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:duration animations:^{
      _landscapeViewController.view.alpha = 0.0f;
      
      _statusBarStyle = UIStatusBarStyleDefault;
      [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
      [_landscapeViewController.view removeFromSuperview];
      [_landscapeViewController removeFromParentViewController];
      _landscapeViewController = nil;
    }];
    
    if (!_search.searchResults) {
      [self.searchBar becomeFirstResponder];
    }
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)performSearch
{
  _search = [Search new];
  NSLog(@"Allocated %@", _search);
  
  [_search performSearchForText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex completion:^(BOOL success) {
    if (success) {
      [_landscapeViewController searchResultsReceived];
      [self.tableView reloadData];
    }
  }];
  
  [self.tableView reloadData];
  [self.searchBar resignFirstResponder];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
  if (_search) {
    [self performSearch];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (!_search) {
    return 0;
  } else if (_search.isLoading) {
    return 1;
  } else if ([_search.searchResults count] == 0) {
    return 1;
  } else {
    return [_search.searchResults count];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (_search.isLoading) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
    [spinner startAnimating];
    return cell;
  } else if ([_search.searchResults count] == 0) {
    return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
  } else {
    SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
    SearchResult *searchResult = _search.searchResults[indexPath.row];
    [cell configureForSearchResult:searchResult];
    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([_search.searchResults count] == 0 || _search.isLoading) {
  return nil;
  } else {
  return  indexPath;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.searchBar resignFirstResponder];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  _detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
  
  _detailViewController.searchResult = _search.searchResults[indexPath.row];
  
  [_detailViewController presentInParentViewController:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self performSearch];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}

@end
