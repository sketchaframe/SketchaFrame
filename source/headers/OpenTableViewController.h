//
//  OpenTableViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models.h"
#import "GeometryViewController.h"

@class OpenTableViewController;
@protocol OpenTableViewControllerDelegate
-(void)openModel:(OpenTableViewController *)sender;
@end

@interface OpenTableViewController : CoreDataTableViewController
{

}
@property (retain, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) UIManagedDocument *modelDatabase;
@property (nonatomic, assign) id<OpenTableViewControllerDelegate> delegate;
@end
