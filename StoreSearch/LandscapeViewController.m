//
//  LandscapeViewController.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "LandscapeViewController.h"
#import "SearchResult.h"

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
  NSUInteger searchResultsCount = [self.searchResults count];
  
  for (NSUInteger i = 0; i < searchResultsCount; i++) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:[NSString stringWithFormat:@"%d", index] forState:UIControlStateNormal];
    button.frame = CGRectMake(x + marginHorz, 20.0f + marginVert + row * itemHeight, buttonWidth, buttonHeight);
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
  NSUInteger numPages = ceilf(searchResultsCount / (CGFloat)tilesPerPage);
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
