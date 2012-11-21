//
//  ViewController.h
//  OrdoScan
//
//  Created by Mathieu Godart on 09/10/12.
//  Copyright (c) 2012 L'atelier du mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>

@interface ViewController : UIViewController <CvVideoCameraDelegate>

- (IBAction)launchScanTest;

@end
