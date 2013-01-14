//
//  Models.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BoundaryConditions, Forces, Lines, Nodes;

@interface Models : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *lines;
@property (nonatomic, retain) NSSet *nodes;
@property (nonatomic, retain) NSSet *boundaryconditions;
@property (nonatomic, retain) NSSet *forces;
@end

@interface Models (CoreDataGeneratedAccessors)

- (void)addLinesObject:(Lines *)value;
- (void)removeLinesObject:(Lines *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

- (void)addNodesObject:(Nodes *)value;
- (void)removeNodesObject:(Nodes *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

- (void)addBoundaryconditionsObject:(BoundaryConditions *)value;
- (void)removeBoundaryconditionsObject:(BoundaryConditions *)value;
- (void)addBoundaryconditions:(NSSet *)values;
- (void)removeBoundaryconditions:(NSSet *)values;

- (void)addForcesObject:(Forces *)value;
- (void)removeForcesObject:(Forces *)value;
- (void)addForces:(NSSet *)values;
- (void)removeForces:(NSSet *)values;

@end
