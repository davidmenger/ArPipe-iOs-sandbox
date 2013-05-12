# ArPipe Framework Sandbox for iOS
==================

iOs Sandbox for ArPipe Framework

## Requirements

Sandbox is optimized for iOS 5.0 and higher. Only requirement is adding lastest version of Framework <https://github.com/megii/ArPipe-Framework> into Framework directory.

To run application is required to have Xcode installed with iOS 5.0 or greater support and valid developer certificate to deploy application on device.

## Quick start

- Download lastest release of [Framework](https://github.com/megii/ArPipe-Framework) and [sandbox](https://github.com/megii/ArPipe-Framework)
- Insert ArPipe framework into Framework directory in root of sandbox
- Open AR.xcodeproj in your xcode
- Build and Run using Xcode

## Hello World sample

In ViewController.mm class is prepared basic video processing loop with camera video source and display output. The only thing, that must developer do, is add Pipes into PipeLine.
  
    CameraFrameSource *frameSource = [[CameraFrameSource alloc] init];
    
    BaseArView *previewLayer = [[BaseArView alloc]
            initWithFrameAndCaptureSession: self.view.frame captureSession: [frameSource captureSession]];
    
    ArPipe::PipeLine* pipeline = new ArPipe::PipeLine([frameSource frameSource]);
    
    pipeline->addPipe(ArPipe::PolarRotate::init(90));
    pipeline->addPipe(ArPipe::BlackAndWhite::init());
    pipeline->addPipe(ArPipe::Threshold::init());
    
    pipeline->addNextPipe([previewLayer pipeConnector]);
    
    [self.view addSubview: previewLayer];
    [previewLayer showFrameOutput];
    [frameSource start];

There is `CameraFrameSource` object, which provides video data into `PipeLine` and after `PipeLine` there is attached a `BaseArView` preview layer. Purpose of sampe is rotate the image ninety degrees, convert it from color to black and white and then apply threshold filter. Result is shown on screen of device.