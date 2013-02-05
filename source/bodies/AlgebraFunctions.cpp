//
//  AlgebraFunctions.cpp
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/24/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#include "AlgebraFunctions.h"
#include <cmath>

namespace algebraFunctions {
    
    double distansFromPointToLine(double pX,double pY,double startLineX, double startLineY,double endLineX, double endLineY,double &projectX, double &projectY)
    {
        double tempDist=0;
        
        float l2 = pow(endLineX - startLineX,2.0) + pow(endLineY - startLineY,2.0);
        float t = ((pX-startLineX)*(endLineX-startLineX)+(pY-startLineY)*(endLineY-startLineY))/l2;
        
        if (t > 1) {
            tempDist = sqrt(pow(endLineX-pX,2)+pow(endLineY-pY,2));
        } else if (t < 0) {
            tempDist = sqrt(pow(startLineX-pX,2)+pow(startLineY-pY,2));
        } else {
            projectX = startLineX+t*(endLineX-startLineX);
            projectY = startLineY+t*(endLineY-startLineY);
            tempDist = sqrt(pow(projectX-pX,2)+pow(projectY-pY,2));
        }

        return tempDist;
    }
    
}