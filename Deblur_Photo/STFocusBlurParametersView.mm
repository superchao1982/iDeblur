//
//  STFocusBlurParametersView.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STFocusBlurParametersView.h"
#import <NSTimer+BlocksKit.h>

#define kEditingTimeThreshold 0.2f

@interface STFocusBlurParametersView()

@property (weak, nonatomic) IBOutlet UIImageView *kernelImageView;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *edgeFeatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctionStrengthLabel;

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation STFocusBlurParametersView

#pragma mark -
#pragma mark - Initializers

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"STFocusBlurParametersView"
                                          owner:self
                                        options:nil] firstObject];
    if (self) {
        _kernel = [[STFocusBlurKernel alloc] initFocusBlurKernelWithRadius:0.0f edgeFeather:0.0f correctionStrength:0.0f];
        
        [self _updateUIForKernel:_kernel];
    }
    return self;
}

#pragma mark -
#pragma mark - UI

- (void)_updateUIForKernel:(STFocusBlurKernel *)kernel
{
    _radiusLabel.text = [NSString stringWithFormat:@"Radius: %.2f", kernel.radius];
    _edgeFeatherLabel.text = [NSString stringWithFormat:@"Edge feather: %.2f", kernel.edgeFeather];
    _correctionStrengthLabel.text = [NSString stringWithFormat:@"Strength: %.2f", kernel.correctionStrength];
    
    _kernelImageView.image = self.kernel.kernelImage;
}

#pragma mark -
#pragma mark - Helpers

- (void)setRadius:(float)radius
{
    _kernel.radius = radius;
    [self _updateUIForKernel:_kernel];
    
    [_timer invalidate];
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:kEditingTimeThreshold block:^(NSTimer *timer) {
        if ([weakSelf.delegate respondsToSelector:@selector(focusBlurParametersView:didChangeKernelParameters:)]) {
            [weakSelf.delegate focusBlurParametersView:weakSelf didChangeKernelParameters:_kernel];
        }
    } repeats:NO];
}

- (void)setEdgeFeather:(float)edgeFeather
{
    _kernel.edgeFeather = edgeFeather;
    [self _updateUIForKernel:_kernel];
    
    [_timer invalidate];
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:kEditingTimeThreshold block:^(NSTimer *timer) {
        if ([weakSelf.delegate respondsToSelector:@selector(focusBlurParametersView:didChangeKernelParameters:)]) {
            [weakSelf.delegate focusBlurParametersView:weakSelf didChangeKernelParameters:_kernel];
        }
    } repeats:NO];
}

- (void)setCorrectionStrength:(float)correctionStrength
{
    _kernel.correctionStrength = correctionStrength;
    [self _updateUIForKernel:_kernel];
    
    [_timer invalidate];
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:kEditingTimeThreshold block:^(NSTimer *timer) {
        if ([weakSelf.delegate respondsToSelector:@selector(focusBlurParametersView:didChangeKernelParameters:)]) {
            [weakSelf.delegate focusBlurParametersView:weakSelf didChangeKernelParameters:_kernel];
        }
    }repeats:NO];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)radiusSliderValueChanged:(UISlider*)sender
{
    [self setRadius:sender.value];
}

- (IBAction)edgeFeatherValueChanged:(UISlider*)sender
{
    [self setEdgeFeather:sender.value];
}

- (IBAction)correctionStrengthValueChanged:(UISlider*)sender
{
    [self setCorrectionStrength:sender.value];
}

- (IBAction)sliderDidEndEditing:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(focusBlurParametersView:didEndEditingKernelParameters:)]) {
        [self.delegate focusBlurParametersView:self
                 didEndEditingKernelParameters:_kernel];
    }
}

@end
