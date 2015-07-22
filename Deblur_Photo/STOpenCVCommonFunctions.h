//
//  STOpenCVCommonFunctions.h
//  Deblur_Photo
//
//  Created by Yaroslav on 7/17/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface STOpenCVCommonFunctions : NSObject

+ (NSString *)matType2String:(int)matTypeInt;

@end
