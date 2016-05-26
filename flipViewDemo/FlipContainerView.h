//
//  FlipContainerView.h
//  FlipDemo
//
//  Created by caochao on 16/5/25.
//  Copyright © 2016年 snailCC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    BasicFlipFromTop,
    BasicFlipFromBottom,
    BasicFlipFromLeft,
    BasicFlipFromRight,
} BasicFlipDirection;
@class FlipContainerView;

@protocol FlipContainerDelegate <NSObject>

- (UIView *) subViewForFlipContainerView:(FlipContainerView *)containerView atIndex:(NSInteger)index;

@end

@interface FlipContainerView : UIControl
@property (nonatomic,assign) id<FlipContainerDelegate> delegate;
@property (nonatomic,assign)NSTimeInterval duration;
@property (nonatomic,assign)BasicFlipDirection flipDirection;
@end
