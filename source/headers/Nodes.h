//
//  Nodes.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Models;

@interface Nodes : NSManagedObject

@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) Models *model;

@end
