//
//  ViewController.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/13/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "ViewController.h"

#import <UIActionSheet+BlocksKit.h>
#import <MBProgressHUD.h>

#import "STWienerFilter.h"
#import "STFocusBlurKernel.h"

#import "STFocusBlurParametersView.h"
#import "STMotionBlurParametersView.h"

using namespace cv;
using namespace std;

typedef NS_ENUM(NSInteger, STBlurType) {
    STBlurTypeFocus,
    STBlurTypeMotion
};

@interface ViewController ()  < UIImagePickerControllerDelegate, UINavigationControllerDelegate, STFocusBlurParametersViewDelegate, STMotionBlurParametersViewDelegate, UIScrollViewDelegate >

@property (nonatomic, assign) STBlurType currentBlutType;

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *blurParametersContainerView;
@property (nonatomic, strong) STFocusBlurParametersView* focusBlurParametersView;
@property (nonatomic, strong) STMotionBlurParametersView* motionBlurParametersView;

@property (nonatomic, strong) STWienerFilter* wienerFilter;
@property (nonatomic, assign) cv::Mat originalImage;

@end

@implementation ViewController

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setUpScrollView];
    [self _setUpFocusBlurParametersView];
    [self _setUpMotionBlurParametersView];
    
    [self setCurrentBlurType:STBlurTypeMotion];
    
    //TEMP
    _originalImage = imread("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg", IMREAD_UNCHANGED);
    cv::cvtColor(_originalImage, _originalImage, CV_BGR2RGB);
    _wienerFilter = [[STWienerFilter alloc] init];
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
}

#pragma mark -
#pragma mark - UI SetUp

- (void)_setUpScrollView
{
    _containerScrollView.minimumZoomScale = 1.0f;
    _containerScrollView.maximumZoomScale = 2.0f;
}

- (void)_setUpFocusBlurParametersView
{
    _focusBlurParametersView = [STFocusBlurParametersView new];
    _focusBlurParametersView.delegate = self;
    [_blurParametersContainerView addSubview:_focusBlurParametersView];
}

- (void)_setUpMotionBlurParametersView
{
    _motionBlurParametersView = [STMotionBlurParametersView new];
    _motionBlurParametersView.delegate = self;
    [_blurParametersContainerView addSubview:_motionBlurParametersView];
}

#pragma mark -
#pragma mark - Custom Setters & Getters

- (void)setCurrentBlurType:(STBlurType)currentBlutType
{
    _currentBlutType = currentBlutType;
    
    _focusBlurParametersView.hidden = (_currentBlutType != STBlurTypeFocus);
    _motionBlurParametersView.hidden = (_currentBlutType != STBlurTypeMotion);
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
            imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
            imagePickerController.popoverPresentationController.sourceView = self.view;
            imagePickerController.popoverPresentationController.sourceRect = ((UIButton *)sender).frame;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }];
    }
    [actionSheet bk_addButtonWithTitle:@"Choose From Library" handler:^{
        UIImagePickerController* imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = weakSelf;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        imagePickerController.popoverPresentationController.sourceView = self.view;
        imagePickerController.popoverPresentationController.sourceRect = ((UIButton *)sender).frame;
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showFromBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:sender] animated:YES];
}

- (IBAction)blurTypeButtonAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UIActionSheet* actionSheet = [UIActionSheet bk_actionSheetWithTitle:@""];
    [actionSheet bk_addButtonWithTitle:@"Focus Blur" handler:^{
        [weakSelf setCurrentBlurType:STBlurTypeFocus];
    }];
    [actionSheet bk_addButtonWithTitle:@"Motion Blur" handler:^{
        [weakSelf setCurrentBlurType:STBlurTypeMotion];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showFromBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:sender] animated:YES];
}

- (IBAction)applyButtonAction:(id)sender
{
    [self _applyFilter];
}

#pragma mark -
#pragma mark - STFocusBlurParametersView Delegate

- (void)focusBlurParametersView:(STFocusBlurParametersView *)parametersView
      didChangeKernelParameters:(STFocusBlurKernel *)kernel
{
    //TODO: Immediately show changes in preview mode.
}

- (void)focusBlurParametersView:(STFocusBlurParametersView *)parametersView didEndEditingKernelParameters:(STFocusBlurKernel *)kernel
{
    [self _applyFilter];
}

#pragma mark -
#pragma mark - STMotionBlurParametersView Delegate

- (void)motionBlurParametersView:(STMotionBlurParametersView *)view
       didChangeKernelParameters:(STMotionBlurKernel *)kernel
{
    //TODO: Immediately show changes in preview mode.
}

- (void)motionBlurParametersView:(STMotionBlurParametersView *)view
   didEndEditingKernelParameters:(STMotionBlurKernel *)kernel
{
     [self _applyFilter];
}

#pragma mark -
#pragma mark - UIImagePickerController Controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //TODO: Check image size
    UIImage* selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _originalImage = [selectedImage cvMatFromUIImage:selectedImage];
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark -
#pragma mark - Helpers

- (void)_applyFilter
{
    STKernel* currentKernel = [self _currentKernel];
    float gamma = 0.001f; // ??
    _wienerFilter.PSF = currentKernel;
    _wienerFilter.gamma = gamma;
    TICK;
    [_wienerFilter applyWienerFilter:_originalImage
                      withCompletion:^(cv::Mat deconvulvedImage) {
                          TOCK;
           _imageView.image = [UIImage imageWithCVMat:deconvulvedImage]; 
    }];
}

- (STKernel *)_currentKernel
{
    if (_currentBlutType == STBlurTypeFocus) {
        return _focusBlurParametersView.kernel;
    } else {
        return _motionBlurParametersView.kernel;
    }
}

@end
