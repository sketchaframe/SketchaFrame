//
//  OpenViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Models.h"
#import "Nodes.h"
#import "Lines.h"
#import "Forces.h"
#import "BoundaryConditions.h"
#import "CoreDataTableViewController.h"
#import "GeometryView.h"

@interface OpenViewController : UIViewController

@property (nonatomic, strong) UIManagedDocument *modelDatabase;
@property (nonatomic, assign) Models *model;

@end
