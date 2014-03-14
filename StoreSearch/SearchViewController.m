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

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL isLoading;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation SearchViewController
{
  NSMutableArray *_searchResults;
  NSOperationQueue *_queue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _queue = [NSOperationQueue new];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.contentInset = UIEdgeInsetsMake(108.0f, 0.0f, 0.0f, 0.0f); // Search bar 64pt, segmented control 44pt
  
  UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
  cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
  cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
  
  self.tableView.rowHeight = 80.0f;
  
  [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)performSearch
{
  if ([self.searchBar.text length]) {
    [self.searchBar resignFirstResponder];
    [_queue cancelAllOperations];
    
    self.isLoading = YES;
    
    _searchResults = [NSMutableArray arrayWithCapacity:10];
    
    NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      [self parseDictionary:responseObject];
      [_searchResults sortUsingSelector:@selector(compareArtistName:)];
      self.isLoading = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (operation.isCancelled) {
        return;
      }
      
      [self showNetworkError];
      self.isLoading = NO;
    }];
    
    [_queue addOperation:operation];
  }
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
  if (_searchResults) {
    [self performSearch];
  }
}

- (void)setIsLoading:(BOOL)isLoading
{
  _isLoading = isLoading;
  [self.tableView reloadData];
}

- (void)parseDictionary:(NSDictionary *)dictionary
{
  NSArray *array = dictionary[@"results"];
  
  if (!array) {
    NSLog(@"Expected 'results' array");
    return;
  }
  
  for (NSDictionary *resultDict in array) {
    SearchResult *searchResult;
    NSString *wrapperType = resultDict[@"wrapperType"];
    
    if ([wrapperType isEqualToString:@"track"]) {
      searchResult = [self parseTrack:resultDict];
    } else if ([wrapperType isEqualToString:@"audiobook"]) {
      searchResult = [self parseAudioBook:resultDict];
    } else if ([wrapperType isEqualToString:@"software"]) {
      searchResult = [self parseSoftware:resultDict];
    } else if ([wrapperType isEqualToString:@"ebook"]) {
      searchResult = [self parseEBook:resultDict];
    }
    
    if (searchResult) {
      [_searchResults addObject:searchResult];
    }
  }
}

- (SearchResult *)parseTrack:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [SearchResult new];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkURL60"];
  searchResult.artworkURL100 = dictionary[@"artworkURL100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"trackPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}

- (SearchResult *)parseAudioBook:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [SearchResult new];
  searchResult.name = dictionary[@"collectionName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkURL60"];
  searchResult.artworkURL100 = dictionary[@"artworkURL100"];
  searchResult.storeURL = dictionary[@"collectionViewUrl"];
  searchResult.kind = @"audiobook";
  searchResult.price = dictionary[@"collectionPrice"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}

- (SearchResult *)parseSoftware:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [SearchResult new];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"trackURL60"];
  searchResult.artworkURL100 = dictionary[@"trackURL100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = dictionary[@"primaryGenreName"];
  return searchResult;
}

- (SearchResult *)parseEBook:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [SearchResult new];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"trackURL60"];
  searchResult.artworkURL100 = dictionary[@"trackURL100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = [(NSArray *)dictionary[@"genres"] componentsJoinedByString:@", "];
  return searchResult;
}

- (void)showNetworkError
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"There was an error reading from the iTunes Store. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alertView show];
}

- (NSString *)kindForDisplay:(NSString *)kind
{
  if ([kind isEqualToString:@"album"]) {
    return @"Album";
  } else if ([kind isEqualToString:@"audiobook"]) {
    return @"Audio Book";
  } else if ([kind isEqualToString:@"book"]) {
    return @"Book";
  } else if ([kind isEqualToString:@"ebook"]) {
    return @"E-Book";
  } else if ([kind isEqualToString:@"feature-movie"]) {
    return @"Movie";
  } else if ([kind isEqualToString:@"music-video"]) {
    return @"Music Video";
  } else if ([kind isEqualToString:@"podcast"]) {
    return @"Podcast";
  } else if ([kind isEqualToString:@"software"]) {
    return @"App";
  } else if ([kind isEqualToString:@"song"]) {
    return @"Song";
  } else if ([kind isEqualToString:@"tv-episode"]) {
    return @"TV Episode";
  } else {
    return kind;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (self.isLoading) {
    return 1;
  } else if (!_searchResults) {
    return 0;
  } else if ([_searchResults count] == 0) {
    return 1;
  } else {
    return [_searchResults count];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.isLoading) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
    [spinner startAnimating];
    return cell;
  } else if ([_searchResults count] == 0) {
    return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
  } else {
    SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
    SearchResult *searchResult = _searchResults[indexPath.row];
    cell.nameLabel.text = searchResult.name;
    
    NSString *artistName = searchResult.artistName;
    
    if (!artistName) {
      artistName = @"(Unknown)";
    }
    
    NSString *kind = [self kindForDisplay:searchResult.kind];
    cell.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
    
    return cell;
  }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([_searchResults count] == 0 || self.isLoading) {
  return nil;
  } else {
  return  indexPath;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category
{
  NSString *categoryName;
  
  switch (category) {
    case 0: categoryName = @""; break;
    case 1: categoryName = @"musicTrack"; break;
    case 2: categoryName = @"software"; break;
    case 3: categoryName = @"ebook"; break;
  }
  
  NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, categoryName];
  NSLog(@"urlString: %@", urlString);
  NSURL *url = [NSURL URLWithString:urlString];
  return url;
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
