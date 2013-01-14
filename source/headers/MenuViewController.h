//
//  MenuViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-27.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuViewController;
@protocol MenuViewControllerDelegate
-(void)menuUpdate:(MenuViewController *)sender;
-(double)maxDisp:(MenuViewController *)sender;
-(double)maxMoment:(MenuViewController *)sender;
@end

@interface MenuViewController : UIViewController
- (IBAction)switchChanged:(id)sender;
- (IBAction)tensionSwitched:(id)sender;


@property (retain, nonatomic) IBOutlet UISwitch *tensionMode;
@property (retain, nonatomic) IBOutlet UISwitch *showDisplacements;
@property (retain, nonatomic) IBOutlet UISwitch *showMoment;
@property (retain, nonatomic) IBOutlet UISwitch *showNormal;
@property (retain, nonatomic) IBOutlet UISwitch *showGrid;
@property (retain, nonatomic) IBOutlet UISwitch *orthoMode;

@property(nonatomic,assign)id delegate;
@end
