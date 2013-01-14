//
//  Fem.cpp
//  TestModel
//
//  Created by Jonas Lindemann on 2012-06-23.
//  Copyright (c) 2012 Zoom Media. All rights reserved.
//

#include "Fem.h"
#include "calfem.h"
#include <iostream>
#include <cmath>


CDofs::CDofs()
{
    m_dofs[0] = -1;
    m_dofs[1] = -1;
    m_dofs[2] = -1;
}

int CDofs::getDof(int idx)
{
    if ((idx>=0)&&(idx<=2))
        return m_dofs[idx];
    else
        return -1;
}

int CDofs::getDofCount()
{
    return 3;
}

int CDofs::enumerate(int startIdx)
{
    m_dofs[0] = startIdx;
    m_dofs[1] = startIdx + 1;
    m_dofs[2] = startIdx + 2;
    return startIdx + 3;
}



CFemNode::CFemNode(double x, double y)
:CNode(x, y)
{
    m_dofs = new CDofs();
}

CFemNode::~CFemNode()
{
    this->clearBCs();
    this->clearForces();
}

CDofs* CFemNode::getDofs()
{
    return m_dofs;
}



void CFemNode::addForce(CForce* force)
{
    m_nodeForces.push_back(force);
}

void CFemNode::removeForce(CForce *force)
{
    std::vector<CForce*>::iterator it;
    
    for (it=m_nodeForces.begin(); it!=m_nodeForces.end(); it++)
    {
        if ((*it)==force)
        {
            m_nodeForces.erase(it);
            force->clearNode();
            break;
        }
    }
}

void CFemNode::clearForces()
{
    std::vector<CForce*>::iterator it;
    
    for (it=m_nodeForces.begin(); it!=m_nodeForces.end(); it++)
    {
        CForce* force = (*it);
        force->clearNode();
    }
    m_nodeForces.clear();
}

int CFemNode::getForceCount()
{
    return m_nodeForces.size();
}

int CFemModel::getBCCount()
{
    return m_bcs.size();
}

CForce* CFemNode::getForce(int idx)
{
    if ((idx>=0)&&(idx<m_nodeForces.size()))
        return m_nodeForces[idx];
    else
        return 0;
}

void CFemNode::addBC(CBoundaryCondition* bc)
{
    m_nodeBCs.push_back(bc);
}

void CFemNode::removeBC(CBoundaryCondition* bc)
{
    std::vector<CBoundaryCondition*>::iterator it;
    
    for (it=m_nodeBCs.begin(); it!=m_nodeBCs.end(); it++)
    {
        if ((*it)==bc)
        {
            m_nodeBCs.erase(it);
            bc->clearNode();
            break;
        }
    }
}


void CFemNode::clearBCs()
{
    std::vector<CBoundaryCondition*>::iterator it;
    
    for (it=m_nodeBCs.begin(); it!=m_nodeBCs.end(); it++)
    {
        CBoundaryCondition* bc = (*it);
        bc->clearNode();
    }
    m_nodeBCs.clear();
}

int CFemNode::getBCCount()
{
    return m_nodeBCs.size();
}

void CFemModel::setDOFcount(int count)
{
    m_DOFcount = count;
}

int CFemModel::getDOFcount()
{
    return m_DOFcount;
}


CBoundaryCondition* CFemNode::getBC(int idx)
{
    if ((idx>=0)&&(idx<m_nodeBCs.size()))
        return m_nodeBCs[idx];
    else
        return 0;
}



CForce::CForce(double magnitude, double vx, double vy)
{
    m_direction.setComponents(vx, vy);
    m_direction.normalize();
    m_magnitude = magnitude;
}

void CForce::setNode(CFemNode* node)
{
    m_node = node;
    m_node->addForce(this);
}

CFemNode* CForce::getNode()
{
    return m_node;
}

double CForce::getMagnitude()
{
    return m_magnitude;
}

double CForce::getCompX()
{
    return m_direction.getX();
}

double CForce::getCompY()
{
    return m_direction.getY();
}

void CForce::setForceComponents(double compX,double compY)
{
    m_direction.setComponents(compX, compY);
    m_direction.normalize();
    m_magnitude = sqrt(pow(compX,2)+pow(compY,2));
    if (m_magnitude < 40)
        m_magnitude = 40;
}

void CForce::clearNode()
{
    m_node = 0;
}

CBoundaryCondition::CBoundaryCondition(int type)
{
    m_bcType = type;
}

void CBoundaryCondition::setNode(CFemNode* node)
{
    m_node = node;
    m_node->addBC(this);
}

CFemNode* CBoundaryCondition::getNode()
{
    return m_node;
}

int CBoundaryCondition::getType()
{
    return (int)m_bcType;
}

void CBoundaryCondition::clearNode()
{
    m_node = 0;
}

CFemModel::CFemModel()
{
    m_name="";
    m_drawModes[0] = true;
    m_drawModes[1] = true;
    m_drawModes[2] = true;
    m_drawModes[3] = false;
    m_drawModes[4] = false;
    m_drawModes[5] = false;
}

CFemModel::~CFemModel()
{
    
}


void CFemModel::printNodes()
{
    using namespace std;
    std::cout << "Nodes:" << endl;
    std::vector<CFemNodePtr>::iterator it;
    int idx = 0;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
    {
        CFemNode* node = (*it);
        
        /*
         cout << "Node " << idx << " (" << (*it)->getX() << ", " << (*it)->getY() << " BC= " << (*it)->getBC2()<< "Force x:" << (*it)->getForceX2() << " y:" << (*it)->getForceY2() << ") refs = " << (*it)->getReferenceCount() << endl;
         */
        
        cout << "Node" << idx << " (" << node->getX() << ", " << node->getY() << ") - Dofs: (" << node->getDofs()->getDof(0) << ", " << node->getDofs()->getDof(1) << ", " << node->getDofs()->getDof(2) << ")" << endl;
        
        if (node->getForceCount()>0)
        {
            for (int i=0; i<node->getForceCount(); i++)
                cout << "\tForce: Magnitude = " << node->getForce(i)->getMagnitude() << ", Direction = (" << node->getForce(i)->getCompX() << ", " << node->getForce(i)->getCompY() << ")" << endl;
        }
        
        idx++;
    }
}

void CFemModel::printLines()
{
    using namespace std;
    
    std::vector<CLinePtr>::iterator it;
    int idx = 0;
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
    {
        
        cout << "Line " << idx << " cord = " << ((*it)->getNode0())->getX() << "," << ((*it)->getNode0())->getY()<< "->" << ((*it)->getNode1())->getX() << "," << ((*it)->getNode1())->getY()<< " Refs: "<< (*it)->getReferenceCount() << endl;
        
        idx++;
    }
}



void CFemModel::print()
{
    this->updateBounds();
    
    using namespace std;
    
    cout << "Geometry bounds = (" << m_minX << ", " << m_minY << ") - (" << m_maxX << ", " << m_maxY << ")" << endl << endl;
    
    cout << "Nodes:" << endl << endl;
    
    this->printNodes();
    
    cout << endl << "Lines:" << endl << endl;
    
    this->printLines();
}

