//
//  STGaussBlurKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/23/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STGaussBlurKernel.h"

@interface STGaussBlurKernel()

@property (nonatomic, assign) cv::Mat kernelImageMatrix;

@end

@implementation STGaussBlurKernel

#pragma mark -
#pragma mark - Initializers

- (instancetype)initWithRadius:(float)radius
{
    self = [super init];
    if (self) {
        _radius = radius;
        
        [self _updateKernelImageMatrix];
    }
    return self;
}

#pragma mark -
#pragma mark - Custom Setters & Getters

- (void)setRadius:(float)radius
{
    _radius = radius;
    
    [self _updateKernelImageMatrix];
}

#pragma mark -
#pragma mark - Class methods

- (cv::Mat)kernelMatrix
{
    cv::Mat normalizedKernel;
    normalizeKernel(self.kernelImageMatrix, normalizedKernel);
    return normalizedKernel;
}

#pragma mark -
#pragma mark - Helpers

- (void)_updateKernelImageMatrix
{
    self.kernelImageMatrix = buildKMatrixForKernel(_radius);
}

cv::Mat buildKMatrixForKernel(float radius)
{
    int size = 4*radius + 6;
    size += size%2;
    
    cv::Mat kernelMatrix = cv::Mat::Mat(cv::Size(size, size), CV_32FC1, CV_RGB(0.0f,0.0f,0.0f));
    for (int y=0; y<size; y++) {
        for (int x=0; x<size; x++) {
            int value = 255*(pow((float)M_E, -(pow((float)x-size/2,2)+pow((float)y-size/2,2))/(2*pow((float)radius,2))));
            kernelMatrix.at<float>(x,y) = value;
        }
    }
    return kernelMatrix;
}

#pragma mark -
#pragma mark - Overriden

- (UIImage *)kernelImage
{
    cv::Mat convertedImage;
    self.kernelImageMatrix.convertTo(convertedImage, CV_8UC1);
    return [UIImage imageWithCVMat:convertedImage];
}

@end
