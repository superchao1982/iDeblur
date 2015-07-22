//
//  STMotionBlurParametersView.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STMotionBlurParametersView.h"

@interface STMotionBlurParametersView()

@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kernelImageView;

@end

@implementation STMotionBlurParametersView

#pragma mark -
#pragma mark - Initializers

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"STMotionBlurParametersView"
                                          owner:self
                                        options:nil] firstObject];
    if (self) {
        _kernel = [[STMotionBlurKernel alloc] initMotionBlurKernelWithLength:10.0f angle:0.0f];
        
        [self _updateUIForKernel:_kernel];
    }
    return self;
}

#pragma mark -
#pragma mark - UI

- (void)_updateUIForKernel:(STMotionBlurKernel *)kernel
{
    _lengthLabel.text = [NSString stringWithFormat:@"Length: %.2f", kernel.length];
    _angleLabel.text = [NSString stringWithFormat:@"Angle: %.2f", kernel.angle];
    
    _kernelImageView.image = self.kernel.kernelImage;
}

#pragma mark -
#pragma mark - Helpers

- (void)setLength:(float)length
{
    _kernel.length = length;
    [self _updateUIForKernel:_kernel];
}


- (void)setAngle:(float)angle
{
    _kernel.angle = angle;
    [self _updateUIForKernel:_kernel];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)lengthValueChanged:(UISlider *)sender
{
    [self setLength:sender.value];
    
    if ([self.delegate respondsToSelector:@selector(motionBlurParametersView:didChangeKernelParameters:)]) {
        [self.delegate motionBlurParametersView:self
                      didChangeKernelParameters:_kernel];
    }
}

- (IBAction)angleValueChanged:(UISlider *)sender
{
    [self setAngle:sender.value];
    
    if ([self.delegate respondsToSelector:@selector(motionBlurParametersView:didChangeKernelParameters:)]) {
        [self.delegate motionBlurParametersView:self
                      didChangeKernelParameters:_kernel];
    }
}

- (IBAction)sliderDidEndEditing:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(motionBlurParametersView:didEndEditingKernelParameters:)]) {
        [self.delegate motionBlurParametersView:self didEndEditingKernelParameters:_kernel];
    }
}

@end