void CFemModel::addNode(double x, double y)
{
    m_nodes.push_back(CFemNodePtr(new CFemNode(x, y)));
}

void CFemModel::removeNode(double x, double y)
{
    using namespace std;
    
    if (findNode(x,y, 25) != 9999) {
        m_nodes.erase(m_nodes.begin() + findNode(x,y, 25));
    }
}

void CFemModel::addForce(int nodeIdx, double magnitude, double vx, double vy)
{
    if ((nodeIdx>=0)&&(nodeIdx<m_nodes.size()))
    {
        CForce* force = new CForce(magnitude, vx, vy);
        m_forces.push_back(CForcePtr(force));
        m_nodes[nodeIdx]->addForce(new CForce(magnitude, vx, vy));
    }
}


void CFemModel::addBC(int nodeIdx, int type)
{
    if ((nodeIdx>=0)&&(nodeIdx<m_nodes.size()))
    {
        CBoundaryCondition* bc = new CBoundaryCondition(type);
        m_bcs.push_back(CBoundaryConditionPtr(bc));
        m_nodes[nodeIdx]->addBC(bc);
    }
}


void CFemModel::clearForces()
{
    std::vector<CForcePtr>::iterator it;
    
    for (it=m_forces.begin(); it!=m_forces.end(); )
    {
        if ((*it)->getReferenceCount()==1)
        {
            CForce* force = *it;
            force->getNode()->removeForce(force);
            force->clearNode();
            it = m_forces.erase(it);
        }
        else
        {
            it++;
        }
    }
}

void CFemModel::clearResults()
{
    
    std::vector<CLinePtr>::iterator it;
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
    {
        (*it)->getResults()->clear();
        
    }
}


int CFemModel::getForceX(int idn, int forceID)
{
    std::vector<CFemNodePtr>::iterator it;
    it=m_nodes.begin() + idn;
    CFemNode* node = (*it);
    
    
    if (node->getForceCount()>0)
        return node->getForce(forceID)->getMagnitude() * node->getForce(forceID)->getCompX();
    else
        return 0;
    
    
}

int CFemModel::getForceY(int idn, int forceID)
{
    std::vector<CFemNodePtr>::iterator it;
    it=m_nodes.begin() + idn;
    CFemNode* node = (*it);
    
    if (node->getForceCount()>0)
        return node->getForce(forceID)->getMagnitude() * node->getForce(forceID)->getCompY();
    else
        return 0;
    
    
}


double CFemModel::getScale()
{
    return m_scale;
}

void CFemModel::setScale(double scale)
{
    m_scale = scale;
}

double CFemModel::getMomentScale()
{
    return m_momentscale*1e-4;
}

void CFemModel::setMomentScale(double scale)
{
    m_momentscale = scale;
}

void CFemModel::setDrawMode(bool def, bool mom, bool nor, bool grid, bool ortho, bool tension, bool redundancy)
{
    m_drawModes[0] = def;
    m_drawModes[1] = mom;
    m_drawModes[2] = nor;
    m_drawModes[3] = grid;
    m_drawModes[4] = ortho;
    m_drawModes[5] = tension;
    m_drawModes[6] = redundancy;
    
}

bool CFemModel::drawRedundancy()
{
    return m_drawModes[6];
}

bool CFemModel::drawDeformation()
{
    return m_drawModes[0];
}

bool CFemModel::drawMoment()
{
    return m_drawModes[1];
}

bool CFemModel::drawNormal()
{
    return m_drawModes[2];
}

bool CFemModel::showGrid()
{
    return m_drawModes[3];
}

bool CFemModel::orthoMode()
{
    return m_drawModes[4];
}

bool CFemModel::tensionMode()
{
    return m_drawModes[5];
}

string CFemModel::getName()
{
    return m_name;
}

void CFemModel::setName(string name)
{
    m_name=name;
}


void CFemModel::setBC(CBoundaryCondition* type, int nodeID, int bcID)
{
    std::vector<CFemNodePtr>::iterator it;
    it=m_nodes.begin() + nodeID;
    CFemNode* node = (*it);
    
    if (node->getBCCount()>0)
    {
        //node->getBC(nodeID)->setBCCondition(type);
    }
    else
    {
        node->addBC(type);
    }
}

void CFemModel::setForce(double x, double y, int nodeID,int forceID)
{
    
    std::vector<CFemNodePtr>::iterator it;
    it=m_nodes.begin() + nodeID;
    CFemNode* node = (*it);
    
    if (node->getForceCount()>0)
        node->getForce(forceID)->setForceComponents(x, y);
}



void CFemModel::removeLine(double x, double y)
{
    using namespace std;
    
    for (int i = 0; i!=100;i++)
    {
        if (findLine(x,y, 25) != 9999) {
            m_lines.erase(m_lines.begin() + findLine(x,y, 25));
        } else {
            break;
        }
    }
    
    
}

void CFemModel::removeOneLine(double x, double y)
{
    if (findLine(x,y, 25) != 9999) {
        m_lines.erase(m_lines.begin() + findLine(x,y, 25));
    }
}

bool CFemModel::lineExists(int start, int end)
{
    
    using namespace std;
    std::vector<CLinePtr>::iterator it;
    
    double x1 = m_nodes[start]->getX();
    double y1 = m_nodes[start]->getY();
    double x2 = m_nodes[end]->getX();
    double y2 = m_nodes[end]->getY();
    
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
    {
        //Check if line exists from A-B
        if ((x1 == ((*it)->getNode0())->getX()) && (y1 == ((*it)->getNode0())->getY()) && (x2 == ((*it)->getNode1())->getX()) && (y2 == ((*it)->getNode1())->getY()))
        {
            std::cout<< "Line exists already" << endl;
            return true;
            
        }
        //Check if line exists from B->A
        if ((x2 == ((*it)->getNode0())->getX()) && (y2 == ((*it)->getNode0())->getY()) && (x1 == ((*it)->getNode1())->getX()) && (y1 == ((*it)->getNode1())->getY()))
        {
            cout<< "Line exists already (oppsosite)" << endl;
            return true;
        }
        
    }
    
    return false;
}

int CFemModel::findNode(double x, double y, int distSetting)
{
    using namespace std;
    vector<CFemNodePtr>::iterator it;
    
    int idx = 0;
    float dist=2000;
    int Node=0;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
    {
        if (sqrt(pow((*it)->getX()-x,2) + pow((*it)->getY()-y,2)) < dist)
        {
            dist = sqrt(pow((*it)->getX()-x,2) + pow((*it)->getY()-y,2));
            Node = idx;
            
        }
        idx++;
    }
    
    if (dist < distSetting) {
        return Node;
    } else {
        return 9999;
    }
}

