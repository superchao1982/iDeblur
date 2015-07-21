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
                                        options:nil] objectAtIndex:0];
    if (self) {
        _kernel = [STMotionBlurKernel new];
        
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
}

- (IBAction)angleValueChanged:(UISlider *)sender
{
    [self setAngle:sender.value];
}

@end
