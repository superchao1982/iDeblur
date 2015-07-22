//
//  STWienerFilterOperation.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/22/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKernel.h"


@interface STWienerFilterOperation : NSOperation

- (instancetype)initWithCVMat:(cv::Mat)image
                       kernel:(STKernel *)kernel
                        gamma:(float)gamma;

@property(nonatomic, assign) cv::Mat editedImage;

@end