int CFemModel::findAction(double x, double y, int distSetting, int &type)
{
    using namespace std;
    vector<CFemNodePtr>::iterator it;
    
    int idx = 0;
    float dist=2000;
    int Node=0;
    type=0;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
    {
        if (sqrt(pow((*it)->getX()-x,2) + pow((*it)->getY()-y,2)) < dist)
        {
            dist = sqrt(pow((*it)->getX()-x,2) + pow((*it)->getY()-y,2));
            Node = idx;
            type=1;
        }
        idx++;
    }
    
    idx=0;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
    {
        // See if there's a closer distance to an action point
        // Make sure node has a force for this to run
        if ((*it)->getForceCount() > 0) {
            std::cout << "GOT FORCE NODE" << std::endl;
            
            double tempDist=0;
            int start_x = (*it)->getX();
            int start_y = (*it)->getY();
            int end_x = (*it)->getX()+(*it)->getForce(0)->getCompX()*(*it)->getForce(0)->getMagnitude();
            int end_y =(*it)->getY()+(*it)->getForce(0)->getCompY()*(*it)->getForce(0)->getMagnitude();
            
            float l2 = pow(end_x - start_x,2.0) + pow(end_y - start_y,2.0);
            float t = ((x-start_x)*(end_x-start_x)+(y-start_y)*(end_y-start_y))/l2;
            
            if (t > 1) {
                tempDist = sqrt(pow(end_x-x,2)+pow(end_y-y,2));
            } else if (t < 0) {
                tempDist = sqrt(pow(start_x-x,2)+pow(start_y-y,2));
            } else {
                float projection_x = start_x+t*(end_x-start_x);
                float projection_y = start_y+t*(end_y-start_y);
                tempDist = sqrt(pow(projection_x-x,2)+pow(projection_y-y,2));
            }
            
            if (tempDist < dist)
            {
                dist = tempDist;
                Node = idx;
                type=2;
            }
            
        }
        idx++;
    }
    
    //std::cout << "Closest action is : " << dist << "of type " << type << " w id: " << Node << std::endl;
    if (dist < distSetting) {
        return Node;
    } else {
        return 9999;
    }
}



void CFemModel::setCord(double x, double y, int idn)
{
    std::vector<CFemNodePtr>::iterator it;
    it = m_nodes.begin()+ idn;
    (*it)->setCoord(x, y);
}
int CFemModel::findLine(double x, double y, int distSetting)
{
    using namespace std;
    std::vector<CLinePtr>::iterator it;
    int idx = 0;
    
    float dist;
    float dist2=10000;
    int Line=0;
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
    {
        
        int start_x = ((*it)->getNode0())->getX();
        int start_y = ((*it)->getNode0())->getY();
        int end_x = ((*it)->getNode1())->getX();
        int end_y =((*it)->getNode1())->getY();
        
        float l2 = pow(end_x - start_x,2.0) + pow(end_y - start_y,2.0);
        float t = ((x-start_x)*(end_x-start_x)+(y-start_y)*(end_y-start_y))/l2;
        
        if (t > 1) {
            dist = sqrt(pow(end_x-x,2)+pow(end_y-y,2));
        } else if (t < 0) {
            dist = sqrt(pow(start_x-x,2)+pow(start_y-y,2));
        } else {
            float projection_x = start_x+t*(end_x-start_x);
            float projection_y = start_y+t*(end_y-start_y);
            dist = sqrt(pow(projection_x-x,2)+pow(projection_y-y,2));
        }
        
        if (dist2 > dist)
        {
            dist2 = dist;
            Line = idx;
        }
        
        idx++;
    }
    
    
    if (dist2 < distSetting) {
        return Line;
    } else {
        return 9999;
    }
}

bool CFemModel::foundGrid(double x,double y,double snapDistance,double &gridX,double &gridY)
{
    int space = 65;
    int nrX = x/space;
    int nrY = y/space;
    
    gridX=-1;
    gridY=-1;
    
    if (abs(nrX-x/space)<snapDistance)
        gridX = nrX*space;
    
    if (abs(nrX-x/space)>(1-snapDistance))
    {
        nrX++;
        gridX=nrX*space;
    }
    
    if (abs(nrY-y/space)<snapDistance)
        gridY = nrY*space;
    
    if (abs(nrY-y/space)>(1-snapDistance))
    {
        nrY++;
        gridY=nrY*space;
    }
    
    if (gridX+gridY >= 0)
        return true;
    else
        return false;
    
    
}


int CFemModel::findLineExtended(double x, double y, int distSetting, double &lineX, double &lineY)
{
    using namespace std;
    std::vector<CLinePtr>::iterator it;
    int idx = 0;
    
    float dist;
    float dist2=10000;
    int Line=0;
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
    {
        double projection_x;
        double projection_y;
        
        int start_x = ((*it)->getNode0())->getX();
        int start_y = ((*it)->getNode0())->getY();
        int end_x = ((*it)->getNode1())->getX();
        int end_y =((*it)->getNode1())->getY();
        
        float l2 = pow(end_x - start_x,2.0) + pow(end_y - start_y,2.0);
        float t = ((x-start_x)*(end_x-start_x)+(y-start_y)*(end_y-start_y))/l2;
        
        if (t > 1) {
            dist = sqrt(pow(end_x-x,2)+pow(end_y-y,2));
            projection_x = end_x;
            projection_y = end_y;
        } else if (t < 0) {
            dist = sqrt(pow(start_x-x,2)+pow(start_y-y,2));
            projection_x = start_x;
            projection_y = start_y;
        } else {
            projection_x = start_x+t*(end_x-start_x);
            projection_y = start_y+t*(end_y-start_y);
            dist = sqrt(pow(projection_x-x,2)+pow(projection_y-y,2));
        }
        
        if (dist2 > dist)
        {
            dist2 = dist;
            Line = idx;
            lineX = projection_x;
            lineY = projection_y;
        }
        
        idx++;
    }
    
    
    if (dist2 < distSetting) {
        return Line;
    } else {
        return 9999;
    }
}




void CFemModel::addLine(int idx0, int idx1)
{
    
    if ((idx0 + idx1) < 10000)
    {
        
        if ((idx0<0)||(idx0>=m_nodes.size()))
            return;
        if ((idx1<0)||(idx1>=m_nodes.size()))
            return;
        
        m_lines.push_back(CLinePtr(new CLine(m_nodes[idx0], m_nodes[idx1])));
    }
    
    
}

void CFemModel::clearNodes()
{
    std::cout << "clear nodes";
    
    std::vector<CFemNodePtr>::iterator it;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); )
    {
        if ((*it)->getReferenceCount()==1)
            it = m_nodes.erase(it);
        else {
            it++;
        }
    }
}

void CFemModel::clearLines()
{
    std::vector<CLinePtr>::iterator it;
    
    for (it=m_lines.begin(); it!=m_lines.end(); )
    {
        if ((*it)->getReferenceCount()==1)
            it = m_lines.erase(it);
        else {
            it++;
        }
    }
}

void CFemModel::clear()
{
    //this->clearForces();
    this->clearLines();
    this->clearNodes();
    this->setName("");
    this->setMaxDisp(0);
    this->setMaxMoment(0);
    this->setMaxTension(0);
    this->setDegreeOfMechanism(-1);
}

int CFemModel::nodeCount()
{
    return m_nodes.size();
}

int CFemModel::lineCount()
{
    return m_lines.size();
}



