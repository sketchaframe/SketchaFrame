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

@end
