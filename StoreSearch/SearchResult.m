//
//  SearchResult.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/12/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (NSComparisonResult)compareName:(SearchResult *)other
{
  return [self.name localizedStandardCompare:other.name];
}

- (NSComparisonResult)compareArtistName:(SearchResult *)other
{
  return [self.artistName localizedStandardCompare:other.artistName];
}

@end
