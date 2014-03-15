//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by Scott Gardner on 3/11/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageWithBounds:(CGSize)bounds
{
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio = MIN(horizontalRatio, verticalRatio);
  CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
  
  UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0f);
  [self drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
