//
//  Fem.h
//  TestModel
//
//  Created by Jonas Lindemann on 2012-06-23.
//  Copyright (c) 2012 Zoom Media. All rights reserved.
//

#ifndef TestModel_Fem_h
#define TestModel_Fem_h

#include "Geom.h"
#include "Vec2d.h"
#include "newmat.h"
#include "newmatio.h"

SmartPointer(CDofs);

class CDofs : public CBase {
private:
    int m_dofs[3];
public:
    CDofs();
    
    int getDof(int idx);
    int getDofCount();
    
    int enumerate(int startIdx);
};



SmartPointer(CFemNode);

class CForce;
class CBoundaryCondition;

class CFemNode : public CNode {
private:
    CDofsPtr m_dofs;
    std::vector<CForce*> m_nodeForces;
    std::vector<CBoundaryCondition*> m_nodeBCs;
    
public:
    CFemNode(double x = 0, double y = 0);
    virtual ~CFemNode();
    
    void addForce(CForce* force);
    void removeForce(CForce* force);
    void clearForces();
    int getForceCount();
    CForce* getForce(int idx);
    
    void addBC(CBoundaryCondition* bc);
    void removeBC(CBoundaryCondition* bc);
    void clearBCs();
    int getBCCount();
    CBoundaryCondition* getBC(int idx);
    
    CDofs* getDofs();
    
};

SmartPointer(CForce);

class CForce : public CBase {
private:
    CVec2d m_direction;
    double m_magnitude;
    CFemNode* m_node;
public:
    CForce(double magnitude, double vx, double vy);
    
    void setNode(CFemNode* node);
    void clearNode();
    
    double getMagnitude();
    double getCompX();
    double getCompY();
    void setForceComponents(double compX,double compY);
    
    CFemNode* getNode();
};

SmartPointer(CBoundaryCondition);

class CBoundaryCondition : public CBase {
public:
    //enum TBCType {BT_ROT, BT_XY, BT_X, BT_Y,  BT_M};
private:
    
    //  -o- BT_ROT
    //  ///
    
    //  o
    // / \ BT_XY
    
    //  o
    // / \
    // o o BT_Y
    
    // o
    //   >o BT_X
    // o
    
    // Lock moment DOF
    // BT_M
    
    CFemNode* m_node;
    
    int m_bcType;
public:
    CBoundaryCondition(int type);
    
    void setNode(CFemNode* node);
    void clearNode();
    
    int getType();
    
    CFemNode* getNode();
};

class CCalfemBrain;
class CRedundancyBrain;

SmartPointer(CFemModel);

class CFemModel : public CBase {
private:
    std::vector<CFemNodePtr> m_nodes;
    std::vector<CLinePtr> m_lines;
    std::vector<CForcePtr> m_forces;
    std::vector<CBoundaryConditionPtr> m_bcs;
    double m_minX;
    double m_maxX;
    double m_minY;
    double m_maxY;
    double m_scale;
    double m_momentscale;
    string m_name;
    bool m_drawModes[7];
    
    double m_maxDisp;
    double m_maxMoment;
    double m_maxTension;
    
    int m_DOFcount;
    int m_degreeMechanism;
    
    bool m_checkModel[5];
    
    CCalfemBrain* calfemBrain;
    CRedundancyBrain* redundancyBrain;
    
public:
    CFemModel();
    virtual ~CFemModel();
    
    void addNode(double x, double y);
    void removeNode(double x, double y);
    void removeLine(double x, double y);
    void removeOneLine(double x, double y);
    void addLine(int idx0, int idx1);
    
    void addForce(int nodeIdx, double magnitude, double vx, double vy);
    void addBC(int nodeIdx, int type);
    
    void printNodes();
    void printLines();
    void print();
    
    void clearNodes();
    void clearLines();
    void clearForces();
    void clearResults();
    void clear();
    
    int nodeCount();
    int lineCount();
    int forceCount();
    int getBCCount();
    
    CFemNode* getNode(int idx);
    CLine* getLine(int idx);
    CForce* getForce(int idx);
    
    void setCord(double x, double y, int idn);
    void setBC(CBoundaryCondition* type, int nodeID, int bcID);
    void setForce(double x, double y, int idn, int forceID);
    
    int getForceX(int idn, int forceID);
    int getForceY(int idn, int ForceID);
    
    double getScale();
    void setScale(double maxDisp);
    
    double getMomentScale();
    void setMomentScale(double maxMoment);
    
    void setDrawMode(bool def, bool mom, bool nor, bool grid, bool ortho, bool tension, bool redundancy);
    bool drawDeformation();
    bool drawMoment();
    bool drawNormal();
    bool showGrid();
    bool orthoMode();
    bool tensionMode();
    bool drawRedundancy();
    
    
    string getName();
    void setName(string name);
    
    int enumerateNodes(int idx);
    int enumerateLines(int idx);
    int enumerateDofs(int idx);
    int findAction(double x, double y, int distSetting, int &type);
    int findNode(double x, double y, int distSetting);
    int findLine(double x, double y, int distSetting);
    int findLineExtended(double x, double y, int distSetting, double &lineX, double &lineY);
    bool foundGrid(double x,double y,double snapDistance,double &gridX,double &gridY);
    bool lineExists(int start, int end);
    void updateBounds();
    
    double getMaxDisp();
    void setMaxDisp(double maxDisp);
    
    double getMaxMoment();
    void setMaxMoment(double maxMoment);
    
    double getMaxTension();
    void setMaxTension(double maxTension);
    
    bool calculate(bool geometryUpdated, bool doStaticAnalysis);
    CCalfemBrain* getCalfemBrain(CFemModel *model);
    
    
    void calculateRedundancy();
    CRedundancyBrain* getRedundancyBrain(CFemModel *model);
    
    int getDOFcount();
    void setDOFcount(int count);
    
    int getDegreeOfMechanism();
    void setDegreeOfMechanism(int degree);
    
    void setCheckModel(bool checkModel[5]);
    bool checkUnconnectedNodes();
    bool checkFreeRotation();
    bool checkFreeX();
    bool checkFreeY();
    bool checkNoForceApplied();
};

SmartPointer(CRedundancyBrain);

class CRedundancyBrain : public CBase {
private:
    CFemModel *model;
    Matrix H;
    Matrix PSI;
    int m;
    int s;
    RowVector ep;
    vector<int> freeDOFs;
public:
    CRedundancyBrain(CFemModel *model);
    void getPSI();
    void getHDOF(int nodeID, bool xDirection, int &hDOF, bool &free);
    int getLockedHDOFCount();
    void getEquilibriumMatrix();
    
    void calculateRedundancy();
    int getm();
    int gets();
    int getBarMekanism();
    
};


SmartPointer(CCalfemBrain);

class CCalfemBrain : public CBase {
private:
    double ex, ey;
    Matrix KReduced;
    Matrix K;
    ColumnVector f;
    ColumnVector fReduced;
    vector<int> lockedDOFs;
    vector<int> freeDOFs;
    vector<int> rotationDOFs;
    vector<int> freeRotationsDOFAdress;
    RowVector ep;
    bool staticAnalysisOK;
    CFemModel *model;
    
public:
    CCalfemBrain(CFemModel* model);
    
    bool femCalculations(bool geometryUpdated, bool doStaticAnalysis);
    bool checkMechanim();
    bool staticAnalysis();
    void getDOF();
    void getStiffnessMatrix();
    
    void setConstraints();
    void getForce(RowVector &f);
    
};

#endif
