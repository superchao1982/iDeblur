//
//  ViewController.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/13/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "ViewController.h"

#import <UIActionSheet+BlocksKit.h>

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
    
    vector<Mat> channels(3);
    split(img, channels);
    
    channels[0] = applyWienerFilterForChannels(channels[0], PSF, 0.01f);
    channels[1] = applyWienerFilterForChannels(channels[1], PSF, 0.01f);
    channels[2] = applyWienerFilterForChannels(channels[2], PSF, 0.01f);
    
    merge(channels, img);
    
    imwrite("/Users/santatnt/Desktop/deblurred.png", img);
}

#pragma mark -
#pragma mark -

Mat applyWienerFilterForChannels(Mat img, Mat PSF, float gamma)
{
    if (img.channels() > 1) {
        return img;
    }
    
    img.convertTo(img, CV_32FC1, 1.0f/255.0f);
    
    Mat Hf = Mat::zeros(img.rows, img.cols, CV_32FC1);
    PSF.copyTo(Hf(Range(0, PSF.rows), Range(0, PSF.cols)));
    dft(Hf, Hf, cv::DFT_COMPLEX_OUTPUT);
    
    Mat xHf0;
    cv::mulSpectrums(Hf, Hf, xHf0, DFT_ROWS, true);
    Mat xHf1;
    cv::mulSpectrums(Hf, Hf, xHf1, DFT_ROWS, true);
    xHf1 = xHf1 + gamma;
    
    reverseComplexSpectrum(&xHf1);
    
    Mat xHf;
    cv::mulSpectrums(xHf0, xHf1, xHf, DFT_ROWS);
    
    reverseComplexSpectrum(&Hf);
    
    Mat iHf;
    cv::mulSpectrums(Hf, xHf, iHf, DFT_ROWS);
    
    Mat Yf;
    dft(img, Yf, cv::DFT_COMPLEX_OUTPUT);
    Mat Fv;
    cv::mulSpectrums(Yf, iHf, Fv, DFT_ROWS);
    
    idft(Fv, Fv, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);
    
    Fv.convertTo(Fv, CV_32FC1, 255.0f);
    
    return Fv;
}

void reverseComplexSpectrum(Mat* array)
{
    for (int i = 0; i < (*array).rows; i++) {
        for (int j = 0; j < (*array).cols*2; j+=2) {
            std::complex<float> c0(1.0f, 0.0f);
            float a = (*array).at<float>(i, j);
            float b = (*array).at<float>(i, j+1);
            std::complex<float> c1(a, b);
            
            std::complex<float> c2 = c0/c1;
            (*array).at<float>(i, j) = c2.real();
            (*array).at<float>(i, j+1) = c2.imag();
        }
    }
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
