//
//  SimpleGeom.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#ifndef SimpleFrame_SimpleGeom_h
#define SimpleFrame_SimpleGeom_h

#include "Base.h"
#include <vector>
#include "ColorCode.h"

SmartPointer(CNode);

class CNode : public CBase {
private:
    double m_coord[2];
    int m_index;
public:
    CNode(double x=0, double y=0);
    virtual ~CNode();
    
    ClassInfo("CNode", CBase);
    
    void setCoord(double x, double y);
    void getCoord(double& x, double& y);
    double getX();
    double getY();
    double getBC2();
    
    
    int enumerate(int idx);
    int getEnumerate();
};


SmartPointer(CResults);

class CResults : public CBase {
private:
    double m_displacements_x[20];
    double m_displacements_y[20];
    double m_mekanismEnd_x[20];
    double m_mekanismEnd_y[20];
    double m_mekanismStart_x[20];
    double m_mekanismStart_y[20];
    double m_nForce;
    double m_mForce[2];
    double m_tension[2];
    double m_modalDisp[4];
    rgbColor *m_colorRGB;
public:
    CResults();
    double getMekanismStart_x(int id);
    double getMekanismStart_y(int id);
    double getMekanismEnd_x(int id);
    double getMekanismEnd_y(int id);
    void setMekanismStart(double dx[20], double dy[20], bool start);
    double getDisplacements_x(int id);
    double getDisplacements_y(int id);
    double getMoment(int id);
    void clear();
    void setResults(double dx[20], double dy[20],double nForce, double m[2],double s[2]);
    double getNormalForce();
    double getTension(int id);
    double getModalDisp(int nr);
    void setModalDisp(double modalDisp[4]);
    
    void setRedundancyColor(rgbColor *color);
    rgbColor* getRedundancyColor();
    
};



SmartPointer(CLine);

class CLine : public CBase {
private:
    CNodePtr m_node0;
    CNodePtr m_node1;
    int m_index;
    CResultsPtr m_results;
    int m_startDOF;
    int m_endDOF;
    
public:
    CLine(CNode* node0 = 0, CNode* node1 = 0);
    virtual ~CLine();
    
    void setNode0(CNode* node);
    void setNode1(CNode* node);
    
    void setStartDOF(int startDOF);
    void setEndDOF(int endDOF);
    
    int getStartDOF();
    int getEndDOF();
    
    CNode* getNode0();
    CNode* getNode1();
    
    int enumerate(int idx);
    int getEnumerate();
    
    CResults* getResults();
};


SmartPointer(CViewPort)

class CViewPort : public CBase {
private:
    double m_topLeft[2];
    double m_width;
    double m_height;
    
    double m_screenWidth;
    double m_screenHeight;
public:
    CViewPort();
    virtual ~CViewPort();
    
    void setTopLeft(double x, double y);
    void moveViewPort(double dx, double dy);
    
    void setSize(double width, double height);
    void setScreenSize(double width, double height);
    
    double viewHeight();
    void toScreen(double x, double y, double& sx, double& sy);
    void toWorld(double sx, double sy, double& x, double& y);
    
    void linetoCoord(CLine* line, double& sx, double& sy, double& sx2, double& sy2);
    
    void toScreen(CNode* node, double& sx, double& sy);
    void toWorld(double sx, double sy, CNode* node);
};


#endif
