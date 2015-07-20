//
//  STFilterKernel.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKernel : NSObject

- (cv::Mat)kernelMatrix;
- (UIImage *)kernelImage;

@end
