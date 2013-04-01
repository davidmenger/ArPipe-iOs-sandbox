//
//  ViewController.m
//  AR
//
//  Created by Menger David on 16.03.13.
//  Copyright (c) 2013 storyous.com s.r.o. All rights reserved.
//

#import "ViewController.h"
#import "./../Framework/ArPipeFramework.h"
#import "./../Framework/ArPipeObjcUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CameraFrameSource *frameSource = [[CameraFrameSource alloc] init];
    
    BaseArView *previewLayer = [[BaseArView alloc]
            initWithFrameAndCaptureSession: self.view.frame captureSession: [frameSource captureSession]];
    
    [frameSource setNextPipe: [previewLayer pipeConnector]];
    
    [self.view addSubview: previewLayer];
    
    [previewLayer showPreviewLayer];
    
    
    
    [frameSource start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
