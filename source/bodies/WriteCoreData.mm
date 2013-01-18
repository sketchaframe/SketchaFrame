//
//  WriteCoreData.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "WriteCoreData.h"


@implementation WriteCoreData
@synthesize terminateDatabase=_terminateDatabase;

+(void)readModel:(Models *) model:(UIManagedDocument *)document
{
    GeometryView *myGeo = [GeometryView sharedInstance];
    CFemModelPtr femModel = [myGeo getFemModel];
    
    if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {}];
    }

    
    femModel->clear();
    
    NSFetchRequest *requestNodes = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
    requestNodes.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    requestNodes.sortDescriptors = [NSArray arrayWithObject:sortdescriptor];
    
    NSArray *nodesInModel = [document.managedObjectContext executeFetchRequest:requestNodes error:nil];
    
    for (int i=0; i<[nodesInModel count]; i++) {
        
        Nodes *myNode = [nodesInModel objectAtIndex:i];
        femModel->addNode([myNode.x doubleValue], [myNode.y doubleValue]);
    }
    
    femModel->setName([model.name UTF8String]);

    NSFetchRequest *requestLines = [NSFetchRequest fetchRequestWithEntityName:@"Lines"];
    requestLines.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorLines = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
    requestLines.sortDescriptors = [NSArray arrayWithObject:sortdescriptorLines];
    
    NSArray *linesInModel = [document.managedObjectContext executeFetchRequest:requestLines error:nil];
    
    for (int i=0; i<[linesInModel count]; i++) {
        
        Lines *myLine = [linesInModel objectAtIndex:i];
        femModel->addLine([myLine.start intValue] , [myLine.end intValue]);
    }
    
    
    
    
    NSFetchRequest *requestForces = [NSFetchRequest fetchRequestWithEntityName:@"Forces"];
    requestForces.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorForces = [NSSortDescriptor sortDescriptorWithKey:@"node" ascending:YES];
    requestForces.sortDescriptors = [NSArray arrayWithObject:sortdescriptorForces];
    
    NSArray *forcesInModel = [document.managedObjectContext executeFetchRequest:requestForces error:nil];
    
    for (int i=0; i<[forcesInModel count]; i++) {
        
        Forces *myForce = [forcesInModel objectAtIndex:i];
        femModel->addForce([myForce.node intValue], [myForce.magnitude doubleValue], [myForce.xcomp doubleValue], [myForce.ycomp doubleValue]);
    }
    
    NSFetchRequest *requestBC = [NSFetchRequest fetchRequestWithEntityName:@"BoundaryConditions"];
    requestBC.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorBC = [NSSortDescriptor sortDescriptorWithKey:@"node" ascending:YES];
    requestBC.sortDescriptors = [NSArray arrayWithObject:sortdescriptorBC];
    
    NSArray *bcInModel = [document.managedObjectContext executeFetchRequest:requestBC error:nil];
    
    for (int i=0; i<[bcInModel count]; i++) {
        
        BoundaryConditions *myBC = [bcInModel objectAtIndex:i];
        femModel->addBC([myBC.node intValue], [myBC.type intValue]);
    }

}



