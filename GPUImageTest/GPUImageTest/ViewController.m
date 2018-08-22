//
//  ViewController.m
//  GPUImageTest
//
//  Created by huangjian on 2018/8/17.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
@interface ViewController ()
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) UIButton *beautifyButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera=[[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation=UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    [self setButton];
}
-(void)setButton
{
    self.beautifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautifyButton.backgroundColor = [UIColor whiteColor];
    [self.beautifyButton setTitle:@"开启" forState:UIControlStateNormal];
    [self.beautifyButton setTitle:@"关闭" forState:UIControlStateSelected];
    [self.beautifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.beautifyButton addTarget:self action:@selector(beautifyTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.beautifyButton];
    self.beautifyButton.frame=CGRectMake(self.view.bounds.size.width/2-50, self.view.bounds.size.height-30, 100, 40);
}
-(void)beautifyTouch:(UIButton *)btn
{
    btn.selected=!btn.selected;
    if (!btn.selected) {
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.filterView];
    }else {
        [self.videoCamera removeAllTargets];
        [self filter];
    }
}
-(void)filter
{
    GPUImageFilterGroup *group=[[GPUImageFilterGroup alloc]init];
    GPUImageBilateralFilter *bilateraFilter=[[GPUImageBilateralFilter alloc]init];
    bilateraFilter.distanceNormalizationFactor = 7.0;
    [group addFilter:bilateraFilter];
    
    // 美白滤镜
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    //设置美白参数
    filter.brightness = 0.3;
    [group addFilter:filter];
    
//    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
//    [group addFilter:cannyEdgeFilter];

    [bilateraFilter addTarget:filter];
    
    group.initialFilters = [NSArray arrayWithObjects:bilateraFilter,nil];
    group.terminalFilter = filter;
    
    [self.videoCamera addTarget:group];
    [group addTarget:self.filterView];
    
}
@end
