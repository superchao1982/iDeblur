//
//  ViewController.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/13/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "ViewController.h"

#import <UIActionSheet+BlocksKit.h>
#import <UIAlertView+BlocksKit.h>
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

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *showOriginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *blurParametersContainerView;
@property (nonatomic, strong) STFocusBlurParametersView* focusBlurParametersView;
@property (nonatomic, strong) STMotionBlurParametersView* motionBlurParametersView;

@property (nonatomic, strong) STWienerFilter* wienerFilter;
@property (nonatomic, assign) cv::Mat originalImage;
@property (nonatomic, assign) cv::Mat previewImage;

@end

@implementation ViewController

#pragma mark -
#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _wienerFilter = [[STWienerFilter alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setUpScrollView];
    [self _setUpFocusBlurParametersView];
    [self _setUpMotionBlurParametersView];
    
    [self setCurrentBlurType:STBlurTypeFocus];
    
    //TEMP
    _originalImage = imread("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg", IMREAD_UNCHANGED);
    if (_originalImage.channels() == 3) {
        cv::cvtColor(_originalImage, _originalImage, CV_BGR2RGB);
    }
    cv::cvtColor(_originalImage, _previewImage, CV_RGB2GRAY);
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIImagePickerController* imagePickerController = [UIImagePickerController new];
                imagePickerController.delegate = weakSelf;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
                imagePickerController.popoverPresentationController.sourceView = self.view;
                imagePickerController.popoverPresentationController.sourceRect = ((UIButton *)sender).frame;
                [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
            });
        }];
    }
    [actionSheet bk_addButtonWithTitle:@"Choose From Library" handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImagePickerController* imagePickerController = [UIImagePickerController new];
            imagePickerController.delegate = weakSelf;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
            imagePickerController.popoverPresentationController.sourceView = self.view;
            imagePickerController.popoverPresentationController.sourceRect = ((UIButton *)sender).frame;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        });
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

- (IBAction)saveButtonAction:(id)sender
{
    UIImage* image = self.imageView.image;
    if (_wienerFilter.filtering == NO && image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (IBAction)showOriginPhotoButtonAction:(id)sender
{
    if (_wienerFilter.filtering == NO) {
        self.imageView.image = [UIImage imageWithCVMat:_originalImage];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:@"Image has been saved to your gallery."
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
                                   handler:nil];
}

#pragma mark -
#pragma mark - STFocusBlurParametersView Delegate

- (void)focusBlurParametersView:(STFocusBlurParametersView *)parametersView
      didChangeKernelParameters:(STFocusBlurKernel *)kernel
{
    _statusLabel.text = @"Applying preview filter.";
    _saveButton.enabled = NO;
    [_activityIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self _applyWienerForImage:_previewImage
                withCompletion:^(cv::Mat image) {
                    weakSelf.imageView.image = [UIImage imageWithCVMat:image];
                    
                    weakSelf.statusLabel.text = @"Applying full resolution filter.";
                    
                    [self _applyWienerForImage:_originalImage withCompletion:^(cv::Mat image) {
                        weakSelf.statusLabel.text = @"";
                        [weakSelf.activityIndicator stopAnimating];
                        
                        weakSelf.imageView.image = [UIImage imageWithCVMat:image];
                        weakSelf.saveButton.enabled = YES;
                    }];
                }];
}

#pragma mark -
#pragma mark - STMotionBlurParametersView Delegate

- (void)motionBlurParametersView:(STMotionBlurParametersView *)view
       didChangeKernelParameters:(STMotionBlurKernel *)kernel
{
    _statusLabel.text = @"Applying preview filter.";
    _saveButton.enabled = NO;
    [_activityIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self _applyWienerForImage:_previewImage
                withCompletion:^(cv::Mat image) {
                    weakSelf.imageView.image = [UIImage imageWithCVMat:image];
                    
                    weakSelf.statusLabel.text = @"Applying full resolution filter.";
                    
                    [self _applyWienerForImage:_originalImage withCompletion:^(cv::Mat image) {
                        weakSelf.statusLabel.text = @"";
                        [weakSelf.activityIndicator stopAnimating];
                        
                        weakSelf.imageView.image = [UIImage imageWithCVMat:image];
                        weakSelf.saveButton.enabled = YES;
                    }];
                }];
}

#pragma mark -
#pragma mark - UIImagePickerController Controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //TODO: Check image size
    UIImage* selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _originalImage = [selectedImage cvMatFromUIImage:selectedImage];
    if (_originalImage.channels() == 3) {
        cv::cvtColor(_originalImage, _previewImage, CV_RGB2GRAY);
    } else if (_originalImage.channels() == 4) {
        cv::cvtColor(_originalImage, _previewImage, CV_RGBA2GRAY);
    }
    _imageView.image = [UIImage imageWithCVMat:_originalImage];
    _showOriginButton.enabled = YES;
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

- (void)_applyWienerForImage:(cv::Mat)image withCompletion:(void (^)(cv::Mat image))completionBlock
{
    STKernel* currentKernel = [self _currentKernel];
    float gamma = 0.001f; // ??
    _wienerFilter.kernel = currentKernel;
    _wienerFilter.gamma = gamma;
    TICK;
    [_wienerFilter applyWienerFilter:image
                      withCompletion:^(cv::Mat deconvulvedImage) {
        TOCK;
        if (completionBlock) {
            completionBlock(deconvulvedImage);
        }
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
