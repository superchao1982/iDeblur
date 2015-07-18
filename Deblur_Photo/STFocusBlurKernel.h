//
//  STFocusBlurKernel.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKernel.h"

@interface STFocusBlurKernel : STKernel

- (STFocusBlurKernel *)initFocusBlurKernelWithRadius:(float)radius
                            edgeFeather:(float)edgeFeather
                     correctionStrength:(float)correctionStrength;

@property (nonatomic, assign) float radius;
@property (nonatomic, assign) float edgeFeather;
@property (nonatomic, assign) float correctionStrength;

@end
