//
//  SaveAsViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GeometryView.h"


@class SaveAsViewController;
@protocol SaveAsViewControllerDelegate
-(void)saveModel:(SaveAsViewController *)sender;
@end

@interface SaveAsViewController : UIViewController
{
    NSString *filePath;
    NSString *imagePath;
}

@property (retain, nonatomic) IBOutlet UITextField *inputName;
- (IBAction)saveAs:(id)sender;
@property (assign, nonatomic) IBOutlet GeometryView *geometryView;

@property(nonatomic,assign)id delegate;

@end
