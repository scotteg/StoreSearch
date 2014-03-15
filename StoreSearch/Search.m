//
//  Search.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/15/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>

// Class variable; static restricts its use to this class, i.e., it's not global, and also this is not actually necessary, because AFHTTPRequestOperation can be used without making a queue
static NSOperationQueue *queue = nil;

@interface Search ()
@property (strong, nonatomic, readwrite) NSMutableArray *searchResults;
@end

@implementation Search

+ (void)initialize
{
  if (self == [Search class]) {
    queue = [NSOperationQueue new];
  }
}

- (void)dealloc
{
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;
{
  if ([text length]) {
    [queue cancelAllOperations];
    
    self.isLoading = YES;
    self.searchResults = [NSMutableArray arrayWithCapacity:10];
    
    NSURL *url = [self urlWithSearchText:text category:category];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      [self parseDictionary:responseObject];
      [self.searchResults sortUsingSelector:@selector(compareArtistName:)];
      self.isLoading = NO;
      block(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [self showNetworkError];
      
      if (!operation.isCancelled) {
        self.isLoading = NO;
        block(NO);
      }
    }];
    
    [queue addOperation:operation];
  }
}

- (void)showNetworkError
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops..." message:@"There was an error reading from the iTunes Store. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alertView show];
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
    NSString *kind = resultDict[@"kind"];
    
    if ([wrapperType isEqualToString:@"track"]) {
      searchResult = [self parseTrack:resultDict];
    } else if ([wrapperType isEqualToString:@"audiobook"]) {
      searchResult = [self parseAudioBook:resultDict];
    } else if ([wrapperType isEqualToString:@"software"]) {
      searchResult = [self parseSoftware:resultDict];
    } else if ([kind isEqualToString:@"ebook"]) {
      searchResult = [self parseEBook:resultDict];
    }
    
    if (searchResult) {
      [self.searchResults addObject:searchResult];
    }
  }
}

- (SearchResult *)parseTrack:(NSDictionary *)dictionary
{
  SearchResult *searchResult = [SearchResult new];
  searchResult.name = dictionary[@"trackName"];
  searchResult.artistName = dictionary[@"artistName"];
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
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
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
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
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
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
  searchResult.artworkURL60 = dictionary[@"artworkUrl60"];
  searchResult.artworkURL100 = dictionary[@"artworkUrl100"];
  searchResult.storeURL = dictionary[@"trackViewUrl"];
  searchResult.kind = dictionary[@"kind"];
  searchResult.price = dictionary[@"price"];
  searchResult.currency = dictionary[@"currency"];
  searchResult.genre = [(NSArray *)dictionary[@"genres"] componentsJoinedByString:@", "];
  return searchResult;
}

@end
