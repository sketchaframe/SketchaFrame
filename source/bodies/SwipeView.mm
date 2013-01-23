//
//  SwipeView.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/23/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "SwipeView.h"
#import "Fem.h"

@implementation SwipeView
@synthesize start;
@synthesize end;
@synthesize showSwipeLine;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    [self setOpaque:NO];
    return self;
}

-(void)swipeLine:(CGPoint)start:(CGPoint)end
{
    showSwipeLine = true;
    [self setNeedsDisplay];
}

-(void)hide
{
    showSwipeLine = false;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
}


@end
