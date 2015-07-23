//
//  STGaussBlurParametersView.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/23/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STGaussBlurKernel.h"

@protocol STGaussBlurParametersViewDelegate;

@interface STGaussBlurParametersView : UIView

@property (nonatomic, strong) STGaussBlurKernel* kernel;

@property (nonatomic, weak) id<STGaussBlurParametersViewDelegate> delegate;

@end

@protocol STGaussBlurParametersViewDelegate <NSObject>
@optional

- (void)gaussBlurParametersView:(STGaussBlurParametersView *)view
      didChangeKernelParameters:(STGaussBlurKernel *)kernel;

- (void)gaussBlurParametersView:(STGaussBlurParametersView *)view
  didEndEditingKernelParameters:(STGaussBlurKernel *)kernel;

@end