CFemNode* CFemModel::getNode(int idx)
{
    if ((idx>=0)&&(idx<m_nodes.size()))
        return m_nodes[idx];
    else
        return 0;
}

CLine* CFemModel::getLine(int idx)
{
    if ((idx>=0)&&(idx<m_lines.size()))
        return m_lines[idx];
    else
        return 0;
}

int CFemModel::enumerateNodes(int idx)
{
    std::vector<CFemNodePtr>::iterator it;
    
    int i = idx;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
        i = (*it)->enumerate(i);
    
    return i;
}

int CFemModel::enumerateLines(int idx)
{
    std::vector<CLinePtr>::iterator it;
    
    int i = idx;
    
    for (it=m_lines.begin(); it!=m_lines.end(); it++)
        i = (*it)->enumerate(i);
    
    return i;
}

int CFemModel::enumerateDofs(int idx)
{
    std::vector<CFemNodePtr>::iterator it;
    
    int i = idx;
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
        i = (*it)->getDofs()->enumerate(i);
    
    return i;
}


void CFemModel::updateBounds()
{
    std::vector<CFemNodePtr>::iterator it;
    
    m_minX = std::numeric_limits<double>::max();
    m_minY = std::numeric_limits<double>::max();
    m_maxX = -std::numeric_limits<double>::max();
    m_maxY = -std::numeric_limits<double>::max();
    
    for (it=m_nodes.begin(); it!=m_nodes.end(); it++)
    {
        if ((*it)->getX()<m_minX)
            m_minX = (*it)->getX();
        if ((*it)->getX()>m_maxX)
            m_maxX = (*it)->getX();
        if ((*it)->getY()<m_minY)
            m_minY = (*it)->getY();
        if ((*it)->getY()>m_maxY)
            m_maxY = (*it)->getY();
    }
}

void CFemModel::setMaxDisp(double maxDisp)
{
    m_maxDisp = maxDisp;
}

double CFemModel::getMaxDisp()
{
    return m_maxDisp;
}

void CFemModel::setMaxMoment(double maxMoment)
{
    m_maxMoment = maxMoment;
}

double CFemModel::getMaxMoment()
{
    return m_maxMoment;
}

void CFemModel::setMaxTension(double maxTension)
{
    m_maxTension=maxTension;
}

double CFemModel::getMaxTension()
{
    return m_maxTension;
}

int CFemModel::getDegreeOfMechanism()
{
    return m_degreeMechanism;
}

void CFemModel::setDegreeOfMechanism(int degree)
{
    m_degreeMechanism = degree;
}

void CFemModel::setCheckModel(bool checkModel[5])
{
    for (int i=0; i<5; i++)
    {
        m_checkModel[i]=checkModel[i];
    }
    
}

bool CFemModel::checkUnconnectedNodes()
{
    return m_checkModel[0];
}

bool CFemModel::checkFreeRotation()
{
    return m_checkModel[1];
}

bool CFemModel::checkFreeX()
{
    return m_checkModel[2];
}

bool CFemModel::checkFreeY()
{
    return m_checkModel[3];
}

bool CFemModel::checkNoForceApplied()
{
    return m_checkModel[4];
}

CCalfemBrain* CFemModel::getCalfemBrain(CFemModel* model)
{
    if (!calfemBrain)
        calfemBrain = new CCalfemBrain(model);
    return calfemBrain;
}

bool CFemModel::calculate(bool geometryUpdated, bool doStaticAnalysis)
{
    this->getCalfemBrain(this);
    return calfemBrain->femCalculations(geometryUpdated, doStaticAnalysis);
    
}

CRedundancyBrain* CFemModel::getRedundancyBrain(CFemModel *model)
{
    if (!redundancyBrain)
        redundancyBrain = new CRedundancyBrain(model);
    
    return redundancyBrain;
}

void CFemModel::calculateRedundancy()
{
    this->getRedundancyBrain(this);
    redundancyBrain->calculateRedundancy();
}



CRedundancyBrain::CRedundancyBrain(CFemModel* modelStorage)
{
    model = modelStorage;
    m=0;
    s=0;
}


int CRedundancyBrain::getLockedHDOFCount()
{
    int lockedXYdofs = 0;
    
    for (int i=0; i<=model->nodeCount()-1; i++)
    {
        CFemNode* node = model->getNode(i);
        
        if (node->getBCCount() > 0)
        {
            
            if (node->getBC(0)->getType() == 2 || node->getBC(0)->getType() == 3)
                lockedXYdofs++;
            
            if (node->getBC(0)->getType() == 0 || node->getBC(0)->getType() == 1)
                lockedXYdofs+=2;
        }
    }
    
    return lockedXYdofs;
}

void CRedundancyBrain::getHDOF(int nodeID, bool xDirection, int &hDOF, bool &free)
{
    int hDOFcount = 0;
    hDOF=-1;
    
    CFemNode* node;
    bool freeX, freeY;
    for (int i=0; i<model->nodeCount(); i++)
    {
        node = model->getNode(i);
        freeX = true;
        freeY = true;
        
        if (node->getBCCount()>0)
        {
            switch (node->getBC(0)->getType()) {
                case 2:
                    freeY = false;
                    break;
                case 3:
                    //Free in y direction
                    freeX = false;
                    break;
                case 0:
                    freeX = false;
                    freeY = false;
                    break;
                case 1:
                    freeX = false;
                    freeY = false;
                    break;
                    
                default:
                    break;
            }
        }
        
        if (freeX)
        {
            hDOFcount++;
            
            if (i==nodeID && xDirection)
                hDOF=hDOFcount;
        }
        
        if (freeY)
        {
            hDOFcount++;
            
            if (i==nodeID && !xDirection)
                hDOF=hDOFcount;
        }
        
        
        //If this is the node to check, return if its locked or not
        if (i==nodeID)
        {
            if (xDirection)
                free=freeX;
            else
                free=freeY;
        }
        
        
    }
    
}

void CRedundancyBrain::getEquilibriumMatrix()
{
    
    H.resize(2*model->nodeCount()-getLockedHDOFCount(),model->lineCount());
    H = 0.0;
    for (int i=0; i<model->lineCount(); i++)
    {
        CFemNode *startNode = model->getNode(model->getLine(i)->getNode0()->getEnumerate());
        CFemNode *endNode = model->getNode(model->getLine(i)->getNode1()->getEnumerate());
        double elementLength = sqrt(pow(endNode->getX() - startNode->getX(),2) + pow(endNode->getY()-startNode->getY(),2));
        int hDOF;
        bool free;
        
        //cout << "start id: " << startNode->getEnumerate() << " end id: " << endNode->getEnumerate() << endl;
        
        //Startnode
        //x-direction get the h-dof and if its free
        getHDOF(startNode->getEnumerate(), true, hDOF, free);
        if (free)
        {
            H(hDOF,i+1) = ((startNode->getX() - endNode->getX()))/elementLength;
            //cout << "first H x direction " << (startNode->getX() - endNode->getX()) << "hdof:" << hDOF << endl;
        }
        
        //y-direction
        getHDOF(startNode->getEnumerate(), false, hDOF, free);
        if (free)
            H(hDOF,i+1) = ((startNode->getY() - endNode->getY()))/elementLength;
        
        //Endnode
        //x-direction get the h-dof and if its free
        getHDOF(endNode->getEnumerate(), true, hDOF, free);
        if (free)
            H(hDOF,i+1) = ((endNode->getX() - startNode->getX()))/elementLength;
        //cout << "Endnode: " << endNode->getX() << " Startnode X" << startNode->getX() << endl;
        //y-direction
        getHDOF(endNode->getEnumerate(), false, hDOF, free);
        if (free)
            H(hDOF,i+1) = (endNode->getY() - startNode->getY())/elementLength;
        
        //cout << "Locked DOFs XY" << getLockedHDOFCount() << endl;;
        //cout << "H-matrix:" << endl << H << endl;
        
    }
    //cout << "H-matrix:" << H << endl;
}

