//
//  GeometryViewController.h
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "GeometryView.h"
#import "OpenTableViewController.h"
#import "SaveAsViewController.h"
#import "MenuViewController.h"
#import "HelpViewController.h"

#define kUndo @"kUndo"
#define kOpenXMLUrl @"kOpenXMLUrl"

@interface GeometryViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate,UIPopoverControllerDelegate, UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
    
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
@property (retain, nonatomic) IBOutlet UIButton *buttonUndo;
@property (retain, nonatomic) IBOutlet UIButton *buttonRedo;

@property (assign, nonatomic) IBOutlet GeometryView *geometryView;
@property (assign, nonatomic) SaveAsViewController *saveAsViewController;
@property (assign, nonatomic) UIPopoverController *saveAsPopOverController;
@property (assign, nonatomic) UIPopoverController *openPopOverController;
@property (assign, nonatomic) UIPopoverController *examplesPopOverController;

@property (retain, nonatomic) IBOutlet UITabBarItem *tabBarOutlet;
@property (retain, nonatomic) IBOutlet UIView *buttonMenuView;


- (IBAction)saveButton:(id)sender;
- (IBAction)openButton:(id)sender;
- (IBAction)examplesButton:(id)sender;
- (IBAction)undoButton:(id)sender;
- (IBAction)redoButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *gridButtonOutlet;
- (IBAction)gridButton:(id)sender;


@property (retain, nonatomic) IBOutlet UIButton *orthoButtonOutlet;
@property (assign, nonatomic) vector<CFemModelPtr> *undoModelList;
@property (assign, nonatomic) vector<CFemModelPtr> *redoModelList;
- (IBAction)orthoButton:(id)sender;
- (IBAction)infoButton:(id)sender;

- (IBAction)openMail:(id)sender;

@end
