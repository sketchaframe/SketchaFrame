//
//  SwipeView.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/23/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipeView : UIView
{
    
}
@property (nonatomic, assign) CGPoint *start;
@property (nonatomic, assign) CGPoint *end;
@property (nonatomic, assign) bool showSwipeLine;

-(void)swipeLine:(CGPoint)start:(CGPoint)end;
-(void)hide;
@end
