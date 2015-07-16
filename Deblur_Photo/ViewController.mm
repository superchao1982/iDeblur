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
    float values0[3][3]= {{0, 0, 0}, {0, 1, 0}, {0, 0, 0}};
    Mat PSF = Mat(3, 3, CV_32FC1, &values0);
    
    Mat img = imread("/Users/santatnt/Documents/MATLAB/lena1.png", IMREAD_GRAYSCALE);
    img.convertTo(img, CV_32FC1, 1.0f/255.0f);
    filter2D(img, img, -1, PSF);

    cout << "img" << img(Range(0, 5), Range(0, 5)) << endl << endl;

    Mat Yf;
    dft(img, Yf, cv::DFT_COMPLEX_OUTPUT);
    cout << "Yf" << Yf(Range(0, 5), Range(0, 5)) << endl << endl;
    
    Mat Hf = Mat::zeros(img.rows, img.cols, CV_32FC1);
    PSF.copyTo(Hf(Range(0, PSF.rows), Range(0, PSF.cols)));
    dft(Hf, Hf, cv::DFT_COMPLEX_OUTPUT);
    cout <<"PSF " << PSF << endl << endl;;
    cout << "Hf " << Hf(Range(0, 5), Range(0, 5)) << endl << endl;

    divideSpectrum(&Hf);
    
    cout << "Hf " << Hf(Range(0, 5), Range(0, 5)) << endl << endl;

    Mat Fv;
    cv::mulSpectrums(Yf, Hf, Fv, DFT_ROWS);
    cout << "Hf " << Fv(Range(0, 5), Range(0, 5)) << endl << endl;
    
    idft(Fv, Fv, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);

    Fv.convertTo(Fv, CV_32FC1, 255.0f);

//    dft(img, img, cv::DFT_COMPLEX_OUTPUT);
//    idft(img, img, cv::DFT_REAL_OUTPUT | cv::DFT_SCALE);
//    img.convertTo(img, CV_32FC1, 255.0f);
    
    imwrite("/Users/santatnt/Desktop/test.png", Fv);
    _imageView.image = [self.class imageWithCVMat:Fv];
}

void divideSpectrum(Mat* array)
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

#pragma mark - 

