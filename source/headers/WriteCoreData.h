//
//  WriteCoreData.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeometryView.h"
#import "Models.h"
#import "Nodes.h"
#import "Lines.h"
#import "Forces.h"
#import "BoundaryConditions.h"

@interface WriteCoreData : NSObject
+(void)saveModelToCore:(UIManagedDocument *)document;
+(void)readModel:(Models *) model:(UIManagedDocument *)document;
@property (assign, nonatomic) UIManagedDocument *terminateDatabase;
@end




