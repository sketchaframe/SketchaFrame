//
//  GeometryView.m
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "GeometryViewController.h"
#import "GeometryView.h"
#import "RedundancyView.h"

@interface RedundancyView ()
@property (retain) GeometryView *myGeo;
@end

@implementation RedundancyView

static GeometryView *_sharedInstance;
@synthesize toolMode;
@synthesize myGeo;
@synthesize firstDraw;
@synthesize firstRelease;
@synthesize needsRescale;
@synthesize notFirstTimeViewShow;


+ (GeometryView *) sharedInstance
{
	if (!_sharedInstance)
	{
		_sharedInstance = [[GeometryView alloc] init];
	}
    
	return _sharedInstance;
}

- (CFemModelPtr) getFemModel;
{
    if (!shareFemModel)
        shareFemModel = new CFemModel();
	return shareFemModel;
}


- (CViewPortPtr) getworldViewport;
{
    if (!share_worldViewport)
        share_worldViewport = new CViewPort();
	return share_worldViewport;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
    {
        myGeo = [GeometryView sharedInstance];
        
        snapDistance = 45;
        geometryUpdated = YES;
        
        femModel = [myGeo getFemModel];
        worldViewport = [myGeo getworldViewport];
        
        if (![myGeo notFirstTimeViewShow])
        {
            [myGeo setFirstDraw:YES];
            [myGeo setFirstRelease:YES];
            [myGeo setFirstSwipe:YES];
            [myGeo setNeedsRescale:YES];
            
            worldViewport->setTopLeft(0.0, self.frame.size.height);
            worldViewport->setScreenSize(self.frame.size.width, self.frame.size.height);
            worldViewport->setSize(self.frame.size.width, self.frame.size.height);
            
            [myGeo setNotFirstTimeViewShow:YES];
        }
        
        textRect = CGRectMake(230, 820, 500, 20);
        
        
        CGRect momentScale = CGRectMake(0, 790, 768, 20);
        CGRect deformationScale = CGRectMake(0, 790, 768, 20);
        CGRect mechanismDegree = CGRectMake(214, 25, 340, 50);
        
        defScaleLabel = [[UILabel alloc] initWithFrame: deformationScale];
        momScaleLabel = [[UILabel alloc] initWithFrame: momentScale];
        mechanismLabel = [[UILabel alloc] initWithFrame: mechanismDegree];
        [self addSubview: defScaleLabel];
        [self addSubview: momScaleLabel];
        [self addSubview: mechanismLabel];
        
        [momScaleLabel setBackgroundColor:[UIColor clearColor]];
        [defScaleLabel setBackgroundColor:[UIColor clearColor]];
        [momScaleLabel setTextAlignment:UITextAlignmentCenter];
        [defScaleLabel setTextAlignment:UITextAlignmentCenter];
        [mechanismLabel setBackgroundColor:[UIColor clearColor]];
        [mechanismLabel setTextAlignment:UITextAlignmentCenter];
        
        mechanismLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"warningBG.png"]];
        mechanismLabel.alpha = 0.6;
        mechanismLabel.hidden = YES;
        
        prevDefScaleValue=0;
        prevMomScaleValue=0;
        
    }
    return self;
}


- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        
        geometryUpdated = YES;
        firstTap = [sender locationInView:self];
        swipeLine = NO;
        panning = YES;
        
        playType=0;
        double x, y;
        double lineX,lineY;
        worldViewport->toWorld(firstTap.x, firstTap.y, x, y);
        playID = femModel->findAction(x, y, snapDistance, playType);
        
        if (playID != 9999 && playType==1)
        {
            double nodeCordX, nodeCordY;
            worldViewport->toScreen(femModel->getNode(playID)->getX(), femModel->getNode(playID)->getY(), nodeCordX, nodeCordY);
            firstTap.x = nodeCordX;
            firstTap.y = nodeCordY;
        }
        
        nodeIDglob = femModel->findNode(x, y, snapDistance);
        
        
        if (playID == 9999 && [myGeo toolMode] == 22)
        {
            //no node is found, check if line is found
            int lineID = femModel->findLineExtended(x, y, snapDistance, lineX, lineY);
            if (lineID<9999)
            {
                int startOldLine = femModel->getLine(lineID)->getNode0()->getEnumerate();
                int endOldLine = femModel->getLine(lineID)->getNode1()->getEnumerate();
                femModel->removeLine(x, y);
                femModel->addNode(lineX, lineY);
                int nodeID = femModel->findNode(x, y, snapDistance);
                femModel->addLine(startOldLine, nodeID);
                femModel->addLine(nodeID, endOldLine);
                
            }
            else if (femModel->showGrid())
            {
                double gridX=0,gridY=0;
                if (femModel->foundGrid(firstTap.x,firstTap.y,0.2,gridX, gridY))
                {
                    
                    if (gridX > 0)
                        firstTap.x=gridX;
                    if (gridY > 0)
                        firstTap.y=gridY;
                    
                    worldViewport->toWorld(firstTap.x, firstTap.y, x, y);
                    femModel->addNode(x, y);
                } else {
                    femModel->addNode(x, y);
                }
                
            } else {
                femModel->addNode(x, y);
            }
            
            //If no node or line is found, add node
            playID = femModel->findAction(x, y, snapDistance, playType);
        }
        
        //Enable adding a force in the middle of a line
        
        if (playID == 9999 && [myGeo toolMode] == 11)
        {
            int lineID = femModel->findLineExtended(x, y, snapDistance, lineX, lineY);
            if (lineID<9999)
            {
                int startOldLine = femModel->getLine(lineID)->getNode0()->getEnumerate();
                int endOldLine = femModel->getLine(lineID)->getNode1()->getEnumerate();
                femModel->removeLine(x, y);
                femModel->addNode(lineX, lineY);
                int nodeID = femModel->findNode(x, y, snapDistance);
                femModel->addLine(startOldLine, nodeID);
                femModel->addLine(nodeID, endOldLine);
                femModel->addBC(nodeID, 4);
                playID = femModel->findAction(x, y, snapDistance, playType);
            } else {
                
            }
            
        }
        playID = femModel->findAction(x, y, snapDistance, playType);
        
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        lastTap = [sender locationInView:self];
        
        //To make sure cannot draw out of screen
        if (lastTap.y<10)
        {
            lastTap.y=10;
        }
        
        if (lastTap.y>819)
        {
            lastTap.y=819;
        }
        
        if (femModel->orthoMode())
        {
            if (fabs(lastTap.x-firstTap.x) > fabs(lastTap.y-firstTap.y))
                lastTap.y = firstTap.y;
            else
                lastTap.x = firstTap.x;
        }
        
        double x, y;
        worldViewport->toWorld(lastTap.x, lastTap.y, x, y);
        
        if ([myGeo toolMode] == 22) {
            swipeLine = YES;
        }
        
        if ([myGeo toolMode] == 100)
        {
            NSLog(@"Erase pan");
            
            //Remove force
            int nodeType;
            int nodeID;
            nodeID = femModel->findAction(x, y, snapDistance, nodeType);
            if (nodeType == 2 && nodeID<9999)
                femModel->getNode(nodeID)->removeForce(femModel->getNode(nodeID)->getForce(0));
            
            femModel->removeNode(x, y);
            femModel->removeLine(x, y);
            playID=9999;
        }
        
        if (playID < 9999) {
            
            
            
            double sx, sy;
            CNodePtr node = femModel->getNode(playID);
            worldViewport->toScreen(node, sx, sy);
            
            switch ([myGeo toolMode]) {
                case 11:
                    //Move forces
                    
                    if (femModel->showGrid())
                    {
                        double gridX=0,gridY=0;
                        if (femModel->foundGrid(lastTap.x,lastTap.y,0.2,gridX, gridY))
                        {
                            
                            if (gridX > 0)
                                lastTap.x=gridX;
                            if (gridY > 0)
                                lastTap.y=gridY;
                            
                        }
                    }
                    
                    if (playType == 2) //Forces
                    {
                        geometryUpdated = NO;
                        femModel->setForce(lastTap.x-sx, sy-lastTap.y, playID, 0);
                    }
                    
                    if (playType == 1)
                    {
                        if (femModel->getNode(playID)->getForceCount() == 0)
                        {
                            femModel->addForce(playID, 10, 0,1);
                            playType=2;
                        }
                    }
                    
                    break;
                    
                case 23:
                    //Move nodes or forces
                    
                    if (femModel->showGrid())
                    {
                        double gridX=0,gridY=0;
                        if (femModel->foundGrid(lastTap.x,lastTap.y,0.2,gridX, gridY))
                        {
                            
                            if (gridX > 0)
                                lastTap.x=gridX;
                            if (gridY > 0)
                                lastTap.y=gridY;
                            
                        }
                    }
                    
                    double px,py;
                    worldViewport->toScreen(lastTap.x, lastTap.y,px,py);
                    
                    
                    if (playType == 2 && nodeIDglob==9999) //Forces
                    {
                        geometryUpdated = NO;
                        femModel->setForce(lastTap.x-sx, sy-lastTap.y, playID, 0);
                    }
                    if (nodeIDglob < 9999) //Nodes
                        femModel->setCord(px, py, nodeIDglob);
                    break;
                    
            }
        }
        
        [self setNeedsDisplay];
        
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        geometryUpdated=YES;
        panning = NO;
        switch ([myGeo toolMode]) {
            case 22:
                double x1, y1, x2, y2;
                int start, end;
                
                worldViewport->toWorld(firstTap.x, firstTap.y, x1, y1);
                worldViewport->toWorld(lastTap.x, lastTap.y, x2, y2);
                start = femModel->findNode(x1, y1, snapDistance);
                end = femModel->findNode(x2, y2, snapDistance);
                
                if (end == 9999)
                {
                    double lineX, lineY;
                    int lineID = femModel->findLineExtended(x2, y2, snapDistance, lineX, lineY);
                    if (lineID<9999)
                    {
                        //Snapped to line, remove old line and draw two new + one connecting
                        int startOldLine = femModel->getLine(lineID)->getNode0()->getEnumerate();
                        int endOldLine = femModel->getLine(lineID)->getNode1()->getEnumerate();
                        
                        femModel->removeOneLine(x2, y2);
                        
                        femModel->addNode(lineX, lineY);
                        int nodeID = femModel->findNode(x2, y2, snapDistance);
                        
                        femModel->addLine(startOldLine, nodeID);
                        femModel->addLine(nodeID, endOldLine);
                        
                        end = femModel->findNode(x2, y2, snapDistance);
                        femModel->addLine(start, end);
                        
                        
                    } else {
                        if (end != start)
                        {
                            femModel->addNode(x2, y2);
                            end = femModel->findNode(x2, y2, snapDistance);
                        }
                    }
                }
                
                if (start+end < 9999)
                {
                    if (!femModel->lineExists(start, end) && start!=end)
                    {
                        femModel->addLine(start, end);
                        femModel->enumerateLines(1);
                    } else {
                        //[self warningMessage:@"Line already exists!"];
                    }
                }
                
                
        }
        
        swipeLine = NO;
        
        //calculated = femModel->calculate(YES, YES);
        
        if (calculated)
            [myGeo setFirstRelease:NO];
        
        if (firstDraw)
            geometryUpdated = YES;
        
        
        
        [self setNeedsDisplay];
        
    } else if (sender.state == UIGestureRecognizerStateCancelled ||	sender.state == UIGestureRecognizerStateFailed) {
        
    }
}


- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        lastTap = [sender locationInView:self];
        double x, y;
        
        worldViewport->toWorld(lastTap.x, lastTap.y, x, y);
        int nodeID = femModel->findNode(x, y, snapDistance);
        
        
        //Add node if none found and snapp to lines
        if (nodeID==9999 && [myGeo toolMode]<10)
        {
            double lineX,lineY;
            int lineID = femModel->findLineExtended(x, y, snapDistance, lineX, lineY);
            if (lineID<9999)
            {
                //Snapped to line, remove old line and draw two new + one connecting
                int startOldLine = femModel->getLine(lineID)->getNode0()->getEnumerate();
                int endOldLine = femModel->getLine(lineID)->getNode1()->getEnumerate();
                femModel->removeOneLine(x, y);
                femModel->addNode(lineX, lineY);
                nodeID = femModel->findNode(x, y, snapDistance);
                femModel->addLine(startOldLine, nodeID);
                femModel->addLine(nodeID, endOldLine);
            } else {
                femModel->addNode(x, y);
                nodeID = femModel->findNode(x, y, snapDistance);
            }
            
        }
        
        switch ([myGeo toolMode]) {
            case 1:
                femModel->getNode(nodeID)->clearBCs();
                femModel->addBC(nodeID, 0);
                //[self reScaleWait];
                break;
            case 2:
                femModel->getNode(nodeID)->clearBCs();
                femModel->addBC(nodeID, 1);
                //[self reScaleWait];
                break;
            case 3:
                femModel->getNode(nodeID)->clearBCs();
                femModel->addBC(nodeID, 2);
                //[self reScaleWait];
                break;
            case 4:
                femModel->getNode(nodeID)->clearBCs();
                femModel->addBC(nodeID, 3);
                //[self reScaleWait];
                break;
            case 5:
                femModel->getNode(nodeID)->clearBCs();
                femModel->addBC(nodeID, 4);
                //[self reScaleWait];
                break;
            case 6:
                femModel->getNode(nodeID)->clearBCs();
                //[self reScaleWait];
                break;
                
            case 11:
                if (nodeID<9999 && (femModel->getNode(nodeID)->getForceCount() == 0))
                    femModel->addForce(nodeID, 100, 0,1);
                break;
                
            case 22:
                NSLog(@"Draw");
                femModel->addNode(x, y);
                femModel->enumerateDofs(1);
                femModel->print();
                [self setNeedsDisplay];
                break;
                
            case 23:
                
                break;
                
            case 100:
                NSLog(@"Erase");
                
                //Remove force
                int nodeType;
                int nodeID;
                nodeID = femModel->findAction(x, y, snapDistance, nodeType);
                if (nodeType == 2 && nodeID<9999)
                    femModel->getNode(nodeID)->removeForce(femModel->getNode(nodeID)->getForce(0));
                
                femModel->removeNode(x, y);
                femModel->removeLine(x, y);
                
                break;
                
            default:
                break;
        }
        
        [self setNeedsDisplay];
        
    }
}


