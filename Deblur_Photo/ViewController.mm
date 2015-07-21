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

#import "STFocusBlurParametersView.h"

using namespace cv;
using namespace std;

typedef NS_ENUM(NSInteger, STBlurType) {
    STBlurTypeFocus
};

@interface ViewController ()  < UIImagePickerControllerDelegate, UINavigationControllerDelegate, STFocusBlurParametersViewDelegate >

@property (nonatomic, assign) STBlurType currentBlutType;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *blurParametersContainerView;
@property (nonatomic, strong) STFocusBlurParametersView* focusBlurParametersView;

@property (nonatomic, strong) STWienerFilter* wienerFilter;
@property (nonatomic, assign) cv::Mat originalImage;

@end

@implementation ViewController

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setUpFocusBlurParametersView];
    [self setCurrentBlutType:STBlurTypeFocus];
    
    _originalImage = imread("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg", IMREAD_UNCHANGED);
    cv::cvtColor(_originalImage, _originalImage, CV_BGR2RGB);
    _wienerFilter = [[STWienerFilter alloc] init];
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
}

#pragma mark -
#pragma mark - UI SetUp

- (void)_setUpFocusBlurParametersView
{
    _focusBlurParametersView = [STFocusBlurParametersView new];
    _focusBlurParametersView.delegate = self;
    [_blurParametersContainerView addSubview:_focusBlurParametersView];
}

#pragma mark -
#pragma mark - Custom Setters & Getters

- (void)setCurrentBlutType:(STBlurType)currentBlutType
{
    _currentBlutType = currentBlutType;
    
    _focusBlurParametersView.hidden = (_currentBlutType != STBlurTypeFocus);
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

- (IBAction)applyButtonAction:(id)sender
{
    [self _applyFilter];
}

#pragma mark -
#pragma mark - STFocusBlurParametersView Delegate

- (void)focusBlurParametersViewDidChangeRadius:(STFocusBlurParametersView *)view
                                        radius:(float)radius
{
    //
}

- (void)focusBlurParametersViewDidEdgeFeather:(STFocusBlurParametersView *)view
                                  edgeFeather:(float)edgeFeather
{
    //
}

- (void)focusBlurParametersViewDidChangeCorrectionStrength:(STFocusBlurParametersView *)view
                                        correctionStrength:(float)correctionStrength
{
    //
}

#pragma mark -
#pragma mark - Helpers

- (void)_applyFilter
{
    STKernel* currentKernel = [self _currentKernel];
    float gamma = 0.001f; // ??
    _wienerFilter.PSF = currentKernel;
    _wienerFilter.gamma = gamma;
    Mat deconvulvedImage = [_wienerFilter applyWienerFilter:_originalImage];
    _imageView.image = [UIImage imageWithCVMat:deconvulvedImage];
}

- (STKernel *)_currentKernel
{
    if (_currentBlutType == STBlurTypeFocus) {
        return _focusBlurParametersView.kernel;
    } else {
        return nil;
    }
}

@end
