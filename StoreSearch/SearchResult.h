//
//  SearchResult.h
//  StoreSearch
//
//  Created by Scott Gardner on 3/12/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *artistName;
@property (copy, nonatomic) NSString *artworkURL60;
@property (copy, nonatomic) NSString *artworkURL100;
@property (copy, nonatomic) NSString *storeURL;
@property (copy, nonatomic) NSString *kind;
@property (copy, nonatomic) NSString *currency;
@property (copy, nonatomic) NSDecimalNumber *price;
@property (copy, nonatomic) NSString *genre;

- (NSComparisonResult)compareName:(SearchResult *)other;
- (NSComparisonResult)compareArtistName:(SearchResult *)other;

@end
