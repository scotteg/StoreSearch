//
//  SearchResultCell.h
//  StoreSearch
//
//  Created by Scott Gardner on 3/12/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end
