//
//  Lines.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Models;

@interface Lines : NSManagedObject

@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;
@property (nonatomic, retain) Models *model;

@end
