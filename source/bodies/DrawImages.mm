//
//  DrawImages.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/31/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "DrawImages.h"
#import "GeometryView.h"

@implementation DrawImages

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(NSDictionary *)boundaries
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    
    double maxHeight=0;
    double maxWidth=0;
    double minHeight=2000;
    double minWidth=2000;
    
    for (int i=0; i<femModel->nodeCount(); i++)
    {
        //Get max
        if (femModel->getNode(i)->getX() > maxWidth)
            maxWidth = femModel->getNode(i)->getX();
        if (femModel->getNode(i)->getY() > maxHeight)
            maxHeight = femModel->getNode(i)->getY();
        
        //Get mins
        if (femModel->getNode(i)->getX() < minWidth)
            minWidth = femModel->getNode(i)->getX();
        if (femModel->getNode(i)->getY() < minHeight)
            minHeight = femModel->getNode(i)->getY();
        
        if (femModel->getNode(i)->getForceCount() > 0) {
            double xLocation = femModel->getNode(i)->getX() + femModel->getNode(i)->getForce(0)->getMagnitude()*femModel->getNode(i)->getForce(0)->getCompX();
            double yLocation = femModel->getNode(i)->getY() - femModel->getNode(i)->getForce(0)->getMagnitude()*femModel->getNode(i)->getForce(0)->getCompY();
            
            //Get max
            if (maxHeight<yLocation)
                maxHeight=yLocation;
            if (maxWidth<xLocation)
                maxWidth=xLocation;
            
            //Get mins
            if (minHeight>yLocation)
                minHeight=yLocation;
            if (minWidth>xLocation)
                minWidth=xLocation;
        }
        
    }
    
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        
        for (int j=0; j<20;j++)
        {
            double xLocation = line->getResults()->getDisplacements_x(j);
            double yLocation = line->getResults()->getDisplacements_y(j);
            
            if (xLocation>0 || yLocation>0)
            {
                //Get max
                if (maxHeight<yLocation)
                    maxHeight=yLocation;
                if (maxWidth<xLocation)
                    maxWidth=xLocation;
                
                //Get mins
                if (minHeight>yLocation)
                    minHeight=yLocation;
                if (minWidth>xLocation)
                    minWidth=xLocation;
            }
            
        }
    }
    
    minWidth-=20;
    minHeight-=25;
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"minWidth", @"minHeight", @"maxWidth", @"maxHeight", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithDouble:minWidth],[NSNumber numberWithDouble:minHeight],[NSNumber numberWithDouble:maxWidth], [NSNumber numberWithDouble:maxHeight], nil];
    NSDictionary *boundaries = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
    return boundaries;
}

+(CGPoint)localC:(CGPoint) globalC
{
    CGPoint localC;
    NSDictionary *boundaries = [self boundaries];
    
    localC.x = 0.6*(globalC.x - [[boundaries objectForKey:@"minWidth"] doubleValue]+42);
    localC.y = 0.6*(globalC.y - [[boundaries objectForKey:@"minHeight"] doubleValue]+42);
    return localC;
    
}

+(CGSize)imageBoundaries
{
    CGSize imageSize;
    NSDictionary *boundaries = [self boundaries];
    
    double minWidth = [[boundaries objectForKey:@"minWidth"] doubleValue];
    double minHeight = [[boundaries objectForKey:@"minHeight"] doubleValue];
    double maxWidth = [[boundaries objectForKey:@"maxWidth"] doubleValue];
    double maxHeight = [[boundaries objectForKey:@"maxHeight"] doubleValue];
    
    imageSize.width=0.6*(maxWidth-minWidth+84);
    imageSize.height=0.6*(maxHeight-minHeight+84+50);
    
    if (imageSize.width<240)
    {
        imageSize.width=240;
    }
    
    return imageSize;
}