+(void)saveModelToCore:(UIManagedDocument *)document {

    GeometryView *myGeo = [GeometryView sharedInstance];
    CFemModelPtr femModel;
    femModel = [myGeo getFemModel];
    
    
    NSString *modelName;
    if (femModel->getName() == "") 
    {
        modelName = @"Unnamed";
    } else {
        modelName = [NSString stringWithCString:femModel->getName().c_str() 
                                  encoding:[NSString defaultCStringEncoding]];
    }

    
    NSFetchRequest *requestModels = [NSFetchRequest fetchRequestWithEntityName:@"Models"];
    requestModels.predicate = [NSPredicate predicateWithFormat:@"name = %@", modelName];
    NSSortDescriptor *sortdescriptorModels = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    requestModels.sortDescriptors = [NSArray arrayWithObject:sortdescriptorModels];
    
    NSArray *modelList = [document.managedObjectContext executeFetchRequest:requestModels error:nil];
    Models *model = [modelList lastObject];
    
    if ([modelList count] > 0) 
    {
        [document.managedObjectContext deleteObject:model];
    }
    
    //Add new model
    Models *models = [NSEntityDescription insertNewObjectForEntityForName:@"Models" inManagedObjectContext:document.managedObjectContext];
    models.name = modelName;
    models.date = [NSDate date];
    
    for (int i=0; i<femModel->nodeCount(); i++) {
        Nodes *nodes = [NSEntityDescription insertNewObjectForEntityForName:@"Nodes" inManagedObjectContext:document.managedObjectContext];
        nodes.id = [NSNumber numberWithInt:i];
        nodes.x = [NSNumber numberWithDouble: femModel->getNode(i)->getX()];
        nodes.y = [NSNumber numberWithDouble: femModel->getNode(i)->getY()];
        nodes.model = models;
    }
    
    for (int i=0; i<femModel->lineCount(); i++) {
        Lines *lines = [NSEntityDescription insertNewObjectForEntityForName:@"Lines" inManagedObjectContext:document.managedObjectContext];
        lines.start = [NSNumber numberWithInt: femModel->getLine(i)->getNode0()->getEnumerate()];
        lines.end = [NSNumber numberWithInt: femModel->getLine(i)->getNode1()->getEnumerate()];
        lines.model = models;
    }
    
    for (int i=0; i<femModel->nodeCount(); i++) {
        if (femModel->getNode(i)->getBCCount() > 0) {
            BoundaryConditions *bc = [NSEntityDescription insertNewObjectForEntityForName:@"BoundaryConditions" inManagedObjectContext:document.managedObjectContext];
            bc.node = [NSNumber numberWithInt:i];
            bc.type = [NSNumber numberWithInt: femModel->getNode(i)->getBC(0)->getType()];
            bc.model = models;
        }
    }
    
    for (int i=0; i<femModel->nodeCount(); i++) {
        if (femModel->getNode(i)->getForceCount() > 0) {
            Forces *forces = [NSEntityDescription insertNewObjectForEntityForName:@"Forces" inManagedObjectContext:document.managedObjectContext];
            forces.node = [NSNumber numberWithInt:i];
            forces.xcomp = [NSNumber numberWithDouble:femModel->getNode(i)->getForce(0)->getCompX()];
            forces.ycomp = [NSNumber numberWithDouble:femModel->getNode(i)->getForce(0)->getCompY()]; 
            forces.magnitude = [NSNumber numberWithDouble:femModel->getNode(i)->getForce(0)->getMagnitude()]; 
            forces.model = models;
        }
    }
    
    
    
}

