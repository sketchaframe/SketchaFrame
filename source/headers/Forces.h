//
//  Forces.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Models;

@interface Forces : NSManagedObject

@property (nonatomic, retain) NSNumber * xcomp;
@property (nonatomic, retain) NSNumber * magnitude;
@property (nonatomic, retain) NSNumber * ycomp;
@property (nonatomic, retain) NSNumber * node;
@property (nonatomic, retain) Models *model;

@end
