//
//  OpenViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-14.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GeometryView.h"

@interface OpenViewController : UIViewController

@property (nonatomic, strong) UIManagedDocument *modelDatabase;
@property (nonatomic, assign) Models *model;

@end