int CRedundancyBrain::getm()
{
    return m;
}

int CRedundancyBrain::gets()
{
    return s;
}

void CRedundancyBrain::calculateRedundancy()
{
    
    
    m=100;
    s=0;
    
    model->enumerateDofs(1);
    model->enumerateNodes(0);
    model->enumerateLines(0);
    model->clearResults();
    //
    //    if (nc<nr && nr>0)
    //    {
    //
    //        Matrix U,V;
    //        DiagonalMatrix D;
    //
    //        SVD(H, D, U, V);
    //
    //        int rmax = min(nr,nc);
    //        int i=2;
    //        int r=0;
    //
    //        if (rmax == 2 && D(2)/D(1)<0.001)
    //        {
    //            r=1;
    //        } else {
    //            while (i<=rmax && D(i)/D(1)>0.001) {
    //                r=i;
    //                i++;
    //            }
    //        }
    //
    //        m = nr-r;
    //        s = nc-r;
    //
    //    }
    
    model->getCalfemBrain(model)->checkMechanim();
    
    if (!model->checkUnconnectedNodes())
        this->getBarMekanism();
    
    s=model->lineCount()-2*model->nodeCount()+model->nodeCount()*2-freeDOFs.size();
    
    if (model->lineCount() > 0 && model->getBCCount()>0 && m==0 && s>0)
    {
        H=0.0;
        getEquilibriumMatrix();
        
        //Investigate the matrix
        int nr, nc;
        nr = 2*model->nodeCount()-getLockedHDOFCount();
        nc = model->lineCount();
        
        
        //cout << "Static deter. " << s << endl;
        
        
        Matrix LAMBDA;
        LAMBDA = 0.0;
        
        PSI.resize(model->lineCount(), model->lineCount());
        PSI = 0.0;
        
        for (int i=0; i<model->lineCount(); i++)
            PSI(i+1,i+1)=1;
        
        
        IdentityMatrix I(model->lineCount());
        Matrix detTest =H*PSI*H.t();
        if (detTest.determinant() != 0)
            LAMBDA = I- H.t()*(H*PSI*H.t()).i()*H*PSI;
        else
        {
            cout << "Error redundance system not solveable";
            
            return;
        }
        
        double currentElement=0;
        
        ColumnVector redundancies(model->lineCount());
        double highestRedundance, lowestRedundancy;
        
        for (int i=0; i<model->lineCount();i++)
        {
            //cout << "Diagonalen RR: " << LAMBDA(i+1,i+1) << endl;
            redundancies(i+1) = LAMBDA(i+1,i+1);
        }
        
        
        //highestRedundance = floor((highestRedundance+0.5)*1000)/1000;
        for (int i=0; i<model->lineCount();i++)
        {
            
            currentElement = redundancies(i+1);
            lowestRedundancy = redundancies.minimum();
            
            //Normalize
            highestRedundance = redundancies.maximum ();
            
            
            //currentElement = floor((currentElement+0.5)*1000)/1000;
            
            if (currentElement > highestRedundance)
                cout << "error";
            
            if (currentElement != 0)
                currentElement = currentElement/highestRedundance;
            
            
            model->getLine(i)->getResults()->setRedundancyColor(new rgbColor(currentElement));
        }
        
    }
}

void CRedundancyBrain::getPSI()
{
    PSI.resize(model->lineCount(), model->lineCount());
    Matrix FI;
    FI = 0.0;
    PSI = 0.0;
    
    FI.resize(model->lineCount(), model->lineCount());
    
    
    for (int i=0; i<model->lineCount();i++)
    {
        CFemNode *startNode = model->getNode(model->getLine(i)->getNode0()->getEnumerate());
        CFemNode *endNode = model->getNode(model->getLine(i)->getNode1()->getEnumerate());
        
        //double elementLength = sqrt(pow(endNode->getX()-startNode->getX(),2) + pow(endNode->getY()-startNode->getY(),2));
        FI(i+1,i+1) = 1; //elementLength / (ep(1)*ep(2));
        
    }
    //cout << "Fi: " << FI;
    
    PSI = FI.i();
}


int CRedundancyBrain::getBarMekanism()
{
    RowVector ex(2);
    RowVector ey(2);
    RowVector Topo(4);
    Matrix Ke(4,4); Ke=0.0;
    
    ep.resize(4);
    ep(1) = 2.1e11; //   E
    ep(2) = 764e-6; //   A
    ep(3) = 0.801e-6; // I
    ep(4) = 20e3; //     W
    
    SymmetricBandMatrix tempK(model->nodeCount()*2,model->nodeCount()*2);
    tempK=0.0;
    
    for (int i=0; i<=model->lineCount()-1; i++)
    {
        CFemNode* startNode = model->getNode(model->getLine(i)->getNode0()->getEnumerate());
        CFemNode* endNode = model->getNode(model->getLine(i)->getNode1()->getEnumerate());
        
        ex(1)= startNode->getX();
        ex(2)= endNode->getX();
        
        ey(1)= startNode->getY();
        ey(2)= endNode->getY();
        
        int start = 1+2*startNode->getEnumerate();
        int end = 1+2*endNode->getEnumerate();
        
        Topo << start << start +1 << end << end +1;
        calfem::bar2e(ex, ey, ep, Ke);
        calfem::assem(Topo, tempK, Ke);
        
    }
    
    
    //Find Bar freedofs
    freeDOFs.clear();
    for (int i=0; i<=model->nodeCount()-1; i++)
    {
        //Only using the first BC
        if (model->getNode(i)->getBCCount() >0)
        {
            if (model->getNode(i)->getBC(0)->getType() == 2)
            {
                freeDOFs.push_back(i*2+0);
            }
            if (model->getNode(i)->getBC(0)->getType() == 3)
            {
                freeDOFs.push_back(i*2+1);
            }
            if (model->getNode(i)->getBC(0)->getType() == 5)
            {
                freeDOFs.push_back(i*2+0);
                freeDOFs.push_back(i*2+1);
            }
        } else {
            freeDOFs.push_back(i*2+0);
            freeDOFs.push_back(i*2+1);
        }
    }
    
    //Reduce K-matrix
    Matrix KReduced;
    KReduced = 0.0;
    KReduced.resize(freeDOFs.size(), freeDOFs.size());
    
    //Reducing the stiffness matrix
    for (int i=0; i<freeDOFs.size(); i++)
    {
        for (int j=0; j<freeDOFs.size(); j++)
            KReduced(j+1,i+1)=tempK(freeDOFs[j]+1,freeDOFs[i]+1);
    }
    
    int matrixSize = sqrt(KReduced.size());
    
    SymmetricMatrix KSymm(matrixSize);
    KSymm << KReduced;
    
    DiagonalMatrix eigen(sqrt(KSymm.size()));
    EigenValues(KSymm, eigen);
    
    
    int degree=0;
    for (int i=1; i<=eigen.size(); i++)
    {
        if (eigen(i)<1e-8)
            degree++;
    }
    m=degree;
    return degree;
}