+(UIImage*)drawBC
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];

    CGSize imageSize = [self imageBoundaries];
    UIGraphicsBeginImageContext(imageSize);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    for (int i=0; i<femModel->nodeCount(); i++)
    {
        CGContextSetLineWidth(ctx, 3.0);
        CNodePtr node = femModel->getNode(i);
        CGPoint nodePoint = [self localC:CGPointMake(node->getX(), node->getY())];

        UIImage *bc;
        if (femModel->getNode(i)->getBCCount() == 0)
        {
            bc = [UIImage imageNamed:@"small_bc0.png"];
        } else {
            NSString *fileName = [[@"small_bc" stringByAppendingFormat:@"%d", femModel->getNode(i)->getBC(0)->getType()+1] stringByAppendingString:@".png"];
            bc = [UIImage imageNamed:fileName];
            
        }
        

        
        CGPoint nodePointBC = CGPointMake(nodePoint.x - bc.size.width/2,nodePoint.y-bc.size.height/2);
        [bc drawAtPoint:nodePointBC];
  
    }
    
    
    
    
    
	// make image out of bitmap context and return
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return retImage;
}

+(UIImage*)drawForce
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    double imageScale = 0.6;
    double arrowScale = 0.6;
    
    CGSize imageSize = [self imageBoundaries];
    UIGraphicsBeginImageContext(imageSize);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    for (int i=0; i<femModel->nodeCount(); i++)
    {
        CGContextSetLineWidth(ctx, 3.0);
        CNodePtr node = femModel->getNode(i);
        CGPoint nodePoint = [self localC:CGPointMake(node->getX(), node->getY())];
                
        //Draw force arrows
        if (!(femModel->getForceX(i,0) == 0 && femModel->getForceY(i,0) == 0 ) && !femModel->drawRedundancy())
        {
            double arrowNormalX=(femModel->getForceX(i,0)/sqrt(pow(femModel->getForceX(i,0),2)+pow(femModel->getForceY(i,0),2)));
            double arrowNormalY=(femModel->getForceY(i,0)/sqrt(pow(femModel->getForceX(i,0),2)+pow(femModel->getForceY(i,0),2)));
            
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextMoveToPoint(ctx, nodePoint.x+arrowNormalX*14, nodePoint.y-arrowNormalY*14);
            CGContextAddLineToPoint( ctx, nodePoint.x+femModel->getForceX(i,0)*imageScale,nodePoint.y - femModel->getForceY(i,0)*imageScale);
            CGContextStrokePath(ctx);
            
            double sx = nodePoint.x;
            double sy = nodePoint.y;
            
            //Building the arrow head (min 7px + 1/20 of the length)
            double extendX = arrowNormalX*18*arrowScale;//+(femModel->getForceX(i,0)/25);
            double extendY = arrowNormalY*18*arrowScale;//+(femModel->getForceY(i,0)/25);
            
            CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextMoveToPoint(ctx, sx+arrowNormalX*10*arrowScale, sy-arrowNormalY*10*arrowScale);
            CGContextAddLineToPoint( ctx, sx+arrowNormalX*10*arrowScale+extendX-extendY, sy-arrowNormalY*10*arrowScale-extendY-extendX);
            CGContextAddLineToPoint( ctx, sx+arrowNormalX*10*arrowScale+extendX+extendY, sy-arrowNormalY*10*arrowScale-extendY+extendX);
            CGContextAddLineToPoint(ctx, sx+arrowNormalX*10*arrowScale, sy-arrowNormalY*10*arrowScale);
            
            CGContextFillPath(ctx);
            
            //Elipse at the top of arrow
            CGRect rectangle = CGRectMake(sx+femModel->getForceX(i,0)*imageScale-5*arrowScale, sy-femModel->getForceY(i,0)*imageScale-5*arrowScale, 10*arrowScale, 10*arrowScale);
            CGContextAddEllipseInRect(ctx, rectangle);
            CGContextStrokePath(ctx);
            CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
            CGContextAddEllipseInRect(ctx, rectangle);
            CGContextFillPath(ctx);
            
            
            //Cleanup crew
            CGContextStrokePath(ctx);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            
            
        }
        
        
    }    
	// make image out of bitmap context and return
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return retImage;
}

