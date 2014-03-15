//
//  Search.h
//  StoreSearch
//
//  Created by Scott Gardner on 3/15/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SearchBlock)(BOOL success);

@interface Search : NSObject

@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic, readonly) NSMutableArray *searchResults;

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;

@end
