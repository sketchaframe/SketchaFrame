//
//  RedundancyView.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/2/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "Fem.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorCode.h"

@interface RedundancyView : UIView
{
    CGPoint lastTap;
    CGPoint firstTap;
    CFemModelPtr femModel;
    CFemModelPtr shareFemModel;
    CViewPortPtr worldViewport;
    CViewPortPtr share_worldViewport;
    bool swipeLine;
    int snapDistance;
    bool geometryUpdated;
    bool calculated;
    bool panning;
    
    int playID;
    int playType;
    int nodeIDglob;
    
    NSString *message;
    CGRect textRect;
    UILabel *momScaleLabel;
    UILabel *defScaleLabel;
    UILabel *mechanismLabel;
    
    double prevDefScaleValue;
    double prevMomScaleValue;
    
    CALayer	*rootLayer;
	CAShapeLayer *shapeLayer;
    
	CGMutablePathRef mekanismEndShape;
	CGMutablePathRef mekanismStartShape;
}

+ (GeometryView *) sharedInstance;
- (CFemModelPtr) getFemModel;
- (CViewPortPtr) getworldViewport;

@property (nonatomic, assign) id delegate;
@property int toolMode;
@property bool firstDraw;
@property bool firstRelease;
@property bool firstSwipe;
@property bool needsRescale;
@property bool notFirstTimeViewShow;

-(void)startAnimation;

@end