+(void)readExample:(int) exampleID
{
    GeometryView *myGeo = [GeometryView sharedInstance];
    CFemModelPtr femModel = [myGeo getFemModel];
    
    femModel->clear();
    
    if (exampleID==0)
    {
        //Frame
        femModel->addNode(130, 583);
        femModel->addNode(130, 973);
        femModel->addNode(650, 973);
        femModel->addNode(650, 583);
        femModel->addNode(390, 973);
        femModel->addLine(0,1);
        femModel->addLine(2,3);
        femModel->addLine(1,4);
        femModel->addLine(4,2);
        femModel->addBC(0, 1);
        femModel->addBC(1, 4);
        femModel->addBC(2, 4);
        femModel->addBC(3, 1);
        femModel->addBC(4, 4);
        femModel->addForce(4 ,130,0,1);
    }
    
    if (exampleID==1)
    {
        
        //FEM assignment
        femModel->addNode(130, 973);
        femModel->addNode(260, 973);
        femModel->addNode(390, 973);
        femModel->addNode(520, 973);
        femModel->addNode(650, 843);
        femModel->addNode(130, 843);
        femModel->addNode(260, 843);
        femModel->addNode(390, 843);
        femModel->addNode(520, 843);
        femModel->addLine(0,1);
        femModel->addLine(1,2);
        femModel->addLine(2,3);
        femModel->addLine(3,4);
        femModel->addLine(5,6);
        femModel->addLine(6,7);
        femModel->addLine(7,8);
        femModel->addLine(8,4);
        femModel->addLine(1,6);
        femModel->addLine(1,7);
        femModel->addLine(7,2);
        femModel->addLine(2,8);
        femModel->addLine(8,3);
        femModel->addLine(6,0);
        femModel->addBC(0, 1);
        femModel->addForce(4 ,130,0,1);
        femModel->addBC(5, 1);
    }
    
    if (exampleID == 2)
    {
        //Big frame
        femModel->addNode(130, 518);
        femModel->addNode(130, 648);
        femModel->addNode(130, 778);
        femModel->addNode(130, 908);
        femModel->addNode(130, 1038);
        femModel->addNode(260, 1038);
        femModel->addNode(390, 1038);
        femModel->addNode(520, 1038);
        femModel->addNode(260, 908);
        femModel->addNode(260, 778);
        femModel->addNode(260, 648);
        femModel->addNode(260, 518);
        femModel->addNode(390, 908);
        femModel->addNode(390, 778);
        femModel->addNode(390, 648);
        femModel->addNode(390, 518);
        femModel->addNode(519, 901.5);
        femModel->addNode(520, 778);
        femModel->addNode(520, 648);
        femModel->addNode(520, 518);
        femModel->addLine(0,1);
        femModel->addLine(0,10);
        femModel->addLine(1,9);
        femModel->addLine(1,2);
        femModel->addLine(1,10);
        femModel->addLine(2,3);
        femModel->addLine(2,9);
        femModel->addLine(2,8);
        femModel->addLine(3,4);
        femModel->addLine(3,8);
        femModel->addLine(3,5);
        femModel->addLine(4,5);
        femModel->addLine(5,6);
        femModel->addLine(5,8);
        femModel->addLine(6,12);
        femModel->addLine(6,7);
        femModel->addLine(7,16);
        femModel->addLine(8,12);
        femModel->addLine(8,9);
        femModel->addLine(9,13);
        femModel->addLine(9,10);
        femModel->addLine(10,14);
        femModel->addLine(10,11);
        femModel->addLine(11,1);
        femModel->addLine(12,13);
        femModel->addLine(12,16);
        femModel->addLine(13,14);
        femModel->addLine(13,17);
        femModel->addLine(14,15);
        femModel->addLine(14,18);
        femModel->addLine(16,17);
        femModel->addLine(17,18);
        femModel->addLine(18,19);
        femModel->addBC(0, 1);
        femModel->addForce(7 ,183.848,0.707107,0.707107);
        femModel->addBC(11, 1);
        femModel->addBC(15, 1);
        femModel->addBC(19, 1);
    }
    
    if (exampleID==3)
    {
        //Bridge
        femModel->addNode(65, 648);
        femModel->addNode(715, 631.5);
        femModel->addNode(65, 713);
        femModel->addNode(130, 778);
        femModel->addNode(130, 713);
        femModel->addNode(195, 843);
        femModel->addNode(195, 778);
        femModel->addNode(325, 908);
        femModel->addNode(325, 843);
        femModel->addNode(650, 713);
        femModel->addNode(650, 778);
        femModel->addNode(585, 778);
        femModel->addNode(585, 843);
        femModel->addNode(455, 843);
        femModel->addNode(455, 908);
        femModel->addNode(715, 713);
        femModel->addNode(390, 843);
        femModel->addNode(388.5, 908);
        femModel->addLine(0,2);
        femModel->addLine(2,3);
        femModel->addLine(0,4);
        femModel->addLine(3,5);
        femModel->addLine(4,6);
        femModel->addLine(5,7);
        femModel->addLine(6,8);
        femModel->addLine(1,9);
        femModel->addLine(10,12);
        femModel->addLine(11,13);
        femModel->addLine(12,14);
        femModel->addLine(0,3);
        femModel->addLine(3,6);
        femModel->addLine(6,7);
        femModel->addLine(13,12);
        femModel->addLine(2,4);
        femModel->addLine(4,5);
        femModel->addLine(5,8);
        femModel->addLine(14,11);
        femModel->addLine(11,10);
        femModel->addLine(1,15);
        femModel->addLine(15,10);
        femModel->addLine(9,11);
        femModel->addLine(1,10);
        femModel->addLine(15,9);
        femModel->addLine(9,12);
        femModel->addLine(8,16);
        femModel->addLine(16,13);
        femModel->addLine(7,17);
        femModel->addLine(17,14);
        femModel->addLine(13,17);
        femModel->addLine(17,8);
        femModel->addLine(7,16);
        femModel->addLine(16,14);
        femModel->addLine(8,7);
        femModel->addLine(13,14);
        femModel->addLine(16,17);
        femModel->addLine(6,5);
        femModel->addLine(4,3);
        femModel->addLine(9,10);
        femModel->addLine(11,12);
        femModel->addBC(0, 1);
        femModel->addBC(1, 1);
        femModel->addForce(17 ,211.005,0.00710883,0.999975);

    }
    
    if (exampleID == 4)
    {
        
        //Spring
        femModel->addNode(325, 778);
        femModel->addNode(325, 843);
        femModel->addNode(260, 843);
        femModel->addNode(260, 713);
        femModel->addNode(390, 713);
        femModel->addNode(386, 908);
        femModel->addNode(195, 908);
        femModel->addNode(195, 648);
        femModel->addNode(455, 648);
        femModel->addLine(0,1);
        femModel->addLine(1,2);
        femModel->addLine(2,3);
        femModel->addLine(3,4);
        femModel->addLine(4,5);
        femModel->addLine(5,6);
        femModel->addLine(6,7);
        femModel->addLine(7,8);
        femModel->addBC(0, 0);
        femModel->addBC(1, 4);
        femModel->addBC(2, 4);
        femModel->addBC(3, 4);
        femModel->addBC(4, 4);
        femModel->addBC(5, 4);
        femModel->addBC(6, 4);
        femModel->addBC(7, 4);
        femModel->addForce(8 ,130,0,1);
    }
    
    femModel->enumerateLines(0);
    femModel->enumerateDofs(0);
}

@end
