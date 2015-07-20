//
//  STWienerFilter.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKernel.h"

@interface STWienerFilter : NSObject

@property (nonatomic, assign) float gamma;
@property (nonatomic, strong) STKernel* PSF;

- (cv::Mat)applyWienerFilter:(cv::Mat)image;

@end
