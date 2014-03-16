//
//  DetailViewController.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GradientView.h"

@interface DetailViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *kindLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation DetailViewController
{
  GradientView *_gradientView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.popupView.layer.cornerRadius = 10.0f;
  
  UIImage *image = [[UIImage imageNamed:@"PriceButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f)];
  image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.priceButton setBackgroundImage:image forState:UIControlStateNormal];
  self.view.tintColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:1.0f];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    
    self.popupView.hidden = !self.searchResult;
    self.title = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
  } else {
    self.view.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
  }
  
  if (self.searchResult) {
    [self updateUI];
  }
}

- (void)updateUI
{
  if (self.searchResult) {
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:self.searchResult.artworkURL100]];
    self.nameLabel.text = self.searchResult.name;
    
    NSString *artistName = self.searchResult.artistName;
    
    if (!artistName) {
      artistName = NSLocalizedString(@"Unknown", @"Unknown");
    }
    
    self.artistNameLabel.text = artistName;
    self.kindLabel.text = [self.searchResult kindForDisplay];
    self.genreLabel.text = self.searchResult.genre;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:self.searchResult.currency];
    
    NSString *priceText;
    
    if ([self.searchResult.price floatValue] == 0.0f) {
      priceText = NSLocalizedString(@"Free", @"Free");
    } else {
      priceText = [formatter stringFromNumber:self.searchResult.price];
    }
    
    [self.priceButton setTitle:priceText forState:UIControlStateNormal];
  }
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    self.popupView.hidden = NO;
    [self.masterPopoverController dismissPopoverAnimated:YES];
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
  [self.artworkImageView cancelImageRequestOperation];
}

- (void)setSearchResult:(SearchResult *)searchResult
{
  if (_searchResult != searchResult) {
    _searchResult = searchResult;
    
    if ([self isViewLoaded]) { // View will not be loaded on iPhone
      [self updateUI];
    }
  }
}

- (IBAction)close:(id)sender
{
  [self dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeSlide];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
  _gradientView = [[GradientView alloc] initWithFrame:parentViewController.view.bounds];
  [parentViewController.view addSubview:_gradientView];
  
  self.view.frame = parentViewController.view.bounds;
  [parentViewController.view addSubview:self.view];
  [parentViewController addChildViewController:self];
  
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  bounceAnimation.duration = 0.4;
  bounceAnimation.delegate = self;
  bounceAnimation.values = @[@0.7, @1.2, @0.9, @1.0];
  bounceAnimation.keyTimes = @[@0.0, @0.334, @0.666, @1.0];
  bounceAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  
  [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
  
  CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeAnimation.fromValue = @0.0f;
  fadeAnimation.toValue = @1.0f;
  fadeAnimation.duration = 0.2;
  [_gradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [self didMoveToParentViewController:self.parentViewController];
}

- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType
{
  [self willMoveToParentViewController:nil];
  
  [UIView animateWithDuration:0.4 animations:^{
    if (animationType == DetailViewControllerAnimationTypeSlide) {
      CGRect rect = self.view.bounds;
      rect.origin.y = CGRectGetHeight(rect);
      self.view.frame = rect;
    } else {
      self.view.alpha = 0.0f;
    }
    
    _gradientView.alpha = 0.0f;
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [_gradientView removeFromSuperview];
  }];
}

- (IBAction)openInStore:(id)sender
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.searchResult.storeURL]];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  return touch.view == self.view;
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
  barButtonItem.title = NSLocalizedString(@"Search", @"Split-view master button");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end
