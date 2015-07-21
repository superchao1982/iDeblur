//
//  STMotionBlurParametersView.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMotionBlurKernel.h"

@protocol STMotionBlurParametersViewDelegate;

@interface STMotionBlurParametersView : UIView

@property (nonatomic, weak) id<STMotionBlurParametersViewDelegate> delegate;

@property (nonatomic, strong) STMotionBlurKernel* kernel;

@end

@protocol STMotionBlurParametersViewDelegate <NSObject>
@required

- (void)motionBlurParametersView:(STMotionBlurParametersView *)view
                 didChangeLength:(float)length;

- (void)motionBlurParametersView:(STMotionBlurParametersView *)view
                 didChangeAngle:(float)angle;

@end
