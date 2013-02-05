//
//  GenerateXMLData.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/30/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "GenerateXMLData.h"
#import "GeometryView.h"


@implementation GenerateXMLData

+(NSData *)getDataModel
{
    NSMutableString *XMLString = [[NSMutableString alloc] initWithFormat:@""];
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    
    [XMLString appendFormat:@"<model>\n"];
    for (int i=0; i<femModel->nodeCount();i++)
    {
        [XMLString appendFormat:@"  <node x=\"%f\" y=\"%f\">\n",femModel->getNode(i)->getX(),femModel->getNode(i)->getY()];
        
        if (femModel->getNode(i)->getBCCount()>0)
        {
            [XMLString appendFormat:@"  <bc nodeID=\"%d\" type=\"%d\">\n",i,femModel->getNode(i)->getBC(0)->getType()];
        }
        
        if (femModel->getNode(i)->getForceCount() > 0)
        {
            [XMLString appendFormat:@"  <force nodeID=\"%d\" magnitude=\"%f\" xcomp=\"%f\" ycomp=\"%f\">\n",i,femModel->getNode(i)->getForce(0)->getMagnitude(),femModel->getNode(i)->getForce(0)->getCompX(),femModel->getNode(i)->getForce(0)->getCompY()];
        }
    }
    
    for (int i=0; i<femModel->lineCount();i++)
    {
        [XMLString appendFormat:@"  <line start=\"%d\" end=\"%d\">\n",femModel->getLine(i)->getNode0()->getEnumerate(),femModel->getLine(i)->getNode1()->getEnumerate()];
    }
    
    [XMLString appendFormat:@"</model>\n"];
    
    return [XMLString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
