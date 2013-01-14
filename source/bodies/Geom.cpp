//
//  SimpleGeom.cpp
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#include "Geom.h"
#include "math.h"
#include <iostream>
#include <limits>


CNode::CNode(double x, double y)
{
    m_coord[0] = x;
    m_coord[1] = y;
}

void CNode::setCoord(double x, double y)
{
    m_coord[0] = x;
    m_coord[1] = y;
}

void CNode::getCoord(double& x, double& y)
{
    x = m_coord[0];
    y = m_coord[1];
}

double CNode::getX()
{
    return m_coord[0];
}

double CNode::getY()
{
    return m_coord[1];
}

int CNode::enumerate(int idx)
{
    m_index = idx;
    return ++idx;
}

int CNode::getEnumerate()
{
    return m_index;
}

CNode::~CNode()
{
    
}


CResults::CResults()
{
    for (int i=0; i<20; i++)
    {
        m_displacements_x[i] = 0;
        m_displacements_y[i] = 0;
    }
    m_nForce = 0;
    m_mForce[0] = 0;
    m_mForce[1] = 0;
    m_colorRGB = new rgbColor();
}

void CResults::clear()
{
    for (int i=0; i<20; i++)
    {
        m_displacements_x[i] = 0;
        m_displacements_y[i] = 0;
    }
    m_nForce = 0;
    m_mForce[0] = 0;
    m_mForce[1] = 0;
    
}

void CResults::setRedundancyColor(rgbColor *color)
{
    m_colorRGB=color;
}

rgbColor* CResults::getRedundancyColor()
{
    return m_colorRGB;
}

void CResults::setResults(double dx[20], double dy[20],double nForce, double m[2],double s[2])
{
    
    for (int i=0; i<20; i++)
    {
        m_displacements_x[i] = dx[i];
        m_displacements_y[i] = dy[i];
    }
    m_mForce[0] = m[0];
    m_mForce[1] = m[1];
    
    m_tension[0]=s[0];
    m_tension[1]=s[1];
    
    m_nForce=nForce;
}

double CResults::getNormalForce()
{
    return m_nForce;
}

double CResults::getMekanismStart_x(int id)
{
    return m_mekanismStart_x[id];
}

double CResults::getMekanismStart_y(int id)
{
    return m_mekanismStart_y[id];
}

double CResults::getMekanismEnd_x(int id)
{
    return m_mekanismEnd_x[id];
}

double CResults::getMekanismEnd_y(int id)
{
    return m_mekanismEnd_y[id];
}

void CResults::setMekanismStart(double dx[20], double dy[20], bool start)
{
    if (start)
    {
        for (int i=0; i<20; i++)
        {
            m_mekanismStart_x[i] = dx[i];
            m_mekanismStart_y[i] = dy[i];
        }
        
    } else {
        for (int i=0; i<20; i++)
        {
            m_mekanismEnd_x[i] = dx[i];
            m_mekanismEnd_y[i] = dy[i];
        }
    }
}

double CResults::getDisplacements_x(int id)
{
    return m_displacements_x[id];
}

double CResults::getDisplacements_y(int id)
{
    return m_displacements_y[id];
}

double CResults::getMoment(int id)
{
    return m_mForce[id];
}

double CResults::getTension(int id)
{
    return m_tension[id];
}

double CResults::getModalDisp(int nr)
{
    return m_modalDisp[nr];
}

void CResults::setModalDisp(double modalDisp[4])
{
    for (int i=0; i<4; i++)
        m_modalDisp[i] = modalDisp[i];
}

CResults* CLine::getResults()
{
    return m_results;
}









CLine::CLine(CNode* node0, CNode* node1)
{
    m_node0 = node0;
    m_node1 = node1;
    m_results = new CResults();
    for (int i=0; i<3; i++)
    {
        m_startDOF=0;
        m_endDOF=0;
    }
    
}

CLine::~CLine()
{
    
}



void CLine::setNode0(CNode* node)
{
    m_node0 = node;
}

void CLine::setNode1(CNode* node)
{
    m_node1 = node;
}

void CLine::setEndDOF(int endDOF)
{
    m_endDOF = endDOF;
}

void CLine::setStartDOF(int startDOF)
{
    
    m_startDOF = startDOF;
}

int CLine::getStartDOF()
{
    return m_startDOF;
}


int CLine::getEndDOF()
{
    return m_endDOF;
}

CNode* CLine::getNode0()
{
    return m_node0;
}

CNode* CLine::getNode1()
{
    return m_node1;
}

int CLine::enumerate(int idx)
{
    m_index = idx;
    return ++idx;
}
int CLine::getEnumerate()
{
    return m_index;
}

CViewPort::CViewPort()
{
    m_topLeft[0] = 0.0;
    m_topLeft[1] = 0.0;
    m_screenWidth = 1.0;
    m_screenHeight = 1.0;
    m_width = 1.0;
    m_height = 1.0;
}

CViewPort::~CViewPort()
{
    
}

void CViewPort::setTopLeft(double x, double y)
{
    m_topLeft[0] = x;
    m_topLeft[1] = y;
}

void CViewPort::moveViewPort(double dx, double dy)
{
    m_topLeft[0] += dx;
    m_topLeft[1] += dy;
}

void CViewPort::setSize(double width, double height)
{
    m_width = width;
    m_height = height;
}

void CViewPort::setScreenSize(double width, double height)
{
    m_screenWidth = width;
    m_screenHeight = height;
}

double CViewPort::viewHeight() {
    return m_screenHeight;
}

void CViewPort::toScreen(double x, double y, double& sx, double& sy)
{
    sx = (x - m_topLeft[0])*m_screenWidth/m_width;
    sy = (m_topLeft[1] - y)*m_screenHeight/m_height;
}

void CViewPort::toWorld(double sx, double sy, double& x, double& y)
{
    x = sx * (m_width / m_screenWidth) + m_topLeft[0];
    y = m_topLeft[1] - sy * (m_width / m_screenWidth);
}

void CViewPort::toScreen(CNode *node, double &sx, double &sy)
{
    this->toScreen(node->getX(), node->getY(), sx, sy);
}


void CViewPort::linetoCoord(CLine *line, double &sx, double &sy, double &sx2, double &sy2)
{
    sx = (line->getNode0())->getX();
    sy = m_height - (line->getNode0())->getY();
    sx2 = (line->getNode1())->getX();
    sy2 = m_height - (line->getNode1())->getY();
    
}



void CViewPort::toWorld(double sx, double sy, CNode* node)
{
    double x = node->getX();
    double y = node->getY();
    this->toWorld(sx, sy, x, y);
    node->setCoord(x, y);
}



