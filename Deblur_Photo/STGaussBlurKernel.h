//
//  STGaussBlurKernel.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/23/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKernel.h"

@interface STGaussBlurKernel : STKernel

- (instancetype)initWithRadius:(float)radius;

@property (nonatomic, assign) float radius;

@end