- (void)_deblurTestFunciton
{
    int height,width,step,channels,depth;
    uchar* data1;
    
    CvMat *dft_A;
    CvMat *dft_B;
    
    CvMat *dft_C;
    IplImage* im;
    IplImage* im1;
    
    IplImage* image_ReB;
    IplImage* image_ImB;
    
    IplImage* image_ReC;
    IplImage* image_ImC;
    IplImage* complex_ImC;
    CvScalar val;
    
    IplImage* k_image_hdr;
    int i,j,k;
    
    FILE *fp;
    fp = fopen("test.txt","w+");
    int dft_M,dft_N;
    int dft_M1,dft_N1;
    
    CvMat* cvShowDFT1(IplImage*, int, int,char*);
//    void cvShowInvDFT1(IplImage*, CvMat*, int, int,char*);
    
    im1 = cvLoadImage("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg");
    //    cvNamedWindow("Original-Color", 0);
    //    cvShowImage("Original-Color", im1);
    im = cvLoadImage("/Users/santatnt/Desktop/3ca5ceda07d41d58574075ddea1a73ad.jpg", CV_LOAD_IMAGE_GRAYSCALE );
    if( !im )
        return;
    
    //    cvNamedWindow("Original-Gray", 0);
    //    cvShowImage("Original-Gray", im);
    
    IplImage* k_image;
    int rowLength= 11;
    long double kernels[11*11];
    CvMat kernel;
    int x,y;
    long double PI_F=3.14159265358979;
    
    long double SIGMA = 0.014089642;
    long double EPS = 2.718;
    long double numerator,denominator;
    long double value;
    
    numerator = (pow((float)-3,2) + pow((float) 0,2))/(2*pow((float)SIGMA,2));
    denominator = sqrt((float) (2 * PI_F * pow(SIGMA,2)));
    value = (pow((float)EPS, (float)-numerator))/denominator;
    
    for(x = -5; x < 6; x++){
        for (y = -5; y < 6; y++)
        {
            numerator = (pow((float)x,2) + pow((float)y,2))/(2.0*pow(SIGMA,2));
            denominator = sqrt((2.0 * 3.14159265358979 * pow(SIGMA,2)));
            value = (pow(EPS,-numerator))/denominator;
            kernels[x*rowLength +y+55] = (float)value;
            
        }
    }
    
    kernel= cvMat(rowLength, // number of rows
                  rowLength, // number of columns
                  CV_32FC1, // matrix data type
                  &kernels);
    k_image_hdr = cvCreateImageHeader( cvSize(rowLength,rowLength), IPL_DEPTH_32F,1);
    k_image = cvGetImage(&kernel,k_image_hdr);
    
    height = k_image->height;
    width = k_image->width;
    step = k_image->widthStep/sizeof(float);
    depth = k_image->depth;
    
    channels = k_image->nChannels;
    data1 = (uchar *)(k_image->imageData);

    dft_M = cvGetOptimalDFTSize( im->height - 1 );
    dft_N = cvGetOptimalDFTSize( im->width - 1 );
    
    dft_M1 = cvGetOptimalDFTSize( im->height+3 - 1 );
    dft_N1 = cvGetOptimalDFTSize( im->width+3 - 1 );
    
    dft_A = cvShowDFT1(im, dft_M1, dft_N1,"original");
    dft_B = cvShowDFT1(k_image,dft_M1,dft_N1,"kernel");
    
    dft_C = cvCreateMat( dft_M1, dft_N1, CV_64FC2 );
    
    cvMulSpectrums(dft_A,dft_B,dft_C,CV_DXT_MUL_CONJ);

    image_ReC = cvCreateImage( cvSize(dft_N1, dft_M1), IPL_DEPTH_64F, 1);
    image_ImC = cvCreateImage( cvSize(dft_N1, dft_M1), IPL_DEPTH_64F, 1);
    complex_ImC = cvCreateImage( cvSize(dft_N1, dft_M1), IPL_DEPTH_64F, 2);
    
    cvSplit( dft_C, image_ReC, image_ImC, 0, 0 );
    
    // Compute A^2 + B^2 of denominator or blur kernel
    image_ReB = cvCreateImage( cvSize(dft_N1, dft_M1), IPL_DEPTH_64F, 1);
    image_ImB = cvCreateImage( cvSize(dft_N1, dft_M1), IPL_DEPTH_64F, 1);
    
    // Split Real and imaginary parts
    cvSplit( dft_B, image_ReB, image_ImB, 0, 0 );
    cvPow( image_ReB, image_ReB, 2.0);
    cvPow( image_ImB, image_ImB, 2.0);
    cvAdd(image_ReB, image_ImB, image_ReB,0);
    
    val = cvScalarAll(kappa);
    cvAddS(image_ReB,val,image_ReB,0);
    
    //Divide Numerator/A^2 + B^2
    cvDiv(image_ReC, image_ReB, image_ReC, 1.0);
    cvDiv(image_ImC, image_ReB, image_ImC, 1.0);
    
    // Merge Real and complex parts
    cvMerge(image_ReC, image_ImC, NULL, NULL, complex_ImC);
    
    Mat matImage = cv::cvarrToMat(im);
    UIImage* image = [self.class imageWithCVMat:matImage];
    [self _showImage:image title:@""];
    
    cvSaveImage("/Users/santatnt/Desktop/opencv_test_image.png", im);
    
    // Perform Inverse
    [self cvShowInvDFT1:im dft_a:(CvMat *)complex_ImC dft_M:dft_M1 dft_N:dft_N1 src:"Weiner o/p k=10000 SIGMA=0.014089642"];
}

