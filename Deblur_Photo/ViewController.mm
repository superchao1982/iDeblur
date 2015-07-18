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
//#import "STFocusBlurKernel.h"

using namespace cv;
using namespace std;

@interface ViewController ()  < UIImagePickerControllerDelegate, UINavigationControllerDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float PSFValues[3][11] = {
        {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0004f, 0.0090f, 0.0176f, 0.0262f, 0.0347f, 0.0199f},
        {0.0346f, 0.0642f, 0.0728f, 0.0814f, 0.0900f, 0.0986f, 0.0900f, 0.0814f, 0.0728f, 0.0642f, 0.0346f},
        {0.0199f, 0.0347f, 0.0262f, 0.0176f, 0.0090f, 0.0004f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}
    };
    Mat PSF = Mat(3, 11, CV_32FC1, &PSFValues);
    Mat img = imread("/Users/santatnt/Documents/MATLAB/lena1.png", IMREAD_UNCHANGED);
    filter2D(img, img, -1, PSF, cv::Point(-1,-1), 0, BORDER_CONSTANT);
    imwrite("/Users/santatnt/Desktop/blurred.png", img);
    
    STWienerFilter* wienerFilter = [[STWienerFilter alloc] init];
    wienerFilter.gamma = 0.0f;
    [wienerFilter applyWienerFilter:&img];

    imwrite("/Users/santatnt/Desktop/deblurred.png", img);
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

@end
