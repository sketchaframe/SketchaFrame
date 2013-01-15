//
//  ExamplesTableViewController.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/14/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeometryViewController.h"

@class ExamplesTableViewController;
@protocol ExamplesTableViewControllerDelegate
-(void)openModel:(ExamplesTableViewController *)sender;
@end

@interface ExamplesTableViewController : UITableViewController
{
    
}
@property (nonatomic, assign) id<ExamplesTableViewControllerDelegate> delegate;
@end
