//
//  ColorCode.cpp
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/9/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#include "ColorCode.h"
#include <cmath>

rgbColor::rgbColor(double value)
{
    //Figure out the color using Tiberts colors
    double k,l, k1,k2,l1,l2;
    value = sqrt(pow(value,2));
    
    if (value >= 0 && value <=0.33333333)
    {
        k=3; //(1)/(16/48);
        
        m_color[0] = 0;
        m_color[1] = k*value;
        m_color[2] = 1;
        
    } else if (value >0.33333333 && value <=0.5) {
        k1=3.0118; //(128/255-0)/(24/48-16/48);
        k2=-2.9882; //(128/255-255/255)/(24/48-16/48);
        l1=-1.0039;
        l2=1.9961;
        
        m_color[0] = k1*value+l1;
        m_color[1] = 1;
        m_color[2] = k2*value+l2;
        
    } else if (value >0.5 && value <=0.666667) {
        k1=2.9882; //(255/255-128/255)/(32/48-24/48);
        k2=-3.0118; // (0-128/255)/(32/48-24/48);
        l1=-0.9922;
        l2=2.0078;
        
        m_color[0] = k1*value+l1;
        m_color[1] = 1;
        m_color[2] = k2*value+l2;
        
    } else if (value >0.666667 && value <=1.00) {
        k=-3;
        l=3;
        
        m_color[0] = 1;
        m_color[1] = k*value+l;
        m_color[2] = 0;
    }
    
}

rgbColor::rgbColor()
{
    
}

rgbColor::~rgbColor()
{
    
}


double rgbColor::getRed()
{
    return m_color[0];
}

double rgbColor::getGreen()
{
    return m_color[1];
}

double rgbColor::getBlue()
{
    return m_color[2];
}