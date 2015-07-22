//
//  STWienerFilterOperation.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/22/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STWienerFilterOperation.h"

using namespace std;
using namespace cv;

@interface STWienerFilterOperation()

@property (nonatomic, assign) cv::Mat image;
@property (nonatomic, strong) STKernel* kernel;
@property (nonatomic, assign) float gamma;

@end

@implementation STWienerFilterOperation

#pragma mark -
#pragma mark - Initializers

- (instancetype)initWithCVMat:(cv::Mat)image
                       kernel:(STKernel *)kernel
                        gamma:(float)gamma
{
    self = [super init];
    if (self) {
        _image = image;
        _kernel = kernel;
        _gamma = gamma;
    }
    return self;
}

#pragma mark -
#pragma mark - Overridden

- (void)main
{
    @autoreleasepool {
        _editedImage = [self applyWienerFilter:_image];
    }
}

#pragma mark -
#pragma mark - Helpers

- (cv::Mat)applyWienerFilter:(cv::Mat)img
{
    std::vector<cv::Mat> channels(3);
    split(img, channels);
    
    channels[0] = [self _applyWienerFilterForChannels:channels[0]
                                               kernel:_kernel.kernelMatrix
                                                gamma:_gamma];
    channels[1] = [self _applyWienerFilterForChannels:channels[1]
                                               kernel:_kernel.kernelMatrix
                                                gamma:_gamma];
    channels[2] = [self _applyWienerFilterForChannels:channels[2]
                                               kernel:_kernel.kernelMatrix
                                                gamma:_gamma];
    
    merge(channels, img);
    
    cv::Mat finalImage;
    img.convertTo(finalImage, CV_8UC3);
    return finalImage;
}

#pragma mark -
#pragma mark - Helpers

- (cv::Mat)_applyWienerFilterForChannels:(cv::Mat)img kernel:(cv::Mat)PSF gamma:(float)gamma
{
    if (img.channels() > 1) {
        NSLog(@"Error: Incorrect number of channels for wiener filter.");
        return img;
    }
    
    img.convertTo(img, CV_32FC1, 1.0f/255.0f);
    
    Mat Hf = Mat::zeros(img.rows, img.cols, CV_32FC1);
    PSF.copyTo(Hf(Range(0, PSF.rows), Range(0, PSF.cols)));
    dft(Hf, Hf, cv::DFT_COMPLEX_OUTPUT);
    
    Mat xHf0;
    cv::mulSpectrums(Hf, Hf, xHf0, DFT_ROWS, true);
    Mat xHf1;
    cv::mulSpectrums(Hf, Hf, xHf1, DFT_ROWS, true);
    xHf1 = xHf1 + gamma;
    
    [self _reverseComplexSpectrum:xHf1];
    
    Mat xHf;
    cv::mulSpectrums(xHf0, xHf1, xHf, DFT_ROWS);
    [self _reverseComplexSpectrum:Hf];
    
    Mat iHf;
    cv::mulSpectrums(Hf, xHf, iHf, DFT_ROWS);
    
    Mat Yf;
    dft(img, Yf, cv::DFT_COMPLEX_OUTPUT);
    Mat Fv;
    cv::mulSpectrums(Yf, iHf, Fv, DFT_ROWS);
    
    idft(Fv, Fv, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);
    
    Fv.convertTo(Fv, CV_32FC1, 255.0f);
    
    return Fv;
}

- (void)_reverseComplexSpectrum:(InputArray)input
{
    cv::Mat array = input.getMat();
    for (int i = 0; i < array.rows; i++) {
        for (int j = 0; j < array.cols*2; j+=2) {
            std::complex<float> c0(1.0f, 0.0f);
            float a = array.at<float>(i, j);
            float b = array.at<float>(i, j+1);
            std::complex<float> c1(a, b);
            
            std::complex<float> c2 = c0/c1;
            array.at<float>(i, j) = c2.real();
            array.at<float>(i, j+1) = c2.imag();
        }
    }
}

@end
