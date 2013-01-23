//
//  SwipeView.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/23/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "SwipeView.h"
#import "Fem.h"
#import "GeometryView.h"

@implementation SwipeView
@synthesize firstTap;
@synthesize lastTap;
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

-(void)swipeLine:(CGPoint *)start:(CGPoint *)end
{
    showSwipeLine = true;
    firstTap=*start;
    lastTap=*end;
    
    [self setNeedsDisplay];
}

-(void)hide
{
    showSwipeLine = false;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //Remove all subviews first (old pics)
    for (UIView *view in self.subviews) {
        if (view.tag == 1)
            [view removeFromSuperview];
    }
    
    if (showSwipeLine)
    {
        GeometryView *myGeo = [GeometryView sharedInstance];
        CFemModel *femModel = [myGeo getFemModel];
        CViewPort *worldViewport = [myGeo getworldViewport];

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 4.0);
        CGContextSetAlpha(context, 1.0);
        
        double sx, sy, sx2, sy2;
        double snapDistance = 45;
        
        worldViewport->toWorld(firstTap.x,firstTap.y,sx,sy);
        int startNodeId = femModel->findNode(sx, sy, snapDistance);
        if (startNodeId<9999)
        {
            
            CNodePtr startNode = femModel->getNode(startNodeId);
            worldViewport->toScreen(startNode, sx, sy);
            worldViewport->toScreen(lastTap.x,lastTap.y, sx2, sy2);
            int endNodeId = femModel->findNode(sx2, sy2, snapDistance);
            
            //Snap to end point
            CGContextMoveToPoint(context, sx, sy);
            
            int imageSize = 84;
            CGRect myImageRect = CGRectMake(sx-imageSize/2,sy-imageSize/2,imageSize,imageSize);
            UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
            [myImage setImage:[UIImage imageNamed:@"bc0.png"]];
            myImage.alpha = 1;
            myImage.tag = 1;
            [self addSubview:myImage];
            [myImage release];
            
            if (endNodeId < 9999 && endNodeId != startNodeId) {
                CNodePtr endNode = femModel->getNode(endNodeId);
                worldViewport->toScreen(endNode, sx2, sy2);
                CGContextAddLineToPoint( context, sx2,sy2);
            } else {
                double lineX, lineY;
                int lineID = femModel->findLineExtended(sx2, sy2, snapDistance, lineX, lineY);
                worldViewport->toScreen(lineX, lineY, lineX, lineY);
                
                if (lineID < 9999) //Snap to line and draw node
                {
                    CGContextAddLineToPoint( context, lineX,lineY);
                    
                    int imageSize = 84;
                    CGRect myImageRect = CGRectMake(lineX-imageSize/2,lineY-imageSize/2,imageSize,imageSize);
                    UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
                    [myImage setImage:[UIImage imageNamed:@"bc0.png"]];
                    myImage.alpha = 1;
                    myImage.tag = 1;
                    [self addSubview:myImage];
                    [myImage release];
                }
                
                else if (femModel->showGrid())
                {
                    double gridX=0,gridY=0;
                    if (femModel->foundGrid(lastTap.x,lastTap.y,0.2,gridX, gridY))
                    {
                        
                        if (gridX > 0)
                            lastTap.x=gridX;
                        if (gridY > 0)
                            lastTap.y=gridY;
                    }
                    
                    CGContextAddLineToPoint( context, lastTap.x,lastTap.y);
                }
                
                else
                    CGContextAddLineToPoint( context, lastTap.x,lastTap.y);
            }
            
        }
        
        CGContextStrokePath(context);
    }
    
}

+(CGPoint)getSnapPoint:(CGPoint)inPoint
{
    
}


@end
