//
//  STFilterKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STKernel.h"

@implementation STKernel

#pragma mark -
#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

#pragma mark -
#pragma mark - Class methods

- (cv::Mat)kernelMatrix
{
    NSAssert(NO, @"Must be overridden!");
    return cv::Mat();
}

- (UIImage *)kernelImage
{
    NSAssert(NO, @"Must be overridden!");
    return nil;
}

@end
