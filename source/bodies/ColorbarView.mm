//
//  ColorbarView.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/2/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "ColorbarView.h"
#import "ColorCode.h"

@implementation ColorbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    for (int i=0; i<self.frame.size.width; i++)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1.0);
        
        
        double currentElement = i/self.frame.size.width;
        rgbColor* elementColor = new rgbColor(currentElement);
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:elementColor->getRed()  green:elementColor->getGreen() blue:elementColor->getBlue() alpha:1].CGColor);
        CGContextMoveToPoint(context, i, 0);
        CGContextAddLineToPoint( context, i, self.frame.size.height);
        CGContextStrokePath(context);
    }
}


@end
