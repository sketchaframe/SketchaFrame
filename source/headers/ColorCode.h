//
//  ColorCode.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/9/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#ifndef __Sketch_a_Frame__ColorCode__
#define __Sketch_a_Frame__ColorCode__

#include <iostream>



class rgbColor {
private:
	double m_color[3];
public:
	/** Class constructor. */
	rgbColor(double value);
    rgbColor();
    
	/** Class destructor. */
	virtual ~rgbColor();
    
    double getRed();
    double getGreen();
    double getBlue();
};

#endif /* defined(__Sketch_a_Frame__ColorCode__) */