//
//  GeometryView.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "Fem.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SwipeView.h"

@interface GeometryView : UIView 
{
    SwipeView *swipeView;
    
    CGPoint lastTap; 
    CGPoint firstTap;
    CGPoint firstSnap;
    
    CFemModelPtr femModel;
    CFemModelPtr shareFemModel;
    CViewPortPtr worldViewport;
    CViewPortPtr share_worldViewport;    

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
- (vector<CFemModelPtr>*) getUndoModelList;
- (vector<CFemModelPtr>*) getRedoModelList;

@property (nonatomic, assign) id delegate;
@property int toolMode;
@property bool firstDraw;
@property bool firstRelease;
@property bool firstSwipe;
@property bool needsRescale;
@property bool notFirstTimeViewShow;
@property vector<CFemModelPtr> *undoModelList;
@property vector<CFemModelPtr> *redoModelList;

-(void)startAnimation;

@end

