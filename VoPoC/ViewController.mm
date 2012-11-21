//
//  ViewController.m
//  OrdoScan
//
//  Created by Mathieu Godart on 09/10/12.
//  Copyright (c) 2012 L'atelier du mobile. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/imgproc/imgproc_c.h>

using namespace cv;



#define kClassifierFace @"haarcascade_frontalface_alt"
#define kClassifierEye  @"haarcascade_eye_tree_eyeglasses"



/** Global variables */
String face_cascade_name;
String eyes_cascade_name;
CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
string window_name = "Capture - Face detection";
RNG rng(12345);



@interface ViewController ()

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *previewImageView;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end



@implementation ViewController



// Do any additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Funcky useless code.
    self.previewImageView.layer.borderColor = UIColor.darkGrayColor.CGColor;
    self.previewImageView.layer.borderWidth = 1;
    self.previewImageView.layer.cornerRadius = 15;
    self.previewImageView.clipsToBounds = YES;
        
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.previewImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
//    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = YES;
    self.videoCamera.delegate = self;

    NSString *classifPath;
    
    // Load the cascade classifier for face.
    classifPath = [[NSBundle mainBundle] pathForResource:kClassifierFace ofType:@"xml"];
    
    face_cascade_name = String([classifPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if( !face_cascade.load( face_cascade_name ) ){ NSLog(@"Error loading faces"); exit(-1); };

    NSLog(@"Loaded face classifier at %@.", classifPath);

    // Load the cascade classifier for eyes.
    classifPath = [[NSBundle mainBundle] pathForResource:kClassifierEye ofType:@"xml"];
    
    eyes_cascade_name = String([classifPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if( !eyes_cascade.load( eyes_cascade_name ) ){ NSLog(@"Error loading eyes"); exit(-1); };
    
    NSLog(@"Loaded eyes classifier at %@.", classifPath);

    // Test functions.
    // This can be commented out and ignored.
#ifdef AUTO_START_SCAN_TEST
    [self performSelector:@selector(launchScanTest) withObject:nil afterDelay:0.3];
#endif

    [[UIScreen mainScreen] setBrightness:1.0];
}



// Launch the image scanner with a test image,
// and show the camera interface to take a picture.
- (IBAction)launchScanTest
{
    [self.videoCamera start];
}



- (void)viewDidUnload
{
    [self setPreviewImageView:nil];
    [super viewDidUnload];
}



#pragma mark - Protocol CvVideoCameraDelegate



#ifdef __cplusplus
// Do some OpenCV stuff with the video image.
- (void)processImage:(Mat&)frame;
{
//    Mat image_copy;
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
    
    
    std::vector<cv::Rect> faces;
    Mat frame_gray;
    
//    cvtColor( frame, frame_gray, CV_BGR2GRAY );
//    cvtColor( frame, frame_gray, CV_GRA );
    
    frame_gray = frame;
//    equalizeHist( frame_gray, frame_gray );
//    medianBlur(frame_gray, frame_gray, 3);
    blur(frame_gray, frame_gray, cv::Size(3, 3));
    
    //-- Detect faces
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
    
    for( int i = 0; i < faces.size(); i++ )
    {
        cv::Point center( faces[i].x + faces[i].width*0.5,
                         faces[i].y + faces[i].height*0.5 );
        ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
        
        Mat faceROI = frame_gray( faces[i] );
        std::vector<cv::Rect> eyes;
        
        //-- In each face, detect eyes
        eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE,
                                      cv::Size(30, 30) );
        
        for( int j = 0; j < eyes.size(); j++ )
        {
            cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5,
                             faces[i].y + eyes[j].y + eyes[j].height*0.5 );
            int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
            circle( frame, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
        }
    }

}
#endif



@end
















