//
//  STFocusBlurKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STFocusBlurKernel.h"

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
        
        [self _updateKernelMatrix];
    }
    return self;
}

#pragma mark -
#pragma mark - Helpers

- (void)_updateKernelMatrix
{
    cv::Mat kernelMatrix;
    buildKMatrixForKernel(_radius, _edgeFeather, _correctionStrength, &kernelMatrix);
    self.kernelMatrix = &kernelMatrix;
}

void buildKMatrixForKernel(float radius, float edgeFeather, float correctionStrength, cv::Mat* kernelMatrix)
{
    int size = 2 * radius + 6;
    size += size%2;
    
    *kernelMatrix = cv::Mat::zeros(size, size, CV_32FC1);
    cv::circle(*kernelMatrix, cv::Point(size/2.0f, size/2.0f), radius, cv::Scalar(255.0f,255.0f,0.0f), CV_FILLED, CV_AA, 0);
    
    int center = size/2;
    for (int y = 0; y<size; y++) {
        for (int x = 0; x<size; x++) {
            double dist = pow((double)x-center,2) + pow((double)y-center,2);
            dist = sqrt(dist);
            if (dist <= radius) {
                double mu = radius;
                double sigma = radius*edgeFeather/100;
                
                double gaussValue = pow(M_E, -pow((dist-mu)/sigma,2)/2);
                gaussValue *= 255*(correctionStrength)/100;
                
                int curValue = (*kernelMatrix).at<float>(x,y);
                if (correctionStrength >= 0) {
                    curValue *= (100-correctionStrength)/100;
                }
                
                curValue += gaussValue;
                if (curValue < 0) {
                    curValue = 0;
                }
                if (curValue > 255) {
                    curValue = 255;
                }
                
                (*kernelMatrix).at<float>(x,y) = curValue;
            }
        }
    }
}

@end
