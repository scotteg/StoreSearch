//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/12/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SearchResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  // Could also have done this in init
  UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
  selectedView.backgroundColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:0.5f];
  self.selectedBackgroundView = selectedView;
}

- (void)configureForSearchResult:(SearchResult *)searchResult
{
  self.nameLabel.text = searchResult.name;
  NSString *artistName = searchResult.artistName;
  
  if (!artistName) {
    artistName = @"(Unknown)";
  }
  
  NSString *kind = [self kindForDisplay:searchResult.kind];
  self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
  
  [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  [self.artworkImageView cancelImageRequestOperation];
  self.nameLabel.text = nil;
  self.artistNameLabel.text = nil;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
