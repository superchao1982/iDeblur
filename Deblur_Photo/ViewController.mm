//
//  ViewController.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/13/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "ViewController.h"
#import "gaussfilter.h"
#import "wienerfilter.h"
#import "cvWiener2.h"

#ifdef __cplusplus
    #include <opencv2/core/core.hpp>
    #import <opencv2/opencv.hpp>
    #import <opencv2/imgproc/imgproc_c.h>
    #import <opencv2/ml/ml.hpp>
#endif

using namespace cv;
using namespace std;

#define kappa 10000

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) NSInteger wienerRadius;
@property (nonatomic, assign) double noiseValue;

@end

@implementation ViewController

#pragma mark -
#pragma mark - UIViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    std::complex<double> c(0.999, 0.0123);
//    std::complex<double> c0(1.0f, 0.0f);
//    c = c0/c;

//    Mat onesMat0 = Mat::ones(2, 2, CV_32FC1)*2;
//    onesMat0.at<float>(0, 0) = 5;
//    Mat onesMat1 = Mat::ones(2, 2, CV_32FC1)*3;
//    
//    dft(onesMat0, onesMat0, cv::DFT_COMPLEX_OUTPUT);
//    dft(onesMat1, onesMat1, cv::DFT_COMPLEX_OUTPUT);
//    cout << "onesMat0 " << endl << onesMat0 << endl << endl;
//    cout << "onesMat1 " << endl << onesMat1 << endl << endl;
//    
//    Mat m0;
//    cv::mulSpectrums(onesMat0, onesMat1, m0, DFT_ROWS);
//    cout << "onesMat0.*onesMat1 " << endl  << m0 << endl;
//    cout << onesMat0.at<float>(0,0) << " " << onesMat0.at<float>(0,1) << " " << onesMat0.at<float>(0,2) << endl;
//    divideSpectrum(&m0);
//    idft(m0, m0, cv::DFT_SCALE|cv::DFT_REAL_OUTPUT);
////    dft(m0, m0, cv::DFT_INVERSE|cv::DFT_REAL_OUTPUT);
//    cout << "idft " << endl << m0 << endl << endl;

    float values[3][11] = {
        {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0004f, 0.0090f, 0.0176f, 0.0262f, 0.0347f, 0.0199f},
        {0.0346f, 0.0642f, 0.0728f, 0.0814f, 0.0900f, 0.0986f, 0.0900f, 0.0814f, 0.0728f, 0.0642f, 0.0346f},
        {0.0199f, 0.0347f, 0.0262f, 0.0176f, 0.0090f, 0.0004f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}
    };
    float values0[3][3]= {{0, 0.2, 0}, {0, 1, 0}, {0, 0, 0}};
    Mat PSF = Mat(3, 3, CV_32FC1, &values0);
    
    Mat img = imread("/Users/santatnt/Documents/MATLAB/lena1.png", IMREAD_GRAYSCALE);
    filter2D(img, img, -1, PSF);
    imwrite("/Users/santatnt/Desktop/blurred.png", img);
    img.convertTo(img, CV_32FC1, 1.0f/255.0f);

    cout << "img" << img(Range(0, 5), Range(0, 5)) << endl << endl;

    Mat Yf;
    dft(img, Yf, cv::DFT_COMPLEX_OUTPUT);
    cout << "Yf" << Yf(Range(0, 5), Range(0, 5)) << endl << endl;
    
    Mat Hf = Mat::zeros(img.rows, img.cols, CV_32FC1);
    PSF.copyTo(Hf(Range(0, PSF.rows), Range(0, PSF.cols)));
    dft(Hf, Hf, cv::DFT_COMPLEX_OUTPUT);
    cout <<"PSF " << PSF << endl << endl;;
    cout << "Hf " << Hf(Range(0, 5), Range(0, 5)) << endl << endl;

    reverseComplexSpectrum(&Hf);
    
    cout << "Hf " << Hf(Range(0, 5), Range(0, 5)) << endl << endl;

    Mat Fv;
    cv::mulSpectrums(Yf, Hf, Fv, DFT_ROWS);
    cout << "Hf " << Fv(Range(0, 5), Range(0, 5)) << endl << endl;
    
    idft(Fv, Fv, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);

    Fv.convertTo(Fv, CV_32FC1, 255.0f);

