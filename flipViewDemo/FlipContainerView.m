//
//  FlipContainerView.m
//  FlipDemo
//
//  Created by caochao on 16/5/25.
//  Copyright © 2016年 snailCC. All rights reserved.
//

#import "FlipContainerView.h"

@interface FlipContainerView(){
    
    
    NSInteger _filpIndex;
}

@property (nonatomic,assign) BOOL reverse;
@property (nonatomic,retain) NSMutableArray *subContentViews;
@end

@implementation FlipContainerView
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.duration = 1.0;
        self.flipDirection = BasicFlipFromLeft;
        _filpIndex = 0;
        _subContentViews = [[NSMutableArray alloc]init];
        
        [self setup];
    }
    return self;
}

#pragma mark - Private instance methods

- (void)setup
{
    
    self.layer.cornerRadius = 4.f;
    
    self.reverse = NO;
    [self addTarget:self action:@selector(loadSubViews)
   forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)setDelegate:(id<FlipContainerDelegate>)delegate{
    
    _delegate = delegate;
    
    // load the first view
    [self loadSubViews];
}
- (void)loadSubViews{
    
    if ([self.delegate respondsToSelector:@selector(subViewForFlipContainerView:atIndex:)]) {
        
        UIView *view = [self.delegate subViewForFlipContainerView:self atIndex:[_subContentViews count]];
        
        if (view !=nil) {
            view.userInteractionEnabled = NO;
            [_subContentViews addObject:view];
            if ([_subContentViews count]==1) {
                [self addSubview:view];
            }
        }else{
            
            view = _subContentViews[_filpIndex-1];
            if (_filpIndex>=[_subContentViews count]) {
                _filpIndex =0;
            }
        }
        if ([_subContentViews count]>=2) {
            
            self.reverse  = [_subContentViews indexOfObject:view]<_filpIndex;
            
            [self flipFromView:_subContentViews[_filpIndex] toView:view];
        }
    }
}

#pragma mark - flip

- (void)flipFromView:(UIView *)fromView toView:(UIView *)toView{
    
    if (fromView ==nil || toView ==nil) {
        return;
    }
    [self addSubview:toView];
    [self sendSubviewToBack:toView];
    
    // Add a perspective transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.001;
    [self.layer setSublayerTransform:transform];
    
    // create two-part snapshots of both the from- and to- views
    NSArray *toViewSnapshots = [self createSnapshots:toView afterScreenUpdates:YES];
    UIView* flippedSectionOfToView = toViewSnapshots[self.reverse ? 0 : 1];
    
    NSArray *fromViewSnapshots = [self createSnapshots:fromView afterScreenUpdates:NO];
    UIView* flippedSectionOfFromView = fromViewSnapshots[self.reverse ? 1 : 0];
    
    // replace the from- and to- views with container views that include gradients
    flippedSectionOfFromView = [self addShadowToView:flippedSectionOfFromView reverse:!self.reverse];
    UIView* flippedSectionOfFromViewShadow = flippedSectionOfFromView.subviews[1];
    flippedSectionOfFromViewShadow.alpha = 0.0;
    
    flippedSectionOfToView = [self addShadowToView:flippedSectionOfToView reverse:self.reverse];
    UIView* flippedSectionOfToViewShadow = flippedSectionOfToView.subviews[1];
    flippedSectionOfToViewShadow.alpha = 1.0;
    
    
    // change the anchor point so that the view rotate around the correct edge
    if (self.flipDirection == BasicFlipFromRight ||self.flipDirection == BasicFlipFromLeft) {
        [self updateAnchorPointAndOffset:CGPointMake(self.reverse ? 0.0 : 1.0, 0.5) view:flippedSectionOfFromView];
        [self updateAnchorPointAndOffset:CGPointMake(self.reverse ? 1.0 : 0.0, 0.5) view:flippedSectionOfToView];
        
        
    }else{
        
        [self updateAnchorPointAndOffset:CGPointMake(0.5,self.reverse ? 0.0 : 1.0) view:flippedSectionOfFromView];
        [self updateAnchorPointAndOffset:CGPointMake(0.5,self.reverse ? 1.0 : 0.0) view:flippedSectionOfToView];

    }
    // rotate the to- view by 90 degrees, hiding it
    flippedSectionOfToView.layer.transform = [self rotate:self.reverse ? M_PI_2 : -M_PI_2];
        // animate
    
    
            [UIView animateKeyframesWithDuration:_duration
                                           delay:0.0
                                         options:0
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0.0
                                                                  relativeDuration:0.5
                                                                        animations:^{
                                                                            // rotate the from- view to 90 degrees
    
                                                                            CGFloat angle = M_PI_2;
    
                                                                            flippedSectionOfFromView.layer.transform = [self rotate:self.reverse ? -1*angle : angle];
                                                                            
                                                                            flippedSectionOfFromViewShadow.alpha = 1.0;
    
                                                                        }];
                                          [UIView addKeyframeWithRelativeStartTime:0.5
                                                                  relativeDuration:0.5
                                                                        animations:^{
                                                                            // rotate the to- view to 0 degrees
                                                                        
                                                                            
                                                                            flippedSectionOfToView.layer.transform = [self rotate:self.reverse ? 0.001 : -0.001];
                                                                            flippedSectionOfToViewShadow.alpha = 0.0;
                                                                        }];
                                      } completion:^(BOOL finished) {
    
                                          for (UIView *subView in [self subviews]) {
                                              if (![subView isEqual:toView]) {
                                                  [subView removeFromSuperview];
                                              }
                                          }
                                          [self.layer removeAllAnimations];
                                          _filpIndex++;
                                      }];
    
}
// adds a gradient to an image by creating a containing UIView with both the given view
// and the gradient as subviews
- (UIView*)addShadowToView:(UIView*)view reverse:(BOOL)reverse {
    
    UIView* containerView = view.superview;
    
    // create a view with the same frame
    UIView* viewWithShadow = [[UIView alloc] initWithFrame:view.frame];
    
    // replace the view that we are adding a shadow to
    [containerView insertSubview:viewWithShadow aboveSubview:view];
    [view removeFromSuperview];
    
    // create a shadow
    UIView* shadowView = [[UIView alloc] initWithFrame:viewWithShadow.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    
    gradient.colors = @[(id)[UIColor orangeColor].CGColor,
                        (id)[UIColor purpleColor].CGColor];
    //    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
    //                        (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
    

    if (self.flipDirection == BasicFlipFromRight ||self.flipDirection == BasicFlipFromLeft) {
        gradient.startPoint = CGPointMake(reverse ? 0.0 : 1.0, 0.0);
        gradient.endPoint = CGPointMake(reverse ? 1.0 : 0.0, 0.0);
    }else{
        
        gradient.startPoint =CGPointMake(0.0,reverse ? 0.0 : 1.0);
        gradient.endPoint = CGPointMake(0.0,reverse ? 1.0 : 0.0);
    }
    
    [shadowView.layer insertSublayer:gradient atIndex:1];
    
    // add the original view into our new view
    view.frame = view.bounds;
    [viewWithShadow addSubview:view];
    
    // place the shadow on top
    [viewWithShadow addSubview:shadowView];
    
    return viewWithShadow;
}

// creates a pair of snapshots from the given view
- (NSArray*)createSnapshots:(UIView*)view afterScreenUpdates:(BOOL) afterUpdates{
    UIView* containerView = view.superview;
    
    if (self.flipDirection == BasicFlipFromLeft ||self.flipDirection == BasicFlipFromRight) {
        // snapshot the left-hand side of the view
        CGRect snapshotRegion = CGRectMake(0,0, view.frame.size.width / 2, view.frame.size.height);
        UIView *leftHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        leftHandView.frame = snapshotRegion;
        
        [containerView addSubview:leftHandView];
        
        // snapshot the right-hand side of the view
        snapshotRegion = CGRectMake(view.frame.size.width / 2 ,0, view.frame.size.width / 2, view.frame.size.height);
        UIView *rightHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        
        rightHandView.frame = snapshotRegion;
        [containerView addSubview:rightHandView];
        
        // send the view that was snapshotted to the back
        [containerView sendSubviewToBack:view];
        
        return @[leftHandView, rightHandView];
    }else{
        
        CGRect snapshotRegion = CGRectMake(0, 0, view.frame.size.width , view.frame.size.height/ 2);
        UIView *topHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        topHandView.frame = snapshotRegion;
        [containerView addSubview:topHandView];
        

        
        
        // snapshot the right-hand side of the view
        snapshotRegion = CGRectMake( 0,view.frame.size.height / 2, view.frame.size.width, view.frame.size.height / 2);
        UIView *bottomHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
        bottomHandView.frame = snapshotRegion;
        [containerView addSubview:bottomHandView];

        
        // send the view that was snapshotted to the back
        [containerView sendSubviewToBack:view];
        
        return @[topHandView, bottomHandView];
    }
    
}

// updates the anchor point for the given view, offseting the frame to compensate for the resulting movement
- (void)updateAnchorPointAndOffset:(CGPoint)anchorPoint view:(UIView*)view {
    view.layer.anchorPoint = anchorPoint;
    
    if (self.flipDirection == BasicFlipFromRight ||self.flipDirection == BasicFlipFromLeft) {
        float xOffset =  anchorPoint.x - 0.5;
        
        view.frame = CGRectOffset(view.frame, xOffset * view.frame.size.width, 0);
    }else{
        
        float yOffset =  anchorPoint.y - 0.5;
        view.frame = CGRectOffset(view.frame, 0, yOffset * view.frame.size.height);
    }
    

}


- (CATransform3D) rotate:(CGFloat) angle {
    
    
    if (self.flipDirection == BasicFlipFromRight ||self.flipDirection == BasicFlipFromLeft) {
        
        return  CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
    }else{
        
        return  CATransform3DMakeRotation(angle, -1.0, 0.0, 0.0);
    }
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
