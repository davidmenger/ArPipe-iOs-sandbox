//
//  ViewController.m
//  AR
//
//  Created by Menger David on 16.03.13.
//  Copyright (c) 2013 storyous.com s.r.o. All rights reserved.
//

#import "ViewController.h"
#import "./../Framework/ArPipeFramework.h"



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
    
    ArPipe::PipeLine* pipeline = new ArPipe::PipeLine([frameSource frameSource]);
    
    pipeline->addPipe(ArPipe::PolarRotate::init(90));
    pipeline->addPipe(ArPipe::BlackAndWhite::init());
    ArPipe::BlackAndWhite *blackAndWhite = (ArPipe::BlackAndWhite*) pipeline->back();
    
    pipeline->addPipe(ArPipe::Threshold::init());
    pipeline->addPipe(ArPipe::FindContours::init()
                      ->setTypeTree());
    pipeline->addPipe(ArPipe::DetectPolygons::init()->setOnlyConvexObjects()
                      ->setRequiredSideCount(4)
                      ->setComplexityKoef(0.5));
    
    ArPipe::FiducidalMarkerIdentifier *mId = (ArPipe::FiducidalMarkerIdentifier*) pipeline
        ->addNextPipe(ArPipe::FiducidalMarkerIdentifier::init()
                      ->setFrameSource(blackAndWhite)
                      ->setShapesSource(pipeline));
    
    blackAndWhite->addNextPipe(mId);
    
    ArPipe::CameraApply *camApply
        = (ArPipe::CameraApply*) mId->addNextPipe(
                            ArPipe::BlackAndWhite::init()->toColor()
                    )->addNextPipe(ArPipe::CameraApply::init());
    
    camApply->addNextPipe(ArPipe::DrawContours::init())
        ->addNextPipe([previewLayer pipeConnector]);
    
    previewLayer->cp = camApply->getCameraParameters();
    
    [self.view addSubview: previewLayer];
    
    [previewLayer showFrameOutput];
    [previewLayer showGlView];
    
    [frameSource start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