CCalfemBrain::CCalfemBrain(CFemModel* modelStorage)
{
    model = modelStorage;
}



void CCalfemBrain::getStiffnessMatrix()
{
    RowVector ex(2);
    RowVector ey(2);
    RowVector Topo(6);
    
    Matrix Ke(6,6); Ke=0.0;
    SymmetricBandMatrix tempK(model->getDOFcount(),model->getDOFcount());
    tempK=0.0;
    
    
    for (int i=0; i<=model->lineCount()-1; i++)
    {
        
        CFemNode* startNode = model->getNode(model->getLine(i)->getNode0()->getEnumerate());
        CFemNode* endNode = model->getNode(model->getLine(i)->getNode1()->getEnumerate());
        
        bool startNodeHinge = false;
        bool endNodeHinge = false;
        
        int start = 1+3*model->getLine(i)->getNode0()->getEnumerate();
        int end = 1+3*model->getLine(i)->getNode1()->getEnumerate();
        
        if (startNode->getBCCount()==0)
        {
            startNodeHinge = true;
        }
        else if  (startNode->getBC(0)->getType() == 1 || startNode->getBC(0)->getType() == 2 || startNode->getBC(0)->getType() == 3)
        {
            startNodeHinge = true;
        }
        
        if (endNode->getBCCount()==0)
        {
            endNodeHinge=true;
        }
        else if (endNode->getBC(0)->getType() == 1 || endNode->getBC(0)->getType() == 2 || endNode->getBC(0)->getType() == 3)
        {
            endNodeHinge = true;
        }
        
        if (!startNodeHinge && !endNodeHinge)
        {
            Topo << start << start+1<<start+2 << end << end+1 << end+2;
        } else if (startNodeHinge && endNodeHinge) {
            Topo << start << start+1<< model->getLine(i)->getStartDOF() << end << end+1 << model->getLine(i)->getEndDOF();
        } else if (startNodeHinge && !endNodeHinge) {
            Topo << start << start+1<<model->getLine(i)->getStartDOF() << end << end+1 << end+2;
        } else if (!startNodeHinge && endNodeHinge) {
            Topo << start << start+1<<start+2 << end << end+1 << model->getLine(i)->getEndDOF();
        }
        
        
        ex(1)= startNode->getX();
        ex(2)= endNode->getX();
        
        ey(1)= startNode->getY();
        ey(2)= endNode->getY();
        
        calfem::beam2e(ex, ey, ep, Ke);
        calfem::assem(Topo, tempK, Ke);
        
    }
    
    K=0.0;
    
    K=tempK;
    //cout << K;
    
    KReduced = 0.0;
    KReduced.resize(freeDOFs.size(), freeDOFs.size());
    //cout << "freedofs size: " <<freeDOFs.size();
    
    //Reducing the stiffness matrix
    for (int i=0; i<=freeDOFs.size()-1; i++)
    {
        for (int j=0; j<=freeDOFs.size()-1; j++)
            KReduced(j+1,i+1)=K(freeDOFs[j],freeDOFs[i]);
    }
    
    //cout << endl << endl << "HÄÄÄR:" << KReduced << endl <<endl;
    
}



void CCalfemBrain::getDOF()
{
    
    lockedDOFs.clear();
    freeDOFs.clear();
    rotationDOFs.clear();
    freeRotationsDOFAdress.clear();
    
    for (int i=0; i<=model->nodeCount()-1; i++)
    {
        //Only using the first BC
        if (model->getNode(i)->getBCCount() >0)
        {
            
            if ((int)model->getNode(i)->getBC(0)->getType() == 0)
            {
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(0));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(1));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(2));
            }
            
            if (model->getNode(i)->getBC(0)->getType() == 1)
            {
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(0));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(1));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(2));
            }
            
            if (model->getNode(i)->getBC(0)->getType() == 2)
            {
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(1));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(2));
            }
            if (model->getNode(i)->getBC(0)->getType() == 3)
            {
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(0));
                lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(2));
            }
        } else {
            lockedDOFs.push_back(model->getNode(i)->getDofs()->getDof(2));
        }
    }
    
    for (int i=3; i<=model->nodeCount()*3; i+=3)
    {
        rotationDOFs.push_back(i);
    }
    
    //Reversing the lockedDOFs array and showing free nodes
    for (int i=1; i<=(model->nodeCount()*3); i++)
        freeDOFs.push_back(i);
    
    for (int i=1; i<=lockedDOFs.size(); i++)
        freeDOFs.erase(freeDOFs.begin() + lockedDOFs[ lockedDOFs.size()-i ]-1);
    
    
    //Add dof for every line that is connected to a node
    int currentDOF=model->nodeCount()*3;
    for (int i=0; i<=model->lineCount()-1; i++)
    {
        CFemNode *startNode = model->getNode(model->getLine(i)->getNode0()->getEnumerate());
        CFemNode *endNode = model->getNode(model->getLine(i)->getNode1()->getEnumerate());
        
        model->getLine(i)->setStartDOF(0);
        model->getLine(i)->setEndDOF(0);
        
        if (startNode->getBCCount() == 0)
        {
            currentDOF++;
            freeDOFs.push_back(currentDOF);
            model->getLine(i)->setStartDOF(currentDOF);
        }
        else if (startNode->getBC(0)->getType() == 1 || startNode->getBC(0)->getType() == 2 || startNode->getBC(0)->getType() == 3)
        {
            currentDOF++;
            freeDOFs.push_back(currentDOF);
            model->getLine(i)->setStartDOF(currentDOF);
        }
        
        //Endnode
        if (endNode->getBCCount() == 0)
        {
            currentDOF++;
            freeDOFs.push_back(currentDOF);
            model->getLine(i)->setEndDOF(currentDOF);
        }
        else if (endNode->getBC(0)->getType() == 1 || endNode->getBC(0)->getType() == 2 || endNode->getBC(0)->getType() == 3)
        {
            currentDOF++;
            freeDOFs.push_back(currentDOF);
            model->getLine(i)->setEndDOF(currentDOF);
        }
        
    }
    model->setDOFcount(currentDOF);
    
    
    //for (int i=0; i<freeRotationsDOFAdress.size(); i++)
    //  cout << "Free Rotation DOF adress:" << freeRotationsDOFAdress[i] << endl;
    
    //for (int i=0; i<freeDOFs.size(); i++)
    //cout << "Free dof:" << freeDOFs[i] << endl;
    
    // for (int i=0; i<rotationDOFs.size(); i++)
    //   cout << "Rotation DOF:" << rotationDOFs[i] << endl;
    
}


