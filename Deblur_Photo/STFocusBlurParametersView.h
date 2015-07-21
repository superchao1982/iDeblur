//
//  STFocusBlurParametersView.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFocusBlurKernel.h"

@protocol STFocusBlurParametersViewDelegate;

@interface STFocusBlurParametersView : UIView

@property (nonatomic, weak) id<STFocusBlurParametersViewDelegate> delegate;

@property (nonatomic, strong) STFocusBlurKernel* kernel;

@end

@protocol STFocusBlurParametersViewDelegate <NSObject>
@required
- (void)focusBlurParametersViewDidChangeRadius:(STFocusBlurParametersView *)view
                                        radius:(float)radius;

- (void)focusBlurParametersViewDidEdgeFeather:(STFocusBlurParametersView *)view
                                  edgeFeather:(float)edgeFeather;

- (void)focusBlurParametersViewDidChangeCorrectionStrength:(STFocusBlurParametersView *)view
                                        correctionStrength:(float)correctionStrength;

@end