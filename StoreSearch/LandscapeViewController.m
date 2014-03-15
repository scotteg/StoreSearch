//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "UIImage+Resize.h"
#import "Search.h"

@interface LandscapeViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation LandscapeViewController
{
  BOOL _firstTime;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _firstTime = YES;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
  self.scrollView.contentSize = CGSizeMake(1000.0f, CGRectGetHeight(self.scrollView.bounds));
  self.pageControl.numberOfPages = 0;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  if (_firstTime) {
    _firstTime = NO;
    [self tileButtons];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
  NSLog(@"%s", __PRETTY_FUNCTION__);
  
  for (UIButton *button in self.scrollView.subviews) {
    [button cancelImageRequestOperation];
  }
}

- (void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button
{
  NSURL *url = [NSURL URLWithString:searchResult.artworkURL60];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  
  __weak UIButton *weakButton = button;
  [button setImageForState:UIControlStateNormal withURLRequest:request placeholderImage:nil success:^(NSHTTPURLResponse *response, UIImage *image) {
    UIImage *unscaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:image.imageOrientation];
    UIImage *resizedImage = [unscaledImage resizedImageWithBounds:CGSizeMake(60.0f, 60.0f)];
    [weakButton setImage:resizedImage forState:UIControlStateNormal];
  } failure:nil];
}

- (IBAction)pageChanged:(UIPageControl *)sender
{
  [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * sender.currentPage, 0.0f);
  } completion:nil];
}

- (void)tileButtons
{
  NSUInteger columnsPerPage = 5;
  CGFloat itemWidth = 96.0f;
  CGFloat x = 0.0f;
  CGFloat extraSpace = 0.0f;
  CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.bounds);
  
  if (scrollViewWidth > 480.0f) {
    columnsPerPage = 6;
    itemWidth = 94.0f;
    x = 2.0f;
    extraSpace = 4.0f;
  }
  
  const CGFloat itemHeight = 88.0f;
  const CGFloat buttonWidth = 82.0f;
  const CGFloat buttonHeight = 82.0f;
  const CGFloat marginHorz = (itemWidth - buttonWidth) / 2.0f;
  const CGFloat marginVert = (itemHeight - buttonHeight) / 2.0f;
  
  NSUInteger index = 0;
  NSUInteger row = 0;
  NSUInteger column = 0;
  
  for (SearchResult *searchResult in self.search.searchResults) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
    button.frame = CGRectMake(x + marginHorz, 20.0f + marginVert + row * itemHeight, buttonWidth, buttonHeight);
    
    [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
    
    [self.scrollView addSubview:button];
    
    index++;
    row++;
    
    if (row == 3) {
      row = 0;
      column++;
      x += itemWidth;
      
      if (column == columnsPerPage) {
        column = 0;
        x += extraSpace;
      }
    }
  }
  
  NSUInteger tilesPerPage = columnsPerPage * 3;
  NSUInteger numPages = ceilf([self.search.searchResults count] / (CGFloat)tilesPerPage);
  self.scrollView.contentSize = CGSizeMake(numPages * scrollViewWidth, CGRectGetHeight(self.scrollView.bounds));
  
  NSLog(@"Number of pages: %d", numPages);
  
  self.pageControl.numberOfPages = numPages;
  self.pageControl.currentPage = 0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  CGFloat width = CGRectGetWidth(self.scrollView.bounds);
  NSUInteger currentPage = (self.scrollView.contentOffset.x + width / 2.0f) / width;
  self.pageControl.currentPage = currentPage;
}

@end
