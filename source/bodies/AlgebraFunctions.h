//
//  AlgebraFunctions.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/24/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#ifndef __Sketch_a_Frame__AlgebraFunctions__
#define __Sketch_a_Frame__AlgebraFunctions__

#include <iostream>

namespace algebraFunctions {

    double distansFromPointToLine(double pX,
                                  double pY,
                                  double startLineX,
                                  double startLineY,
                                  double endLineX,
                                  double endLineY,
                                  double &projectX,
                                  double &projectY);
};

#endif /* defined(__Sketch_a_Frame__AlgebraFunctions__) */