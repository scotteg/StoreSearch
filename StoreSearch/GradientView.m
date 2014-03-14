//
//  GradientView.m
//  StoreSearch
//
//  Created by Scott Gardner on 3/14/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  const CGFloat components[8] = { 0.0f, 0.0f, 0.0f, 0.3f, 0.0f, 0.0f, 0.0f, 0.7f };
  const CGFloat locations[2] = { 0.0f, 1.0f };
  
  CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
  CGColorSpaceRelease(space);
  
  CGFloat x = CGRectGetMidX(self.bounds);
  CGFloat y = CGRectGetMidY(self.bounds);
  CGPoint point = CGPointMake(x, y);
  CGFloat radius = MAX(x, y);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextDrawRadialGradient(context, gradient, point, 0.0f, point, radius, kCGGradientDrawsAfterEndLocation);
  
  CGGradientRelease(gradient);
}

- (void)dealloc
{
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
