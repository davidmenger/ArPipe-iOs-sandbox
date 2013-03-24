//
//  CameraFrameSource.h
//  AR
//
//  Created by Menger David on 17.03.13.
//  Copyright (c) 2013 storyous.com s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <opencv2/opencv.hpp>

#import "BaseFrameSource.h"
#import "BasePipe.h"

@interface CameraFrameSource : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
@protected
    AVCaptureSession *captureSession;
    ArPipe::BaseFrameSource *frameSource;
}

- (CameraFrameSource*) init;
- (void) start;
- (void) stop;
- (void) setNextPipe: (ArPipe::BasePipe *) pipe;


@end
