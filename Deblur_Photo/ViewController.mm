//
//  ViewController.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/13/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "ViewController.h"

#import <UIActionSheet+BlocksKit.h>
#import "STWienerFilter.h"
#import "STFocusBlurKernel.h"

using namespace cv;
using namespace std;

@interface ViewController ()  < UIImagePickerControllerDelegate, UINavigationControllerDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *kernelImageView;

@property (nonatomic, strong) STWienerFilter* wienerFilter;
@property (nonatomic, assign) cv::Mat originalImage;

@end

@implementation ViewController

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    float PSFValues[3][11] = {
//        {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0004f, 0.0090f, 0.0176f, 0.0262f, 0.0347f, 0.0199f},
//        {0.0346f, 0.0642f, 0.0728f, 0.0814f, 0.0900f, 0.0986f, 0.0900f, 0.0814f, 0.0728f, 0.0642f, 0.0346f},
//        {0.0199f, 0.0347f, 0.0262f, 0.0176f, 0.0090f, 0.0004f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}
//    };
//    Mat PSF = Mat(3, 11, CV_32FC1, &PSFValues);
//    Mat img = imread("/Users/santatnt/Documents/MATLAB/lena1.png", IMREAD_UNCHANGED);
//    filter2D(img, img, -1, PSF, cv::Point(-1,-1), 0, BORDER_CONSTANT);
//    imwrite("/Users/santatnt/Desktop/blurred.png", img);
    
    _originalImage = imread("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg", IMREAD_UNCHANGED);
    cv::cvtColor(_originalImage, _originalImage, CV_BGR2RGB);
    _wienerFilter = [[STWienerFilter alloc] init];
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)choosePhotoButtonAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UIActionSheet* actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet bk_addButtonWithTitle:@"Take New Photo" handler:^{
            UIImagePickerController* imagePickerController = [UIImagePickerController new];
            imagePickerController.delegate = weakSelf;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }];
    }
    [actionSheet bk_addButtonWithTitle:@"Choose From Library" handler:^{
        UIImagePickerController* imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = weakSelf;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)slider0ValueChanged:(UISlider *)slider
{
    //
}

- (void)_showImage:(UIImage *)wonImage title:(NSString *)title
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 282)];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    [imageView setImage:wonImage];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [alertView setValue:imageView forKey:@"accessoryView"];
    }else{
        [alertView addSubview:imageView];
    }
    [alertView show];
}

- (IBAction)kernelRadiusValueChanged:(UISlider *)slider
{
    float radius = slider.value;
    NSLog(@"Radius - %.f", radius);
    [(STFocusBlurKernel *)_wienerFilter.PSF setRadius:radius];
    
    _kernelImageView.image = [_wienerFilter.PSF kernelImage];
}

- (IBAction)kernelEdgeFeatherValueChanged:(UISlider *)slider
{
    float edgeFeather = slider.value;
    NSLog(@"Edge feather - %.f", edgeFeather);
    [(STFocusBlurKernel *)_wienerFilter.PSF setEdgeFeather:edgeFeather];
    
    _kernelImageView.image = [_wienerFilter.PSF kernelImage];
}

- (IBAction)kernelCorrectionStrengthValueChanged:(UISlider *)slider
{
    float correctionStrength = slider.value;
    NSLog(@"Correction strength - %.f", correctionStrength );
    [(STFocusBlurKernel *)_wienerFilter.PSF setCorrectionStrength:correctionStrength];
    
    _kernelImageView.image = [_wienerFilter.PSF kernelImage];
}

- (IBAction)applyButtonAction:(id)sender
{
    _wienerFilter.gamma = 0.001f;
    [_wienerFilter applyWienerFilter:&_originalImage];
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
    
    imwrite("/Users/santatnt/Desktop/deblurred.png", _originalImage);
}

@end