+(UIImage*)drawDeformations
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];

    UIGraphicsBeginImageContext([self imageBoundaries]);
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Set bg color = white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 2000, 2000));
    
    [[UIColor darkGrayColor] setFill];
    [@"Deformations:" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:18]];

    
    //Draw deformed shape
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        
        for (int j=0; j<20;j++)
        {
            double dx = line->getResults()->getDisplacements_x(j);
            double dy = line->getResults()->getDisplacements_y(j);
            
            CGPoint drawPoint = [self localC:CGPointMake(dx, dy)];
            if (j==0)
                CGContextMoveToPoint(ctx, drawPoint.x, drawPoint.y);
            if (j!=0)
                CGContextAddLineToPoint( ctx, drawPoint.x, drawPoint.y);
            
        }
    }

    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    CGContextStrokePath(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    //Draw the geometry (one line)

    //Draw the geometry (one line)
    
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        CGPoint start = [self localC:CGPointMake(line->getNode0()->getX(), line->getNode0()->getY())];
        CGPoint end = [self localC:CGPointMake(line->getNode1()->getX(), line->getNode1()->getY())];
        
        CGContextSetLineWidth(ctx, 3);
        CGContextSetAlpha(ctx, 1);
        CGContextMoveToPoint(ctx, start.x, start.y);
        CGContextAddLineToPoint( ctx, end.x, end.y);
        CGContextStrokePath(ctx);
        
    }

    //Add node picture with force arrow
    [[self drawBC] drawAtPoint:CGPointMake(0, 0)];
    [[self drawForce] drawAtPoint:CGPointMake(0, 0)];
        
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return retImage;
}



+(UIImage*)drawTensions
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    UIGraphicsBeginImageContext([self imageBoundaries]);
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Set bg color = white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 2000, 2000));
    
    [[UIColor darkGrayColor] setFill];
    [@"Tensions:" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:18]];
    

    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(ctx, 3);
    CGContextStrokePath(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    
    //Draw the geometry (one line)
    
    //Draw the geometry (one line)
    
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        CGPoint start = [self localC:CGPointMake(line->getNode0()->getX(), line->getNode0()->getY())];
        CGPoint end = [self localC:CGPointMake(line->getNode1()->getX(), line->getNode1()->getY())];
        
        CGContextSetLineWidth(ctx, 3);

        
        double startTension = line->getResults()->getTension(0);
        double endTension = line->getResults()->getTension(1);
        
        double startColor = fabs(startTension/femModel->getMaxTension());
        double endColor = fabs(endTension/femModel->getMaxTension());
        
        int res=40;
        double color;
        
        for (int i=0; i<res; i++)
        {
            double greyness = 0.4;
            color = startColor + i*(endColor - startColor)/res;
            
            if (color>1-greyness)
                greyness = greyness-(color-(1-greyness));
            
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:greyness+color green:greyness blue:greyness alpha:1].CGColor);
            CGContextMoveToPoint(ctx, start.x + i*(end.x-start.x)/res, start.y + i*(end.y - start.y)/res);
            CGContextAddLineToPoint(ctx, start.x + (i+1)*(end.x-start.x)/res+0.4*(end.x-start.x)/sqrt(pow(end.y-start.y,2) + pow(end.x-start.x,2)), start.y + (i+1)*(end.y - start.y)/res+ 0.4*(end.y-start.y)/sqrt(pow(end.y-start.y,2) + pow(end.x-start.x,2)));
            
            CGContextStrokePath(ctx);
        }

        
    }
    
    //Add node picture with force arrow
    [[self drawBC] drawAtPoint:CGPointMake(0, 0)];
    [[self drawForce] drawAtPoint:CGPointMake(0, 0)];
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return retImage;

    
}

