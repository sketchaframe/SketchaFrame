//
//  SaveAsViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "SaveAsViewController.h"
#import "ModelExistsViewController.h"
#import "GenerateXMLData.h"
#import "DrawImages.h"

@interface SaveAsViewController ()

@end


@implementation SaveAsViewController
@synthesize inputName;
@synthesize geometryView=_geometryView;
@synthesize delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    CFemModel *femModel = [[GeometryView sharedInstance] getFemModel];
    cout << femModel->getName() << endl;
    NSString *name = [NSString stringWithCString:femModel->getName().c_str()
                                        encoding:[NSString defaultCStringEncoding]];
    inputName.text=name;
    
}



- (void)viewDidUnload
{
    [self setInputName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (void)dealloc {
    [inputName release];
    [super dealloc];
}
- (IBAction)saveAs:(id)sender {
    
    
    if (![inputName.text isEqual: @""]) 
    {
        GeometryView *myGeo = [GeometryView sharedInstance];
        CFemModelPtr femModel = [myGeo getFemModel];
        femModel->setName([inputName.text UTF8String]);
        
     
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        
        //Create folders if not exists
        NSString *path;
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"];
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
        {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
        
        //Check if modelname is taken
        
        filePath = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"] stringByAppendingPathComponent:inputName.text] stringByAppendingPathExtension:@"safx"];
        
        imagePath = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"] stringByAppendingPathComponent:inputName.text] stringByAppendingPathExtension:@"png"];

        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            if (femModel->calculate(YES, YES) || (femModel->drawRedundancy() && femModel->getRedundancyBrain(femModel)->getm()==0))
            {
                NSData *modelXMLData = [GenerateXMLData getDataModel];                
                [modelXMLData writeToFile:filePath atomically:YES];
                
                NSData *iconImageData = UIImagePNGRepresentation([DrawImages drawIcon]);
                [iconImageData writeToFile:imagePath atomically:YES];
                
                [delegate saveModel:self];
                
            } else {
                [self performSegueWithIdentifier: @"Model Not Complete" sender:self];
            }
            
        } else {
            
            [self performSegueWithIdentifier: @"modelExists" sender:self];
        }
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"modelExists"]) {
        ModelExistsViewController *modelExistsVC = [segue destinationViewController];
        modelExistsVC.delegate = delegate;
        modelExistsVC.filePath=filePath;
        modelExistsVC.imagePath=imagePath;
    }
}

@end