CvMat* cvShowDFT1(IplImage* im, int dft_M, int dft_N,char* src)
{
    IplImage* realInput;
    IplImage* imaginaryInput;
    IplImage* complexInput;
    
    CvMat* dft_A, tmp;
    
    IplImage* image_Re;
    IplImage* image_Im;
    
    char str[80];
    
    double m, M;
    
    realInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 1);
    imaginaryInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 1);
    complexInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 2);
    
    cvScale(im, realInput, 1.0, 0.0);
    cvZero(imaginaryInput);
    cvMerge(realInput, imaginaryInput, NULL, NULL, complexInput);
    
    dft_A = cvCreateMat( dft_M, dft_N, CV_64FC2 );
    image_Re = cvCreateImage( cvSize(dft_N, dft_M), IPL_DEPTH_64F, 1);
    image_Im = cvCreateImage( cvSize(dft_N, dft_M), IPL_DEPTH_64F, 1);
    
    // copy A to dft_A and pad dft_A with zeros
    cvGetSubRect( dft_A, &tmp, cvRect(0,0, im->width, im->height));
    cvCopy( complexInput, &tmp, NULL );
    if( dft_A->cols > im->width )
    {
        cvGetSubRect( dft_A, &tmp, cvRect(im->width,0, dft_A->cols - im->width, im->height));
        cvZero( &tmp );
    }
    
    // no need to pad bottom part of dft_A with zeros because of
    // use nonzero_rows parameter in cvDFT() call below
    
    cvDFT( dft_A, dft_A, CV_DXT_FORWARD, complexInput->height );
    
    strcpy(str,"DFT -");
    strcat(str,src);
    //    cvNamedWindow(str, 0);
    
    // Split Fourier in real and imaginary parts
    cvSplit( dft_A, image_Re, image_Im, 0, 0 );
    
    // Compute the magnitude of the spectrum Mag = sqrt(Re^2 + Im^2)
    cvPow( image_Re, image_Re, 2.0);
    cvPow( image_Im, image_Im, 2.0);
    cvAdd( image_Re, image_Im, image_Re, NULL);
    cvPow( image_Re, image_Re, 0.5 );
    
    // Compute log(1 + Mag)
    cvAddS( image_Re, cvScalarAll(1.0), image_Re, NULL ); // 1 + Mag
    cvLog( image_Re, image_Re ); // log(1 + Mag)
    
    cvMinMaxLoc(image_Re, &m, &M, NULL, NULL, NULL);
    cvScale(image_Re, image_Re, 1.0/(M-m), 1.0*(-m)/(M-m));
    //    cvShowImage(str, image_Re);
    return(dft_A);
}

- (void)cvShowInvDFT1:(IplImage *)im dft_a:(CvMat *)dft_A dft_M:(int)dft_M dft_N:(int)dft_N src:(char *)src
//void cvShowInvDFT1(IplImage* im, CvMat* dft_A, int dft_M, int dft_N,char* src)
{
    
    IplImage* realInput;
    IplImage* imaginaryInput;
    IplImage* complexInput;
    
    IplImage * image_Re;
    IplImage * image_Im;
    
    double m, M;
    char str[80];
    
    realInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 1);
    imaginaryInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 1);
    complexInput = cvCreateImage( cvGetSize(im), IPL_DEPTH_64F, 2);
    
    image_Re = cvCreateImage( cvSize(dft_N, dft_M), IPL_DEPTH_64F, 1);
    image_Im = cvCreateImage( cvSize(dft_N, dft_M), IPL_DEPTH_64F, 1);
    
    //cvDFT( dft_A, dft_A, CV_DXT_INV_SCALE, complexInput->height );
    cvDFT( dft_A, dft_A, CV_DXT_INV_SCALE, dft_M);
    strcpy(str,"DFT INVERSE – ");
    strcat(str,src);
    //    cvNamedWindow(str, 0);
    
    // Split Fourier in real and imaginary parts
    cvSplit( dft_A, image_Re, image_Im, 0, 0 );
    
    // Compute the magnitude of the spectrum Mag = sqrt(Re^2 + Im^2)
    cvPow( image_Re, image_Re, 2.0);
    cvPow( image_Im, image_Im, 2.0);
    cvAdd( image_Re, image_Im, image_Re, NULL);
    cvPow( image_Re, image_Re, 0.5 );
    
    // Compute log(1 + Mag)
    cvAddS( image_Re, cvScalarAll(1.0), image_Re, NULL ); // 1 + Mag
    cvLog( image_Re, image_Re ); // log(1 + Mag)
    
    cvMinMaxLoc(image_Re, &m, &M, NULL, NULL, NULL);
    cvScale(image_Re, image_Re, 1.0/(M-m), 1.0*(-m)/(M-m));
    //cvCvtColor(image_Re, image_Re, CV_GRAY2RGBA);
    
    //    cvShowImage(str, image_Re);
 
//    Mat matImage = cv::cvarrToMat(image_Re);
//    UIImage* image = [self.class imageWithCVMat:matImage];
//    [self _showImage:image];
//    cvSaveImage("/Users/santatnt/Desktop/opencv_test_image.png", image_Re);
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
