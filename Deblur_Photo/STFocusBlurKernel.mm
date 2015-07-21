//
//  STFocusBlurKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STFocusBlurKernel.h"

@interface STFocusBlurKernel()

@property (nonatomic, assign) cv::Mat kernelImageMatrix;

@end

@implementation STFocusBlurKernel

#pragma mark - 
#pragma mark - Initializers

- (STKernel *)initFocusBlurKernelWithRadius:(float)radius
                            edgeFeather:(float)edgeFeather
                     correctionStrength:(float)correctionStrength
{
    self = [super init];
    if (self) {
        _radius = radius;
        _edgeFeather = edgeFeather;
        _correctionStrength = correctionStrength;
        
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

- (void)setEdgeFeather:(float)edgeFeather
{
    _edgeFeather = edgeFeather;
    
    [self _updateKernelImageMatrix];
}

- (void)setCorrectionStrength:(float)correctionStrength
{
    _correctionStrength = correctionStrength;
    
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
    self.kernelImageMatrix = buildKMatrixForKernel(_radius, _edgeFeather, _correctionStrength);
}

cv::Mat buildKMatrixForKernel(float radius, float edgeFeather, float correctionStrength)
{
    int size = 2 * radius + 6;
    size += size%2;
    
    cv::Mat kernelMatrix = cv::Mat::Mat(cv::Size(size, size), CV_32FC1, CV_RGB(0.0f,0.0f,0.0f));
    cv::circle(kernelMatrix, cv::Point(size/2.0f, size/2.0f), radius, cv::Scalar(255.0f, 255.0f, 255.0f), CV_FILLED, CV_AA, 0);
    
    int center = size/2;
    for (int y = 0; y<size; y++) {
        for (int x = 0; x<size; x++) {
            double dist = pow((double)x-center,2) + pow((double)y-center,2);
            dist = sqrt(dist);
            if (dist <= radius) {
                double mu = radius;
                double sigma = radius*edgeFeather/100.0f;
                
                double gaussValue = pow(M_E, -pow((dist-mu)/sigma,2.0f)/2.0f);
                gaussValue *= 255.0f*(correctionStrength)/100.0f;
                
                float curValue = kernelMatrix.at<float>(x,y);
                if (correctionStrength >= 0) {
                    curValue *= (100.0f-correctionStrength)/100.0f;
                }
                
                curValue += gaussValue;
                if (curValue < 0.0f) {
                    curValue = 0.0f;
                }
                if (curValue > 255.0f) {
                    curValue = 255.0f;
                }
                
                kernelMatrix.at<float>(x,y) = curValue;
            }
        }
    }
    
    return kernelMatrix;
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

#pragma mark -
#pragma mark - Overriden

- (UIImage *)kernelImage
{
    cv::Mat convertedImage;
    self.kernelImageMatrix.convertTo(convertedImage, CV_8UC1);
    return [UIImage imageWithCVMat:convertedImage];
}

@end
