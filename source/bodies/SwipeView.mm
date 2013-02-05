//
//  SwipeView.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/23/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "SwipeView.h"
#import "GeometryView.h"
#import "AlgebraFunctions.h"
//#import "Fem.cpp"

@implementation SwipeView
{
    CViewPort *worldViewport;
    CFemModel *femModel;
    bool moveNode;
}

@synthesize firstTap;
@synthesize lastTap;
@synthesize showSwipeLine;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    //Get pointers
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

-(void)getPointers
{
    GeometryView *myGeo = [GeometryView sharedInstance];
    femModel = [myGeo getFemModel];
    worldViewport = [myGeo getworldViewport];
}

- (void)drawRect:(CGRect)rect
{
    
    if (!femModel)
        [self getPointers];

    
    //Remove all subviews first (old pics)
    for (UIView *view in self.subviews) {
        if (view.tag == 1)
            [view removeFromSuperview];
    }
    
    if (showSwipeLine)
    {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 4.0);
        CGContextSetAlpha(context, 1.0);
        
        CGPoint firstPoint = [self getSnapPoint:firstTap];
        CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
        
        CGPoint lastPoint = [self getSnapPoint:lastTap];
        CGContextAddLineToPoint( context, lastPoint.x,lastPoint.y);

        int imageSize = 84;

        CGRect myImageRect = CGRectMake(lastPoint.x-imageSize/2,lastPoint.y-imageSize/2,imageSize,imageSize);
        UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
        [myImage setImage:[UIImage imageNamed:@"bc0.png"]];
        myImage.tag = 1;
        [self addSubview:myImage];
        [myImage release];
        
        
        CGRect myImageRect2 = CGRectMake(firstPoint.x-imageSize/2,firstPoint.y-imageSize/2,imageSize,imageSize);
        UIImageView *myImage2 = [[UIImageView alloc] initWithFrame:myImageRect2];
        [myImage2 setImage:[UIImage imageNamed:@"bc0.png"]];
        myImage2.tag = 1;
        [self addSubview:myImage2];
        [myImage2 release];
        
        CGContextStrokePath(context);
    }
    
}

-(CGPoint)getSnapPoint:(CGPoint) inPoint: (bool)moveNodeIn
{
    moveNode=moveNodeIn;
    return [self getSnapPoint:inPoint];
}

-(CGPoint)getSnapPoint:(CGPoint)inPoint
{
    if (!femModel)
        [self getPointers];
    
    
    double snapDistance = 45;
    CGPoint outPoint = inPoint;
    
    int nodeID = femModel->findNode(inPoint.x, inPoint.y, snapDistance);

    if (nodeID < 9999 && !moveNode) //Snap to node
    {
        CNodePtr node = femModel->getNode(nodeID);
        outPoint.x=node->getX();
        outPoint.y=node->getY();
    } else {
        
        double lineX, lineY;
        int lineID = femModel->findLineExtended(inPoint.x, inPoint.y, snapDistance, lineX, lineY);
        
        if (lineID < 9999 && !moveNode) //Snap to line and draw node
        {
            double gridX=0, gridY=0;
            
            CNodePtr startLN = femModel->getLine(lineID)->getNode0();
            CNodePtr endLN = femModel->getLine(lineID)->getNode1();
            
            outPoint.x=lineX;
            outPoint.y=lineY;
            
            gridX=0;
            gridY=0;
            
            if (femModel->showGrid() && femModel->foundGrid(lineX,lineY,0.2,gridX, gridY)) //Snap to line and cross in grid
            {                
                
                if (gridX>0 && gridY>0)
                {
                    
                    double projectX=0, projectY=0;
                    double distancePointLine = algebraFunctions::distansFromPointToLine
                    (gridX, gridY, startLN->getX(), startLN->getY(), endLN->getX(), endLN->getY(), projectX, projectY);
                    
                    if (distancePointLine<2)
                    {
                        outPoint.x = projectX;
                        outPoint.y = projectY;
                    }
                    
                }
            }

            
        }  else if (femModel->showGrid()) {
            
            double gridX=0,gridY=0;
            if (femModel->foundGrid(inPoint.x,inPoint.y,0.2,gridX, gridY)) //Snap to grid
            {
                
                if (gridX > 0)
                    outPoint.x=gridX;
                if (gridY > 0)
                    outPoint.y=gridY;
                
            }
            
        }
    }
    
    moveNode=false;
    return outPoint;
}



@end
