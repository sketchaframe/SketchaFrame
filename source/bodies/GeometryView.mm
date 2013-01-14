//
//  GeometryView.m
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "GeometryViewController.h"
#import "GeometryView.h"

@interface GeometryView ()
@property (retain) GeometryView *myGeo;
@end

@implementation GeometryView

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
        [self reScale];
        
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
        
        [self reScale];
        swipeLine = NO;
        
        calculated = femModel->calculate(YES, YES);
        
        if (calculated)
            [myGeo setFirstRelease:NO];
        
        if (firstDraw)
            geometryUpdated = YES;
        
        
        
        [self setNeedsDisplay];
        
    } else if (sender.state == UIGestureRecognizerStateCancelled ||	sender.state == UIGestureRecognizerStateFailed) {
        
    }
}


-(void)reScale
{
    //Auto set displacements
    if (femModel->calculate(YES, YES))
    {
        femModel->calculate(NO, NO);
        femModel->setScale(60/femModel->getMaxDisp());
        femModel->calculate(NO, NO);
        
        femModel->setMomentScale(10000*30/femModel->getMaxMoment());
        
        
        
        NSNumberFormatter *ns = [[NSNumberFormatter alloc] init];
        [ns setNumberStyle: NSNumberFormatterScientificStyle];
        [ns setMaximumFractionDigits:2];
        
        NSNumberFormatter *small = [[NSNumberFormatter alloc] init];
        [small setNumberStyle: NSNumberFormatterDecimalStyle];
        //[small setMaximumFractionDigits:4];
        [small setUsesSignificantDigits:YES];
        [small setMaximumSignificantDigits:2];
        
        NSString *scale;
        if (fabs(femModel->getScale())>1000)
            scale = [ns stringFromNumber: [NSNumber numberWithDouble:femModel->getScale()]];
        else
            scale = [small stringFromNumber: [NSNumber numberWithDouble:femModel->getScale()]];
        
        NSString *momScale;
        if (femModel->getMomentScale()*100 >1000)
            momScale = [ns stringFromNumber: [NSNumber numberWithDouble:femModel->getMomentScale()*100]];
        
        else
            momScale = [small stringFromNumber: [NSNumber numberWithDouble:femModel->getMomentScale()*100]];
        
        [small release];
        [ns release];
        
        [defScaleLabel setText:@""];
        [momScaleLabel setText:@""];
        
        if (femModel->drawDeformation())
        {
            [defScaleLabel setText: [@"Deformation scale: " stringByAppendingString:scale]];
        }
        
        if (femModel->drawMoment())
        {
            [momScaleLabel setText: [@"Momentdiagram scale: " stringByAppendingString:momScale]];
        }
        
        
        
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
        
        if (femModel->calculate(YES, YES))
            [myGeo setFirstRelease:NO];
        
        [self setNeedsDisplay];
        
    }
}


- (void)reScaleWait
{
    if (calculated)
    {
        NSTimer *timer;
        timer = [NSTimer scheduledTimerWithTimeInterval: 4
                                                 target: self
                                               selector: @selector(reScaleExecute:)
                                               userInfo: nil
                                                repeats: NO];
    }
}

- (void) reScaleExecute:(NSTimer*)timer
{
    femModel->calculate(YES, YES);
    [self reScale];
    [self setNeedsDisplay];
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
    
    if (femModel->checkUnconnectedNodes() && !femModel->checkNoForceApplied())
    {
        mechanismLabel.text = @"Unnconnected nodes exists";
    } else if (femModel->checkFreeRotation() && !femModel->checkNoForceApplied())
    {
        mechanismLabel.text = @"Too few BC, free to rotate";
    } else if (femModel->checkFreeX() && !femModel->checkNoForceApplied()) {
        mechanismLabel.text = @"Too few BC, free to move horizonaly";
    } else if (femModel->checkFreeX() && !femModel->checkNoForceApplied()) {
        mechanismLabel.text = @"Too few BC, free to move verticaly";
    } else if (femModel->getDegreeOfMechanism() > 0 && femModel->getDegreeOfMechanism()<100 && !femModel->checkNoForceApplied())
    {
        mechanismLabel.text = [[@"Mechanism of the " stringByAppendingString:[NSString stringWithFormat:@"%d",femModel->getDegreeOfMechanism()]] stringByAppendingString:@" degree"];
        
    } else {
        mechanismLabel.hidden=YES;
    }
}

-(void)startAnimation
{
    if (femModel->getDegreeOfMechanism() > 0 && mekanismStartShape)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 2.0;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = (id)mekanismStartShape;
        animation.toValue = (id)mekanismEndShape;
        [shapeLayer addAnimation:animation forKey:@"animatePath"];
    }
}


