//
//  STMotionBlurKernel.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STKernel.h"

@interface STMotionBlurKernel : STKernel

- (STMotionBlurKernel *)initMotionBlurKernelWithLength:(float)length
                                                 angle:(float)angle;

@property (nonatomic, assign) float length;
@property (nonatomic, assign) float angle;

@end
