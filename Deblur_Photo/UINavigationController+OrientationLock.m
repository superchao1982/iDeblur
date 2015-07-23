//
//  UINavigationController+OrientationLock.m
//  Deblur_Photo
//
//  Created by Yaroslav on 7/23/15.
//  Copyright (c) 2015 brekhunchenko. All rights reserved.
//

#import "UINavigationController+OrientationLock.h"

@implementation UINavigationController (OrientationLock)

- (BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end

@implementation UIImagePickerController (OrientationLock)

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
