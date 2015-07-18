//
//  STFilterKernel.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STKernel.h"

@implementation STKernel

- (UIImage *)kernelImage
{
//    cv::Mat kernelImage;
//    std::vector<cv::Mat> channels(3);
//    
//    (*self.kernelMatrix).copyTo(channels[0]);
//    (*self.kernelMatrix).copyTo(channels[1]);
//    (*self.kernelMatrix).copyTo(channels[2]);
//    std::cout << *self.kernelMatrix;
//    
//    merge(channels, kernelImage);
    
    return [UIImage imageWithCVMat:*self.kernelMatrix];
}

@end
