//
//  OpenTableViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeometryViewController.h"

@class OpenTableViewController;
@protocol OpenTableViewControllerDelegate
-(void)openXML:(NSString * )fileName;
-(void)openModel:(OpenTableViewController *)sender;
@end

@interface OpenTableViewController : UITableViewController
{
    NSMutableArray *filelist;
    UIBarButtonItem *editButton;
}
@property (retain) NSMutableArray *filelist;

@property (retain, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, assign) id<OpenTableViewControllerDelegate> delegate;
@end