- (void) removeMessage:(NSTimer*)timer
{
    message=@"";
    [self setNeedsDisplayInRect:textRect];
}

- (void) infoMessage
{
    //Update mechanism label
    mechanismLabel.hidden = NO;
    
    if (femModel->checkUnconnectedNodes())
    {
        mechanismLabel.text = @"Unnconnected nodes exists";
    } else if (femModel->getRedundancyBrain(femModel)->getm() > 0 && femModel->getRedundancyBrain(femModel)->getm() < 100)
    {
        mechanismLabel.text = [[@"Mechanism of the " stringByAppendingString:[NSString stringWithFormat:@"%d",femModel->getRedundancyBrain(femModel)->getm()]] stringByAppendingString:@" degree"];
    } else if (femModel->getRedundancyBrain(femModel)->gets() == 0 && femModel->lineCount()>0 && femModel->getRedundancyBrain(femModel)->getm()==0) {
        mechanismLabel.text = @"Statically determined";
    } else {
        mechanismLabel.hidden=YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    
    
    NSDate *timingDate;
    timingDate = [NSDate date];
    
    
    //Remove all subviews first (old pics)
    for (UIView *view in self.subviews) {
        if (view.tag == 1)
            [view removeFromSuperview];
    }
    
    //Adjustable variables:
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw grid
    if (femModel->showGrid())
    {
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetAlpha(context, 0.2);
        CGContextSetLineWidth(context, 2);
        
        double drawCord=0;
        double space=65;
        
        while(drawCord<self.frame.size.width)
        {
            drawCord+=space;
            CGContextMoveToPoint(context, drawCord, 0);
            CGContextAddLineToPoint(context, drawCord, self.frame.size.height+20);
        }
        
        drawCord=0;
        while(drawCord<self.frame.size.height)
        {
            drawCord+=space;
            CGContextMoveToPoint(context, 0, drawCord);
            CGContextAddLineToPoint(context, self.frame.size.width+20, drawCord);
        }
    }
    CGContextStrokePath(context);
    
    
    //Recalculate everything
    NSDate *timingCalculations;
    timingCalculations = [NSDate date];
    
    
    if (femModel->drawRedundancy() && !panning && femModel->lineCount()>0)
    {
        femModel->calculateRedundancy();
    }
    
    [self infoMessage];
    
    int i;
    double sx, sy, sx2, sy2;
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 1);
    CGContextSetLineWidth(context, 2);
    
    
    
    
    
    
    for (i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        double startX = line->getNode0()->getX();
        double startY = line->getNode0()->getY();
        double endX = line->getNode1()->getX();
        double endY = line->getNode1()->getY();
        
        worldViewport->toScreen(startX, startY, startX, startY);
        worldViewport->toScreen(endX, endY, endX, endY);
        
        
        //Draw the geometry (one line)
        
        if (femModel->getRedundancyBrain(femModel)->getm()>0)
        {
            CGContextSetLineWidth(context, 4);
            CGContextSetAlpha(context, 1);
            CGContextMoveToPoint(context, startX, startY);
            CGContextAddLineToPoint( context, endX,endY);
            CGContextStrokePath(context);
        }
        
        
        //Set the color according to redundancy
        //cout << "MEK: " << femModel->getRedundancyBrain(femModel)->getm() << endl;
        if (femModel->getRedundancyBrain(femModel)->getm()==0)
        {
            CGContextSetLineWidth(context, 4);
            CGContextSetAlpha(context, 1);
            //cout << "s: " << femModel->getRedundancyBrain(femModel)->gets() << endl;
            if (femModel->getRedundancyBrain(femModel)->gets() > 0) {
                rgbColor *elementColor = line->getResults()->getRedundancyColor();
                
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:elementColor->getRed() green:elementColor->getGreen() blue:elementColor->getBlue() alpha:1].CGColor);
            } else if (femModel->getRedundancyBrain(femModel)->gets() == 0)
            {
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:1 alpha:1].CGColor);
            }
            CGContextMoveToPoint(context, startX, startY);
            CGContextAddLineToPoint( context, endX,endY);
            CGContextStrokePath(context);
            
        }
        
        
        
        //Set the colors on the beams according to their tension using graidents
        
        
        
    }
    
    
    CGContextSetLineWidth(context, 4);
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 0.7);
    
    
    //Draw unfinished line
    if (swipeLine)
    {
        
        worldViewport->toWorld(firstTap.x,firstTap.y,sx,sy);
        int startNodeId = femModel->findNode(sx, sy, snapDistance);
        if (startNodeId<9999) {
            
            CNodePtr startNode = femModel->getNode(startNodeId);
            worldViewport->toScreen(startNode, sx, sy);
            worldViewport->toScreen(lastTap.x,lastTap.y, sx2, sy2);
            int endNodeId = femModel->findNode(sx2, sy2, snapDistance);
            
            //Snap to end point
            CGContextMoveToPoint(context, sx, sy);
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
    }
    
    
    CGContextStrokePath(context);
    
    for (i=0; i<femModel->nodeCount(); i++)
    {
        
        CNodePtr node = femModel->getNode(i);
        worldViewport->toScreen(node, sx, sy);
        
        //BC condition images
        if (femModel->getNode(i)->getBCCount() > 0)
        {
            int bc;
            bc = femModel->getNode(i)->getBC(0)->getType()+1;
            
            if (bc == 1)
                bc=2;
            if (bc == 5)
                bc=0;
            
            NSString *fileName = [[@"bc" stringByAppendingFormat:@"%d", bc] stringByAppendingString:@".png"];
            
            if (bc==3)
            {
                fileName = @"bc3.svg";
            }
            
            int imageSize = 84;
            CGRect myImageRect = CGRectMake(sx-imageSize/2,sy-imageSize/2,imageSize,imageSize);
            UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
            [myImage setImage:[UIImage imageNamed:fileName]];
            myImage.alpha = 1;
            myImage.tag = 1;
            [self addSubview:myImage];
            [myImage release];
            
        } else {
            int imageSize = 84;
            CGRect myImageRect = CGRectMake(sx-imageSize/2,sy-imageSize/2,imageSize,imageSize);
            UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
            [myImage setImage:[UIImage imageNamed:@"bc0.png"]];
            myImage.alpha = 1;
            myImage.tag = 1;
            [self addSubview:myImage];
            [myImage release];
            
        }
        
    }
}


@end
