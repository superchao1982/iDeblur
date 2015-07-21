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

void normalizeKernel(cv::InputArray input, cv::OutputArray output)
{
    float sum = 0;
    cv::Mat img = input.getMat();
    cv::Mat kernelConverted;
    img.convertTo(kernelConverted, CV_32FC1);
    for (int i = 0; i < input.size().width; i++) for (int j = 0; j < input.size().height; j++) {
        sum += kernelConverted.at<float>(i, j);
    }
    kernelConverted = kernelConverted/sum;
    kernelConverted.copyTo(output);
}

@end
