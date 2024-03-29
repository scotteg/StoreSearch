//
//  DetailViewController.h
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MessageUI;

@class SearchResult;

typedef NS_ENUM(NSUInteger, DetailViewControllerAnimationType) {
  DetailViewControllerAnimationTypeSlide,
  DetailViewControllerAnimationTypeFade
};

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) SearchResult *searchResult;
@property (weak, nonatomic) IBOutlet UIView *popupView;

- (void)presentInParentViewController:(UIViewController *)parentViewController;
- (void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;
- (void)sendSupportEmail;

@end
