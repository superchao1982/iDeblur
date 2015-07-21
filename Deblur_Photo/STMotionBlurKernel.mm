//
//  STMotionBlurKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STMotionBlurKernel.h"

@interface STMotionBlurKernel()

@property (nonatomic, assign) cv::Mat kernelImageMatrix;

@end

@implementation STMotionBlurKernel

#pragma mark -
#pragma mark - Initializers

- (STMotionBlurKernel *)initMotionBlurKernelWithLength:(float)length angle:(float)angle
{
    self = [super init];
    if (self) {
        _length = length;
        _angle = angle;
        
        [self _updateKernelImageMatrix];
    }
    return self;
}

#pragma mark -
#pragma mark - Custom Setters & Getters

- (void)setAngle:(float)angle
{
    _angle = angle;
    
    [self _updateKernelImageMatrix];
}

- (void)setLength:(float)length
{
    _length = length;
    
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
    self.kernelImageMatrix = buildKMatrixForKernel(_length, _angle);
}

cv::Mat buildKMatrixForKernel(float length, float angle)
{
    int size = 2 * length + 6;
    size += size%2;
    
    cv::Mat kernelMatrix = cv::Mat::Mat(cv::Size(size, size), CV_32FC1, CV_RGB(0.0f,0.0f,0.0f));
    double center = 0.5f + size/2;
    double motionAngleRad = M_PI*angle/180;
    cv::line(kernelMatrix, cv::Point(center - length*cos(motionAngleRad)/2, center - length*sin(motionAngleRad)/2),
             cv::Point(center + length*cos(motionAngleRad)/2, center + length*sin(motionAngleRad)/2),
             cv::Scalar(255.0f,255.0f,255.0));
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