//    dft(img, img, cv::DFT_COMPLEX_OUTPUT);
//    idft(img, img, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);
//    img.convertTo(img, CV_32FC1, 255.0f);
    
    imwrite("/Users/santatnt/Desktop/deblurred.png", Fv);
    _imageView.image = [self.class imageWithCVMat:Fv];
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

string getImgType(int imgTypeInt)
{
    int numImgTypes = 35; // 7 base types, with five channel options each (none or C1, ..., C4)
    
    int enum_ints[] =       {CV_8U,  CV_8UC1,  CV_8UC2,  CV_8UC3,  CV_8UC4,
        CV_8S,  CV_8SC1,  CV_8SC2,  CV_8SC3,  CV_8SC4,
        CV_16U, CV_16UC1, CV_16UC2, CV_16UC3, CV_16UC4,
        CV_16S, CV_16SC1, CV_16SC2, CV_16SC3, CV_16SC4,
        CV_32S, CV_32SC1, CV_32SC2, CV_32SC3, CV_32SC4,
        CV_32F, CV_32FC1, CV_32FC2, CV_32FC3, CV_32FC4,
        CV_64F, CV_64FC1, CV_64FC2, CV_64FC3, CV_64FC4};
    
    string enum_strings[] = {"CV_8U",  "CV_8UC1",  "CV_8UC2",  "CV_8UC3",  "CV_8UC4",
        "CV_8S",  "CV_8SC1",  "CV_8SC2",  "CV_8SC3",  "CV_8SC4",
        "CV_16U", "CV_16UC1", "CV_16UC2", "CV_16UC3", "CV_16UC4",
        "CV_16S", "CV_16SC1", "CV_16SC2", "CV_16SC3", "CV_16SC4",
        "CV_32S", "CV_32SC1", "CV_32SC2", "CV_32SC3", "CV_32SC4",
        "CV_32F", "CV_32FC1", "CV_32FC2", "CV_32FC3", "CV_32FC4",
        "CV_64F", "CV_64FC1", "CV_64FC2", "CV_64FC3", "CV_64FC4"};
    
    for(int i=0; i<numImgTypes; i++)
    {
        if(imgTypeInt == enum_ints[i]) return enum_strings[i];
    }
    return "unknown image type";
}

#pragma mark -
#pragma mark - Actions

- (IBAction)testButtonAction:(id)sender
{
    Mat src = imread("/Users/santatnt/Desktop/matlab_image.png", CV_LOAD_IMAGE_UNCHANGED);
    Mat dst;
    src.convertTo(src, CV_BGR2GRAY);

    dft(src, dst, DFT_REAL_OUTPUT);
    
    _imageView.image = [self.class imageWithCVMat:dst];
}

- (IBAction)slider0ValueChanged:(UISlider *)slider
{
    _wienerRadius = slider.value;
    
    IplImage *tmp = cvLoadImage("/Users/santatnt/Desktop/opecv_test_image_original.png");
    IplImage *tmp2 = cvCreateImage(cvSize(tmp->width, tmp->height), IPL_DEPTH_8U, 1);
    cvCvtColor(tmp, tmp2, CV_RGB2GRAY);
    cvWiener2(tmp2, tmp2, _wienerRadius, _wienerRadius, _noiseValue);

    Mat matImage1 = cv::cvarrToMat(tmp2);
    UIImage* image1 = [self.class imageWithCVMat:matImage1];
    _imageView.image = image1;
    
    cvReleaseImage(&tmp);
    cvReleaseImage(&tmp2);
}

- (IBAction)slider1ValueChanged:(UISlider *)slider {
    _noiseValue = slider.value;
    
    IplImage *tmp = cvLoadImage("/Users/santatnt/Desktop/opecv_test_image_original.png");
    IplImage *tmp2 = cvCreateImage(cvSize(tmp->width, tmp->height), IPL_DEPTH_8U, 1);
    cvCvtColor(tmp, tmp2, CV_RGB2GRAY);
    cvWiener2(tmp2, tmp2, _wienerRadius, _wienerRadius, _noiseValue);
    
    Mat matImage1 = cv::cvarrToMat(tmp2);
    UIImage* image1 = [self.class imageWithCVMat:matImage1];
    _imageView.image = image1;
    
    cvReleaseImage(&tmp);
    cvReleaseImage(&tmp2);
}

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

- (UIImage *)UIImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(( CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
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
