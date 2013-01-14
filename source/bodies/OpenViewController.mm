//
//  OpenViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "OpenViewController.h"

@implementation OpenViewController

@synthesize model=model;
@synthesize modelDatabase=modelDatabase;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GeometryView *myGeo = [GeometryView sharedInstance];
    CFemModelPtr femModel = [myGeo getFemModel];
    
    femModel->clear();
    
    NSFetchRequest *requestNodes = [NSFetchRequest fetchRequestWithEntityName:@"Nodes"];
    requestNodes.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    requestNodes.sortDescriptors = [NSArray arrayWithObject:sortdescriptor];
    
    NSArray *nodesInModel = [modelDatabase.managedObjectContext executeFetchRequest:requestNodes error:nil];
    
    for (int i=0; i<[nodesInModel count]; i++) {
        
        Nodes *myNode = [nodesInModel objectAtIndex:i];
        femModel->addNode([myNode.x doubleValue], [myNode.y doubleValue]);
    }
    
    
    NSFetchRequest *requestLines = [NSFetchRequest fetchRequestWithEntityName:@"Lines"];
    requestLines.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorLines = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
    requestLines.sortDescriptors = [NSArray arrayWithObject:sortdescriptorLines];
    
    NSArray *linesInModel = [modelDatabase.managedObjectContext executeFetchRequest:requestLines error:nil];
    
    for (int i=0; i<[linesInModel count]; i++) {
        
        Lines *myLine = [linesInModel objectAtIndex:i];
        femModel->addLine([myLine.start intValue] , [myLine.end intValue]);
    }
    
    
    
    
    NSFetchRequest *requestForces = [NSFetchRequest fetchRequestWithEntityName:@"Forces"];
    requestForces.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorForces = [NSSortDescriptor sortDescriptorWithKey:@"node" ascending:YES];
    requestForces.sortDescriptors = [NSArray arrayWithObject:sortdescriptorForces];
    
    NSArray *forcesInModel = [modelDatabase.managedObjectContext executeFetchRequest:requestForces error:nil];
    
    for (int i=0; i<[forcesInModel count]; i++) {
        
        Forces *myForce = [forcesInModel objectAtIndex:i];
        femModel->addForce([myForce.node intValue], [myForce.magnitude doubleValue], [myForce.xcomp doubleValue], [myForce.ycomp doubleValue]);
    }
    
    NSFetchRequest *requestBC = [NSFetchRequest fetchRequestWithEntityName:@"BoundaryConditions"];
    requestBC.predicate = [NSPredicate predicateWithFormat:@"model = %@", model];
    NSSortDescriptor *sortdescriptorBC = [NSSortDescriptor sortDescriptorWithKey:@"node" ascending:YES];
    requestBC.sortDescriptors = [NSArray arrayWithObject:sortdescriptorBC];
    
    NSArray *bcInModel = [modelDatabase.managedObjectContext executeFetchRequest:requestBC error:nil];
    
    for (int i=0; i<[bcInModel count]; i++) {
        
        BoundaryConditions *myBC = [bcInModel objectAtIndex:i];
        femModel->addBC([myBC.node intValue], [myBC.type intValue]);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
