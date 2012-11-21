//
//  UIImage+CvMat.h
//  OrdoScan
//
//  Created by Mathieu Godart on 22/10/12.
//  Copyright (c) 2012 L'atelier du mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>



@interface UIImage (CvMat)

- (cv::Mat)cvMat;

- (cv::Mat)cvMatGray;

+ (UIImage *)imageWithCVMat:(cv::Mat)cvMat;

@end
