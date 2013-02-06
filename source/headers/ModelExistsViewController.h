//
//  ModelExistsViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModelExistsViewController : UIViewController 

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *imagePath;
- (IBAction)overwriteButton:(id)sender;
@property(nonatomic,assign)id delegate;
@end
