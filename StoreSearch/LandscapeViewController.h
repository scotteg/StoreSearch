//
//  LandscapeViewController.h
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Search;

@interface LandscapeViewController : UIViewController

@property (strong, nonatomic) Search *search;

- (void)searchResultsReceived;

@end
