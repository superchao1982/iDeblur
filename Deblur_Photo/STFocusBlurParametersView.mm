//
//  STFocusBlurParametersView.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/21/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STFocusBlurParametersView.h"

@interface STFocusBlurParametersView()

@property (weak, nonatomic) IBOutlet UIImageView *kernelImageView;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *edgeFeatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctionStrengthLabel;

@end

@implementation STFocusBlurParametersView

#pragma mark -
#pragma mark - Initializers

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"STFocusBlurParametersView"
                                          owner:self
                                        options:nil] objectAtIndex:0];
    if (self) {
        _kernel = [STFocusBlurKernel new];
        
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
    
    [self.delegate focusBlurParametersViewDidChangeRadius:self
                                                   radius:_kernel.radius];
}

- (void)setEdgeFeather:(float)edgeFeather
{
    _kernel.edgeFeather = edgeFeather;
    [self _updateUIForKernel:_kernel];
    
    [self.delegate focusBlurParametersViewDidEdgeFeather:self
                                             edgeFeather:_kernel.edgeFeather];
}

- (void)setCorrectionStrength:(float)correctionStrength
{
    _kernel.correctionStrength = correctionStrength;
    [self _updateUIForKernel:_kernel];
    
    [self.delegate focusBlurParametersViewDidChangeCorrectionStrength:self
                                                   correctionStrength:_kernel.correctionStrength];
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

@end
