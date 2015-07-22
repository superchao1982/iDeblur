//
//  STWienerFilter.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/18/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "STWienerFilter.h"
#import "STFocusBlurKernel.h"
#import "STWienerFilterOperation.h"

using namespace cv;
using namespace std;

@interface STWienerFilter()

@property (nonatomic, strong) NSOperationQueue* operationQueue;

@end

@implementation STWienerFilter

#pragma mark -
#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if(self) {
        _gamma = 0.01f;
        _PSF = [[STFocusBlurKernel alloc] initFocusBlurKernelWithRadius:10.0f
                                                            edgeFeather:10.0f
                                                     correctionStrength:10.0f];
        
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

#pragma mark -
#pragma mark - Class methods

- (void)applyWienerFilter:(cv::Mat)image
           withCompletion:(void (^)(cv::Mat))completionBlock
{
    [_operationQueue cancelAllOperations];
    
    STWienerFilterOperation* operation = [[STWienerFilterOperation alloc] initWithCVMat:image kernel:_PSF gamma:_gamma];
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [_operationQueue addOperation:operation];
    __weak typeof(operation) weakOperation = operation;
    [operation setCompletionBlock:^{
        if (weakOperation.cancelled == NO) {
            cv::Mat result = [weakOperation editedImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result);
            });
        }
    }];
}

@end