- (void)drawRect:(CGRect)rect
{
    
    
    NSDate *timingDate;
    timingDate = [NSDate date];
    
    if ([myGeo needsRescale])
    {
        [self reScale];
        [myGeo setNeedsRescale:NO];
    }
    
    if ([myGeo firstDraw] && [myGeo firstRelease])
    {
        prevDefScaleValue=0;
        prevMomScaleValue=0;
        momScaleLabel.text=@"";
        defScaleLabel.text=@"";
    }
    
    //Adjustable variables:
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double greyness=0.5; //On lines without normalforce/tension
    
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
    
    if (calculated)
        calculated = femModel->calculate(geometryUpdated, geometryUpdated);
    else
        calculated = femModel->calculate( YES, YES);
    
    if (femModel->getMaxDisp()*femModel->getScale()>500)
    {
        [self reScale];
    }
    
    
    if (femModel->drawRedundancy() && !panning)
    {
        femModel->calculateRedundancy();
    }
    
    
    //If first draw update the scale
    if ([myGeo firstDraw] && calculated && ![myGeo firstRelease]) {
        femModel->calculate(YES, YES);
        [myGeo setFirstDraw:NO];
        [self reScale];
        
    }
    
    //Remove all subviews first (old pics)
    for (UIView *view in self.subviews) {
        if (view.tag == 1)
            [view removeFromSuperview];
    }
    
    
    int i;
    double sx, sy, sx2, sy2;
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 1);
    CGContextSetLineWidth(context, 2);
    
    [self infoMessage];
    
    
    
    //Draw scale for comparison
    if (femModel->drawDeformation() && calculated && ![myGeo firstRelease])
    {
        CGContextMoveToPoint(context, 384-femModel->getMaxDisp()*femModel->getScale()/2, 820);
        CGContextAddLineToPoint(context, 384+femModel->getMaxDisp()*femModel->getScale()/2, 820);
        CGContextMoveToPoint(context, 384-femModel->getMaxDisp()*femModel->getScale()/2, 815);
        CGContextAddLineToPoint(context, 384-femModel->getMaxDisp()*femModel->getScale()/2, 825);
        CGContextMoveToPoint(context, 384+femModel->getMaxDisp()*femModel->getScale()/2, 815);
        CGContextAddLineToPoint(context, 384+femModel->getMaxDisp()*femModel->getScale()/2, 825);
        CGContextStrokePath(context);
    } else {
        [defScaleLabel setText:@""];
    }
    
    if (femModel->drawMoment() && calculated && ![myGeo firstRelease])
    {
        CGContextMoveToPoint(context, 384-femModel->getMaxMoment()*femModel->getMomentScale()/2, 820);
        CGContextAddLineToPoint(context, 384+femModel->getMaxMoment()*femModel->getMomentScale()/2, 820);
        CGContextMoveToPoint(context, 384-femModel->getMaxMoment()*femModel->getMomentScale()/2, 815);
        CGContextAddLineToPoint(context, 384-femModel->getMaxMoment()*femModel->getMomentScale()/2, 825);
        CGContextMoveToPoint(context, 384+femModel->getMaxMoment()*femModel->getMomentScale()/2, 815);
        CGContextAddLineToPoint(context, 384+femModel->getMaxMoment()*femModel->getMomentScale()/2, 825);
        CGContextStrokePath(context);
    } else {
        [momScaleLabel setText:@""];
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 0.7);
    CGContextSetLineWidth(context, 4);
    
    
    //Figuring out the highest tension, moment and normalforce
    
    //Normal force
    double currentnForce = 0, largestNormalforce=0;
    for (i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        currentnForce = line->getResults()->getNormalForce();
        
        if (fabs(currentnForce) > largestNormalforce)
            largestNormalforce = fabs(currentnForce);
        
    }
    
    //Largest tension
    double currentTension=0, largestTension=0;
    for (i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        
        for (int j=0; j<2; j++)
        {
            currentTension = line->getResults()->getTension(j);
            if (fabs(currentTension) > largestTension)
                largestTension = fabs(currentTension);
        }
    }
    
    
    
    for (i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        double startX = line->getNode0()->getX();
        double startY = line->getNode0()->getY();
        double endX = line->getNode1()->getX();
        double endY = line->getNode1()->getY();
        
        double lineLength = sqrt(pow(endX-startX, 2)+pow(endY-startY, 2));
        
        double normalX = (endX-startX)/lineLength;
        double normalY = (endY-startY)/lineLength;
        
        worldViewport->toScreen(startX, startY, startX, startY);
        worldViewport->toScreen(endX, endY, endX, endY);
        
        //Draw moment diagram
        if (femModel->drawMoment() && calculated && femModel->getMaxMoment() > 0 && femModel->getMaxMoment()*femModel->getMomentScale()<500  && !femModel->tensionMode()  && femModel->getMaxMoment() > 1e-7 && ![myGeo firstDraw])
        {
            double startX2=startX+(normalY)*line->getResults()->getMoment(0)*femModel->getMomentScale();
            double startY2=startY+(normalX)*line->getResults()->getMoment(0)*femModel->getMomentScale();
            double endX2=startX+(normalY)*line->getResults()->getMoment(1)*femModel->getMomentScale()+(normalX)*lineLength;
            double endY2=startY+(normalX)*line->getResults()->getMoment(1)*femModel->getMomentScale()-(normalY)*lineLength;
            
            
            CGContextSetAlpha(context, 0.2);
            CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
            
            CGContextMoveToPoint(context,startX,startY);
            CGContextAddLineToPoint(context, startX2, startY2);
            CGContextAddLineToPoint(context, endX2, endY2);
            CGContextAddLineToPoint(context, endX, endY);
            CGContextAddLineToPoint(context, startX, startY);
            
            CGContextFillPath(context);
            
        }
        
        
        //Set the color according to normal force
        if (femModel->drawNormal() && calculated && !femModel->tensionMode())
        {
            //cout << "Largest: " << largestNormalforce << endl;
            double color;
            greyness = 0.4;
            currentnForce = line->getResults()->getNormalForce();
            
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:greyness green:greyness blue:greyness alpha:1].CGColor);
            
            if (currentnForce >= 0  && largestNormalforce>0.05) {
                color = currentnForce / largestNormalforce;
                if (color>1-greyness)
                    greyness = greyness-(color-(1-greyness));
                
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:color+greyness green:greyness blue:greyness alpha:1].CGColor);
            } else if (currentnForce < 0 && largestNormalforce>0.05) {
                color = currentnForce / -largestNormalforce;
                if (color>1-greyness)
                    greyness = greyness-(color-(1-greyness));
                
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:greyness green:greyness blue:color+greyness alpha:1].CGColor);
            }
        }
        
        
        //Draw the geometry (one line)
        if (!femModel->tensionMode() || (!calculated && femModel->tensionMode()))
        {
            if (!femModel->drawRedundancy() || (!calculated && femModel->drawRedundancy()))
            {
                CGContextSetLineWidth(context, 4);
                CGContextSetAlpha(context, 1);
                CGContextMoveToPoint(context, startX, startY);
                CGContextAddLineToPoint( context, endX,endY);
                CGContextStrokePath(context);
            }
        }
        
        
        
        //Set the colors on the beams according to their tension using graidents
        
        
        if (femModel->tensionMode() && calculated)
        {
            
            CGContextSetLineWidth(context, 4);
            CGContextSetAlpha(context, 1);
            
            double startTension = line->getResults()->getTension(0);
            double endTension = line->getResults()->getTension(1);
            
            double startColor = fabs(startTension/femModel->getMaxTension());
            double endColor = fabs(endTension/femModel->getMaxTension());
            
            int res=40;
            double color;
            
            for (int i=0; i<res; i++)
            {
                greyness = 0.4;
                color = startColor + i*(endColor - startColor)/res;
                
                if (color>1-greyness)
                    greyness = greyness-(color-(1-greyness));
                
                CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:greyness+color green:greyness blue:greyness alpha:1].CGColor);
                CGContextMoveToPoint(context, startX + i*(endX-startX)/res, startY + i*(endY - startY)/res);
                CGContextAddLineToPoint(context, startX + (i+1)*(endX-startX)/res+0.4*(endX-startX)/sqrt(pow(endY-startY,2) + pow(endX-startX,2)), startY + (i+1)*(endY - startY)/res+ 0.4*(endY-startY)/sqrt(pow(endY-startY,2) + pow(endX-startX,2)));
                
                CGContextStrokePath(context);
            }
            
        }
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 4);
    CGContextSetAlpha(context, 0.3);
    
    //Draw mekanism modal shape
    //Create path
    if (femModel->getDegreeOfMechanism() > 0 && !panning && !femModel->checkUnconnectedNodes() && !femModel->checkNoForceApplied() && !femModel->checkFreeRotation() && !femModel->checkFreeX() && !femModel->checkFreeY())
    {
        
        rootLayer.sublayers = nil;
        rootLayer	= [CALayer layer];
        
        rootLayer.frame = self.bounds;
        
        [self.layer addSublayer:rootLayer];
        
        mekanismStartShape = CGPathCreateMutable();
        
        if (femModel->getDegreeOfMechanism() > 0)
        {
            //CGContextSetLineWidth(context, 4);
            for (i=0; i<femModel->lineCount(); i++)
            {
                CLinePtr line = femModel->getLine(i);
                
                for (int j=0; j<20;j++)
                {
                    double dx = line->getResults()->getMekanismStart_x(j);
                    double dy = line->getResults()->getMekanismStart_y(j);
                    worldViewport->toScreen(dx, dy, dx, dy);
                    
                    if (j==0)
                        CGPathMoveToPoint(mekanismStartShape, nil, dx, dy);
                    if (j!=0)
                        CGPathAddLineToPoint( mekanismStartShape, nil, dx,dy);
                    
                }
            }
            CGPathCloseSubpath(mekanismStartShape);
        }
        
        
        //End shape
        mekanismEndShape = CGPathCreateMutable();
        
        if (femModel->getDegreeOfMechanism() > 0)
        {
            //CGContextSetLineWidth(context, 4);
            for (i=0; i<femModel->lineCount(); i++)
            {
                CLinePtr line = femModel->getLine(i);
                
                for (int j=0; j<20;j++)
                {
                    double dx = line->getResults()->getMekanismEnd_x(j);
                    double dy = line->getResults()->getMekanismEnd_y(j);
                    worldViewport->toScreen(dx, dy, dx, dy);
                    
                    if (j==0)
                        CGPathMoveToPoint(mekanismEndShape, nil, dx, dy);
                    if (j!=0)
                        CGPathAddLineToPoint( mekanismEndShape, nil, dx,dy);
                    
                }
            }
            CGPathCloseSubpath(mekanismEndShape);
        }
        
        //Create animation
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = mekanismStartShape;
        UIColor *strokeColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0.5 alpha:0.3];
        shapeLayer.strokeColor = strokeColor.CGColor;
        shapeLayer.lineWidth = 4.0;
        shapeLayer.fillRule = kCAFillRuleNonZero;
        [rootLayer addSublayer:shapeLayer];
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0];
    } else {
        rootLayer.sublayers = nil;
    }
    
    //Draw deformed shape
    if (femModel->drawDeformation() && calculated && ![myGeo firstRelease])
    {
        //CGContextSetLineWidth(context, 4);
        for (i=0; i<femModel->lineCount(); i++)
        {
            CLinePtr line = femModel->getLine(i);
            
            for (int j=0; j<20;j++)
            {
                double dx = line->getResults()->getDisplacements_x(j);
                double dy = line->getResults()->getDisplacements_y(j);
                
                worldViewport->toScreen(dx, dy, dx, dy);
                
                if (j==0)
                    CGContextMoveToPoint(context, dx, dy);
                if (j!=0)
                    CGContextAddLineToPoint( context, dx,dy);
                
            }
        }
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
            
            NSString *fileName = [[@"bc" stringByAppendingFormat:@"%d", femModel->getNode(i)->getBC(0)->getType()+1] stringByAppendingString:@".png"];
            
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
        
        //Draw force arrows
        if (!(femModel->getForceX(i,0) == 0 && femModel->getForceY(i,0) == 0 ) && !femModel->drawRedundancy())
        {
            double arrowNormalX=(femModel->getForceX(i,0)/sqrt(pow(femModel->getForceX(i,0),2)+pow(femModel->getForceY(i,0),2)));
            double arrowNormalY=(femModel->getForceY(i,0)/sqrt(pow(femModel->getForceX(i,0),2)+pow(femModel->getForceY(i,0),2)));
            
            
            CGContextSetAlpha(context, 1);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 4.0);
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextMoveToPoint(context, sx+arrowNormalX*14, sy-arrowNormalY*14);
            CGContextAddLineToPoint( context, sx+femModel->getForceX(i,0),sy - femModel->getForceY(i,0));
            CGContextStrokePath(context);
            
            //Building the arrow head (min 7px + 1/20 of the length)
            double extendX = arrowNormalX*18;//+(femModel->getForceX(i,0)/25);
            double extendY = arrowNormalY*18;//+(femModel->getForceY(i,0)/25);
            
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextMoveToPoint(context, sx+arrowNormalX*10, sy-arrowNormalY*10);
            CGContextAddLineToPoint( context, sx+arrowNormalX*10+extendX-extendY, sy-arrowNormalY*10-extendY-extendX);
            CGContextAddLineToPoint( context, sx+arrowNormalX*10+extendX+extendY, sy-arrowNormalY*10-extendY+extendX);
            CGContextAddLineToPoint(context, sx+arrowNormalX*10, sy-arrowNormalY*10);
            
            CGContextFillPath(context);
            
            //Elipse at the top of arrow
            CGRect rectangle = CGRectMake(sx+femModel->getForceX(i,0)-5, sy-femModel->getForceY(i,0)-5, 10, 10);
            CGContextAddEllipseInRect(context, rectangle);
            CGContextStrokePath(context);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextAddEllipseInRect(context, rectangle);
            CGContextFillPath(context);
            
            
            //Cleanup crew
            CGContextStrokePath(context);
            CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(context, 2.0);
            CGContextSetAlpha(context, 0.7);
            
        }
        
        
    }
}


@end
