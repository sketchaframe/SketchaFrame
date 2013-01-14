//
//  GeometryViewController.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeometryView.h"

#import "CoreDataTableViewController.h"
#import "OpenTableViewController.h"
#import "SaveAsViewController.h"
#import "WriteCoreData.h"
#import "Models.h"
#import "MenuViewController.h"
#import "HelpViewController.h"
#import "DBManager.h"


@interface GeometryViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate,UIPopoverControllerDelegate>{
    CFemModelPtr femModel;
    GeometryView *geometryView;
    IBOutlet UIScrollView *scroll;
}

- (IBAction)ToolButton:(id)sender;
- (IBAction)clearButton:(id)sender;
- (IBAction)feedback:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *button3;
@property (retain, nonatomic) IBOutlet UIButton *button4;
@property (retain, nonatomic) IBOutlet UIButton *button5;
@property (retain, nonatomic) IBOutlet UIButton *button6;
@property (retain, nonatomic) IBOutlet UIButton *button11;
@property (retain, nonatomic) IBOutlet UIButton *button22;
@property (retain, nonatomic) IBOutlet UIButton *button23;
@property (retain, nonatomic) IBOutlet UIButton *button100;
@property (retain, nonatomic) IBOutlet UIButton *questionButton;

@property (assign, nonatomic) IBOutlet GeometryView *geometryView;
@property (retain, nonatomic) UIManagedDocument *modelDatabase;
@property (retain, nonatomic) UIManagedDocument *terminateDatabase;
@property (assign, nonatomic) SaveAsViewController *saveAsViewController;
@property (assign, nonatomic) UIPopoverController *saveAsPopOverController;
@property (assign, nonatomic) UIPopoverController *openPopOverController;

@property (retain, nonatomic) IBOutlet UITabBarItem *tabBarOutlet;

- (IBAction)saveButton:(id)sender;
- (IBAction)openButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *gridButtonOutlet;
- (IBAction)gridButton:(id)sender;


@property (retain, nonatomic) IBOutlet UIButton *orthoButtonOutlet;
- (IBAction)orthoButton:(id)sender;
- (IBAction)infoButton:(id)sender;

@end
