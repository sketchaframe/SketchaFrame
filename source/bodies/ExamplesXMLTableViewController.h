//
//  ExamplesXMLTableViewController.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 1/30/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExamplesXMLTableViewController;
@protocol ExamplesXMLTableViewControllerDelegate
-(void)openXMLExample:(NSString * )fileName;
-(void)openModel:(ExamplesXMLTableViewController *)sender;
@end
@interface ExamplesXMLTableViewController : UITableViewController
{
        NSMutableArray *filelist;
}
@property (nonatomic, assign) id<ExamplesXMLTableViewControllerDelegate> delegate;
@end
