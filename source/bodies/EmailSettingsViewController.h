//
//  EmailSettingsViewController.h
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 2/1/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class EmailSettingsViewController;
@protocol EmailSettingsViewControllerDelegate
-(void)sendEmail:(EmailSettingsViewController *)sender;
@end

@interface EmailSettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)cancelButton:(id)sender;
- (IBAction)sendEmail:(id)sender;
@property(nonatomic, assign)id delegate;

@end