void CCalfemBrain::setConstraints()
{
    //Forcestuff
    f.resize(model->getDOFcount());
    f = 0.0;
    
    
    for (int i=1; i <= model->nodeCount(); i++)
    {
        
        if (model->getNode(i-1)->getForceCount() >0)
        {
            
            f((i-1)*3+1)=-model->getNode(i-1)->getForce(0)->getCompX() * model->getNode(i-1)->getForce(0)->getMagnitude()/100;
            f((i-1)*3+2)=-model->getNode(i-1)->getForce(0)->getCompY() * model->getNode(i-1)->getForce(0)->getMagnitude()/100;
        }
    }
    
    fReduced.resize(freeDOFs.size());
    fReduced=0.0;
    
    
    for (int i=0; i<=freeDOFs.size()-1; i++)
        fReduced(i+1)=f(freeDOFs[i]);
    
}

bool CCalfemBrain::checkMechanim()
{
    bool status = true;
    int forceCount=0;
    bool lockedX = false;
    bool lockedY = false;
    int rotationBC = 0;
    bool checkMechanismArray[5];
    
    for (int i =0; i<5; i++)
        checkMechanismArray[i]=false;
    
    for (int i=0; i<=model->nodeCount()-1; i++)
    {
        int lineCount=0;
        int connectingNode=-1;
        //Loop over all lines to find how many connects to that node
        for (int j=0; j<=model->lineCount()-1; j++)
        {
            if (model->getLine(j)->getNode0()->getEnumerate() == i)
            {
                lineCount++;
                connectingNode = model->getLine(j)->getNode1()->getEnumerate();
            }
            if (model->getLine(j)->getNode1()->getEnumerate() == i)
            {
                lineCount++;
                connectingNode = model->getLine(j)->getNode0()->getEnumerate();
            }
            
        }
        
        
        //If nodes without connections mechanism
        if (lineCount == 0)
        {
            status=false;
            checkMechanismArray[0]=true;
            
        }
        
        forceCount += model->getNode(i)->getForceCount();
        
        //Make sure its locked in X and Y direction:
        if (model->getNode(i)->getBCCount() > 0)
        {
            if (model->getNode(i)->getBC(0)->getType() == 0)
            {
                lockedX = true;
                lockedY = true;
                rotationBC += 2;
            } else if (model->getNode(i)->getBC(0)->getType() == 1) {
                lockedX = true;
                lockedY = true;
                rotationBC++;
            } else if (model->getNode(i)->getBC(0)->getType() == 2) {
                lockedY = true;
                rotationBC++;
            } else if (model->getNode(i)->getBC(0)->getType() == 3) {
                lockedX = true;
                rotationBC++;
            }
        }
    }
    
    if (forceCount == 0)
        status=false;
    
    if (rotationBC<2)
    {
        status=false;
        checkMechanismArray[1]=true;
    }
    
    if (!lockedX)
        checkMechanismArray[2]=true;
    
    if (!lockedY)
        checkMechanismArray[3]=true;
    
    if (forceCount == 0)
        checkMechanismArray[4]=true;
    
    if (lockedX != true || lockedY != true)
        status=false;
    
    if (lockedDOFs.size()<1)
        status=false;
    
    model->setCheckModel(checkMechanismArray);
    return status;
}

bool CCalfemBrain::staticAnalysis()
{
    //Static analysis
    
    int matrixSize = sqrt(KReduced.size());
    
    SymmetricMatrix KSymm(matrixSize);
    KSymm << KReduced;
    
    
    DiagonalMatrix eigen(matrixSize);
    EigenValues(KSymm, eigen);
    
    
    int degree=0;
    for (int i=1; i<=eigen.size(); i++)
    {
        if (eigen(i)<1e-8)
            degree++;
    }
    
    
    if (degree>0)
    {
        DiagonalMatrix lowestEigen(matrixSize);
        //cout << "Eigenvalues: " << eigen;
        lowestEigen = eigen(1);
        
        Matrix KMinusEigen(matrixSize,matrixSize);
        KMinusEigen = KReduced - lowestEigen;
        
        ColumnVector aModalReduced(matrixSize);
        
        DiagonalMatrix D2;
        Matrix U, V;
        U = 0.0;
        V = 0.0;
        D2 = 0.0;
        
        SVD(KMinusEigen, D2, U, V);
        aModalReduced = V.column(matrixSize);
        
        //Fill out the a vector with all DOFs
        ColumnVector aModal(model->getDOFcount());
        aModal = 0.0;
        
        for (int i=0; i<=freeDOFs.size()-1; i++)
            aModal(freeDOFs[i])=aModalReduced(i+1);
        
        RowVector exLine(2),  eyLine(2);
        ColumnVector aModalLine(6);
        Matrix edi;
        double distanceBetweenNods_x, distanceBetweenNods_y;
        int res = 20;
        
        for (int lineID = 0; lineID<model->lineCount(); lineID++)
        {
            
            int startRotDOF = model->getLine(lineID)->getNode0()->getEnumerate()*3+3;
            int endRotDOF = model->getLine(lineID)->getNode1()->getEnumerate()*3+3;
            
            if (model->getLine(lineID)->getStartDOF() > 0)
                startRotDOF = model->getLine(lineID)->getStartDOF();
            
            if (model->getLine(lineID)->getEndDOF() > 0)
                endRotDOF = model->getLine(lineID)->getEndDOF();
            
            aModalLine(1) = aModal(model->getLine(lineID)->getNode0()->getEnumerate()*3+1);
            aModalLine(2) = aModal(model->getLine(lineID)->getNode0()->getEnumerate()*3+2);
            aModalLine(3) = aModal(startRotDOF);
            
            aModalLine(4) = aModal(model->getLine(lineID)->getNode1()->getEnumerate()*3+1);
            aModalLine(5) = aModal(model->getLine(lineID)->getNode1()->getEnumerate()*3+2);
            aModalLine(6) = aModal(endRotDOF);
            
            exLine(1)=model->getLine(lineID)->getNode0()->getX();
            exLine(2)=model->getLine(lineID)->getNode1()->getX();
            eyLine(1)=model->getLine(lineID)->getNode0()->getY();
            eyLine(2)=model->getLine(lineID)->getNode1()->getY();
            
            
            distanceBetweenNods_x=(exLine(2)-exLine(1))/(res-1);
            distanceBetweenNods_y=(eyLine(2)-eyLine(1))/(res-1);
            
            edi = 0.0;
            calfem::beam2s(exLine, eyLine, edi, aModalLine, res);
            
            double dx[res], dy[res], dyEnd[res], dxEnd[res];
            for (int i=0;i<res;i++)
            {
                dx[i]=exLine(1) + distanceBetweenNods_x*i + edi(i+1,1)*50;
                dy[i]=eyLine(1) + distanceBetweenNods_y*i + edi(i+1,2)*50;
                dxEnd[i]=exLine(1) + distanceBetweenNods_x*i - edi(i+1,1)*50;
                dyEnd[i]=eyLine(1) + distanceBetweenNods_y*i - edi(i+1,2)*50;
            }
            
            //dx[0] = exLine(1) + aModalLine(1)*100;
            //dx[1] = exLine(2) + aModalLine(4)*100;
            //dy[0] = eyLine(1) + aModalLine(2)*100;
            //dy[1] = eyLine(2) + aModalLine(5)*100;
            
            model->getLine(lineID)->getResults()->setMekanismStart(dx, dy, true);
            model->getLine(lineID)->getResults()->setMekanismStart(dxEnd, dyEnd, false);
            
            
        }
    }
    
    
    //cout << "Mechanism degrees: " << degree << endl;
    model->setDegreeOfMechanism(degree);
    
    if (degree==0)
    {
        return true;
    } else {
        return false;
    }
    
}

