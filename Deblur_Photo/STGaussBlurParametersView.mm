//
//  STGaussBlurParametersView.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/23/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STGaussBlurParametersView.h"
#import <NSTimer+BlocksKit.h>

#define kEditingTimeThreshold 0.2f

@interface STGaussBlurParametersView()

@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kernelImageView;

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation STGaussBlurParametersView

#pragma mark -
#pragma mark - Initializers

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"STGaussBlurParametersView"
                                          owner:self
                                        options:nil] firstObject];
    if (self) {
        _kernel = [[STGaussBlurKernel alloc] initWithRadius:0.0f];
        
        [self _updateUIForKernel:_kernel];
    }
    return self;
}

#pragma mark -
#pragma mark - UI

- (void)_updateUIForKernel:(STGaussBlurKernel *)kernel
{
    _radiusLabel.text = [NSString stringWithFormat:@"Radius: %.2f", _kernel.radius];
    
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
        if ([weakSelf.delegate respondsToSelector:@selector(gaussBlurParametersView:didChangeKernelParameters:)]) {
            [weakSelf.delegate gaussBlurParametersView:weakSelf didChangeKernelParameters:weakSelf.kernel];
        }
    } repeats:NO];
}

#pragma mark -
#pragma mark - Actions 

- (IBAction)radiusValueChanged:(UISlider *)sender
{
    [self setRadius:sender.value];
}

- (IBAction)sliderDidEndEditing:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(gaussBlurParametersView:didEndEditingKernelParameters:)]) {
        [self.delegate gaussBlurParametersView:self didEndEditingKernelParameters:_kernel];
    }
}

@end
