//
//  CameraFrameSource.m
//  AR
//
//  Created by Menger David on 17.03.13.
//  Copyright (c) 2013 storyous.com s.r.o. All rights reserved.
//


#import "CameraFrameSource.h"
#import "BaseFrameContainer.h"

@implementation CameraFrameSource

-(CameraFrameSource*)init
{
    frameSource = new ArPipe::BaseFrameSource();
    return self;
}

-(bool)initCameraSession
{
    NSError *error = nil;
    
    // Create the session
    captureSession = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
            
        [captureSession addInput:input];
        
        // Create a VideoDataOutput and add it to the session
        AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
        [captureSession addOutput:output];
        
        
        
        // Configure your output.
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        dispatch_release(queue);
        
        // Specify the pixel format
        output.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        
        // If you wish to cap the frame rate to a known value, such as 15 fps, set
        // minFrameDuration.
        
        //output.minFrameDuration = CMTimeMake(1, 60); //1,15
        
        
        
            
        return true;
    } else {
        NSLog(@"%@", error);
        return false;
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput
        didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection
{
    if (frameSource) {
        ArPipe::BaseFrameContainer *frm = new ArPipe::BaseFrameContainer([self imageFromSampleBuffer:sampleBuffer]);
        frameSource->getNextPipe()->pushNewFrameContainer(frm, frameSource->getNextPipe());
    }
}

-(void)start
{
    [captureSession startRunning];
}

-(void)stop
{
    [captureSession stopRunning];
}

-(void)dealloc
{
    if (captureSession) {
        
    }
    [super dealloc];
}

// Create a UIImage from sample buffer data
- (cv::Mat) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for :e media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create a bitmap graphics context with the sample buffer data
    
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGFloat cols = CGImageGetWidth(quartzImage);
    CGFloat rows = CGImageGetHeight(quartzImage);
    
    
    
    cv::Mat cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone | kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), quartzImage);
    
    
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRelease(quartzImage);
    
    
    return cvMat;
}

- (void) setNextPipe:(ArPipe::BasePipe *)pipe
{
    frameSource->setNextPipe(pipe);
}

@end
