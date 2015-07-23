//
//  UIImage+OpenCV.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/17/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
+ (UIImage *)imageWithIplImage:(IplImage *)image;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

@end
