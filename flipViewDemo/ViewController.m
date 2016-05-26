//
//  ViewController.m
//  flipViewDemo
//
//  Created by caochao on 16/5/26.
//  Copyright © 2016年 snailCC. All rights reserved.
//

#import "ViewController.h"
#import "FlipContainerView.h"
@interface ViewController ()<FlipContainerDelegate>
{
    
    FlipContainerView *testView;
    FlipContainerView *testView2;
}
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    testView= [[FlipContainerView alloc]initWithFrame:CGRectMake(8, 20, 130, 200)];
    testView.backgroundColor = [UIColor clearColor];
    testView.delegate = self;
    
    testView.flipDirection =  BasicFlipFromBottom;
    [self.view addSubview:testView];
    
    testView2= [[FlipContainerView alloc]initWithFrame:CGRectMake(208, 20, 130, 200)];
    testView2.backgroundColor = [UIColor clearColor];
    testView2.delegate = self;
    
    testView2.flipDirection =  BasicFlipFromLeft;
    [self.view addSubview:testView2];
}
#pragma mark - FlipContainerDelegate
- (UIView *) subViewForFlipContainerView:(FlipContainerView *)containerView atIndex:(NSInteger)index{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(containerView.frame) , CGRectGetHeight(containerView.frame))];
    if (index ==0) {
        view.backgroundColor = [UIColor redColor];
    }else if (index ==1){
        
        view.backgroundColor = [UIColor greenColor];
    }else{
        
        view = nil;
    }
    
    return view;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
