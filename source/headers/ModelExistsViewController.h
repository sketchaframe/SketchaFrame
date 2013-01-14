//
//  ModelExistsViewController.h
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models.h"


@interface ModelExistsViewController : UIViewController 

@property (nonatomic, strong) UIManagedDocument *modelDatabase;
- (IBAction)overwriteButton:(id)sender;
@property(nonatomic,assign)id delegate;
@end