bool CCalfemBrain::femCalculations(bool geometryUpdated, bool doStaticAnalysis)
{
    try
    {
        //ep=0.0;
        ep.resize(4);
        ep(1) = 2.1e11; //   E
        ep(2) = 764e-6; //   A
        ep(3) = 0.801e-6; // I
        ep(4) = 20e3; //     W
        
        model->enumerateDofs(1);
        model->enumerateNodes(0);
        model->enumerateLines(0);
        model->clearResults();
        
        getDOF();
        bool checkMechanism = checkMechanim();
        if (checkMechanism)
        {
            
            if (geometryUpdated || K.size()==0)
            {
                getStiffnessMatrix();
            }
            
            if (doStaticAnalysis || model->getDegreeOfMechanism() == -1)
                staticAnalysisOK = staticAnalysis();
            
            
            if (staticAnalysisOK)
            {
                
                setConstraints();
                
                CroutMatrix kReducedCrout;
                kReducedCrout.cleanup();
                
                kReducedCrout = KReduced;
                ColumnVector aReduced = kReducedCrout.i() * fReduced;
                
                
                //Fill out the a vector with all DOFs
                ColumnVector a(model->getDOFcount());
                a = 0.0;
                
                for (int i=0; i<=freeDOFs.size()-1; i++)
                    a(freeDOFs[i])=aReduced(i+1);
                
                
                f.cleanup();
                f=0.0;
                f=K*a;
                
                //cout << "K: " << K;
                //cout << "f:" << endl << f;
                
                int res = 20;
                Matrix edi(2,res);
                ColumnVector eci(res);
                Matrix es;
                ColumnVector mForce(2);
                double nForce;
                nForce=0.0;
                
                RowVector exLine(2), eyLine(2);
                exLine = 0.0;
                eyLine = 0.0;
                
                double distanceBetweenNods_x, distanceBetweenNods_y;
                ColumnVector aLine(6), fLine(6);
                double maxDisp=0;
                double maxMoment=0;
                double maxTension=0;
                
                for (int lineID = 0; lineID<model->lineCount(); lineID++)
                {
                    
                    int startRotDOF = model->getLine(lineID)->getNode0()->getEnumerate()*3+3;
                    int endRotDOF = model->getLine(lineID)->getNode1()->getEnumerate()*3+3;
                    
                    if (model->getLine(lineID)->getStartDOF() > 0)
                        startRotDOF = model->getLine(lineID)->getStartDOF();
                    
                    if (model->getLine(lineID)->getEndDOF() > 0)
                        endRotDOF = model->getLine(lineID)->getEndDOF();
                    
                    aLine(1) = a(model->getLine(lineID)->getNode0()->getEnumerate()*3+1);
                    aLine(2) = a(model->getLine(lineID)->getNode0()->getEnumerate()*3+2);
                    aLine(3) = a(startRotDOF);
                    
                    aLine(4) = a(model->getLine(lineID)->getNode1()->getEnumerate()*3+1);
                    aLine(5) = a(model->getLine(lineID)->getNode1()->getEnumerate()*3+2);
                    aLine(6) = a(endRotDOF);
                    
                    
                    fLine(1) = f(model->getLine(lineID)->getNode0()->getEnumerate()*3+1);
                    fLine(2) = f(model->getLine(lineID)->getNode0()->getEnumerate()*3+2);
                    fLine(3) = f(startRotDOF);
                    
                    fLine(4) = f(model->getLine(lineID)->getNode1()->getEnumerate()*3+1);
                    fLine(5) = f(model->getLine(lineID)->getNode1()->getEnumerate()*3+2);
                    fLine(6) = f(endRotDOF);
                    
                    exLine(1)=model->getLine(lineID)->getNode0()->getX();
                    exLine(2)=model->getLine(lineID)->getNode1()->getX();
                    eyLine(1)=model->getLine(lineID)->getNode0()->getY();
                    eyLine(2)=model->getLine(lineID)->getNode1()->getY();
                    
                    
                    distanceBetweenNods_x=(exLine(2)-exLine(1))/(res-1);
                    distanceBetweenNods_y=(eyLine(2)-eyLine(1))/(res-1);
                    
                    calfem::beam2s(exLine, eyLine, ep, edi, eci, aLine, fLine , res, es, mForce,nForce);
                    
                    double dx[res], dy[res], m[2],s[2];
                    for (int i=0;i<res;i++)
                    {
                        dx[i]=exLine(1) + distanceBetweenNods_x*i + edi(i+1,1)*model->getScale();
                        dy[i]=eyLine(1) + distanceBetweenNods_y*i + edi(i+1,2)*model->getScale();
                        
                        
                        if (abs(sqrt(pow(edi(i+1,1),2)+pow(edi(i+1,2),2))) > maxDisp)
                            maxDisp = abs(sqrt(pow(edi(i+1,1),2)+pow(edi(i+1,2),2)));
                        
                    }
                    
                    m[0]=-mForce(1);
                    m[1]=-mForce(2);
                    
                    if (abs(m[0])>maxMoment)
                        maxMoment=abs(m[0]);
                    if (abs(m[1])>maxMoment)
                        maxMoment=abs(m[1]);
                    
                    s[0]=nForce*ep(2)+m[0]/ep(4);
                    s[1]=nForce*ep(2)+m[1]/ep(4);
                    
                    
                    if (abs(s[0])>maxTension)
                        maxTension=abs(s[0]);
                    if (abs(s[1])>maxTension)
                        maxTension=abs(s[1]);
                    
                    //nForce = f(model->getLine(lineID)->getNode1()->getEnumerate()*3+2);
                    model->getLine(lineID)->getResults()->setResults(dx,dy,nForce,m,s);
                    //cout << "M0: " << m[0] << "M1: " << m[1] << endl;
                    
                }
                
                model->setMaxMoment(maxMoment);
                model->setMaxDisp(maxDisp);
                model->setMaxTension(maxTension);
                
                //if (maxDisp>5000)
                //  checkMechanism=false;
                
            } else {
                checkMechanism = false;
            }
            
        }
        
        
        return checkMechanism;
    }
    // catch exceptions thrown by my programs
    catch(BaseException) { cout << BaseException::what() << endl; }
    // catch exceptions thrown by other people's programs
    catch(...) { cout << "exception caught in main program" << endl; }
    
    return false;
}