+(UIImage*)drawNormMom
{
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    UIGraphicsBeginImageContext([self imageBoundaries]);
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Set bg color = white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 2000, 2000));
    
    [[UIColor darkGrayColor] setFill];
    [@"Normal force & moment:" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:18]];
    
    
    CGContextSetLineWidth(ctx, 3);
    CGContextStrokePath(ctx);
    //Draw the geometry (one line)
    
    //Normal force
    double currentnForce = 0, largestNormalforce=0;
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        currentnForce = line->getResults()->getNormalForce();
        
        if (fabs(currentnForce) > largestNormalforce)
            largestNormalforce = fabs(currentnForce);
        
    }
    
    
    
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        CGPoint start = [self localC:CGPointMake(line->getNode0()->getX(), line->getNode0()->getY())];
        CGPoint end = [self localC:CGPointMake(line->getNode1()->getX(), line->getNode1()->getY())];
        
        
        if (femModel->getMaxMoment() > 1e-7)
        {
            //Moment diagram
            double lineLength = sqrt(pow(end.x-start.x, 2)+pow(end.y-start.y, 2));
            
            double normalX = (end.x-start.x)/lineLength;
            double normalY = -(end.y-start.y)/lineLength;
            
            
            double startX2=start.x-(normalY)*line->getResults()->getMoment(0)*femModel->getMomentScale();
            double startY2=start.y-(normalX)*line->getResults()->getMoment(0)*femModel->getMomentScale();
            double endX2=start.x-(normalY)*line->getResults()->getMoment(1)*femModel->getMomentScale()+(normalX)*lineLength;
            double endY2=start.y-(normalX)*line->getResults()->getMoment(1)*femModel->getMomentScale()-(normalY)*lineLength;
            
            
            CGContextSetAlpha(ctx, 0.3);
            CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
            
            CGContextMoveToPoint(ctx,start.x,start.y);
            CGContextAddLineToPoint(ctx, startX2, startY2);
            CGContextAddLineToPoint(ctx, endX2, endY2);
            CGContextAddLineToPoint(ctx, end.x, end.y);
            CGContextAddLineToPoint(ctx, start.x, start.y);
            
            CGContextFillPath(ctx);
            
        }
        
        
        CGContextSetAlpha(ctx, 1);
        
        
        double color;
        double greyness = 0.4;
        currentnForce = line->getResults()->getNormalForce();
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:greyness green:greyness blue:greyness alpha:1].CGColor);
        
        if (currentnForce >= 0  && largestNormalforce>0.05) {
            color = currentnForce / largestNormalforce;
            if (color>1-greyness)
                greyness = greyness-(color-(1-greyness));
            
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:color+greyness green:greyness blue:greyness alpha:1].CGColor);
        } else if (currentnForce < 0 && largestNormalforce>0.05) {
            color = currentnForce / -largestNormalforce;
            if (color>1-greyness)
                greyness = greyness-(color-(1-greyness));
            
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:greyness green:greyness blue:color+greyness alpha:1].CGColor);
        }
        
        
        CGContextSetLineWidth(ctx, 3);
        CGContextMoveToPoint(ctx, start.x, start.y);
        CGContextAddLineToPoint( ctx, end.x, end.y);
        CGContextStrokePath(ctx);
        
        
                
    }
    
    //Add node picture with force arrow
    [[self drawBC] drawAtPoint:CGPointMake(0, 0)];
    [[self drawForce] drawAtPoint:CGPointMake(0, 0)];
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return retImage;

}


+(UIImage*)drawRedundancy
{
    
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    UIGraphicsBeginImageContext([self imageBoundaries]);
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Set bg color = white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 2000, 2000));
    
    [[UIColor darkGrayColor] setFill];
    [@"Normalised redundancy:" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:18]];
    
    
    CGContextSetLineWidth(ctx, 3);
    CGContextStrokePath(ctx);
    //Draw the geometry (one line)
    
    for (int i=0; i<femModel->lineCount(); i++)
    {
        CLinePtr line = femModel->getLine(i);
        CGPoint start = [self localC:CGPointMake(line->getNode0()->getX(), line->getNode0()->getY())];
        CGPoint end = [self localC:CGPointMake(line->getNode1()->getX(), line->getNode1()->getY())];
        
        if (femModel->getRedundancyBrain(femModel)->gets() > 0) {
            rgbColor *elementColor = line->getResults()->getRedundancyColor();
            
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:elementColor->getRed() green:elementColor->getGreen() blue:elementColor->getBlue() alpha:1].CGColor);
        } else if (femModel->getRedundancyBrain(femModel)->gets() == 0)
        {
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:1 alpha:1].CGColor);
        }

        
        CGContextSetLineWidth(ctx, 3);
        CGContextMoveToPoint(ctx, start.x, start.y);
        CGContextAddLineToPoint( ctx, end.x, end.y);
        CGContextStrokePath(ctx);
        
    }
    
    //Add node picture with force arrow
    [[self drawBC] drawAtPoint:CGPointMake(0, 0)];
    CGSize imageSize = [self imageBoundaries];
    UIImage *bc = [UIImage imageNamed:@"colorbar.png"];
    [bc drawAtPoint:CGPointMake(imageSize.width/2-[bc size].width/2, imageSize.height-[bc size].height)];
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return retImage;    
    
}



@end
