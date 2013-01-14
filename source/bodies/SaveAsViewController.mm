//
//  SaveAsViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "SaveAsViewController.h"
#import "WriteCoreData.h"
#import "ModelExistsViewController.h"

@interface SaveAsViewController ()

@end


@implementation SaveAsViewController
@synthesize inputName;
@synthesize geometryView=_geometryView;
@synthesize modelDatabase=_modelDatabase;
@synthesize model;
@synthesize delegate;


- (void)userDocument 
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.modelDatabase.fileURL path]]) 
    {
        [self.modelDatabase saveToURL:self.modelDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {

            
        }]; 
        
        
    } else if (self.modelDatabase.documentState == UIDocumentStateClosed) {
        [self.modelDatabase openWithCompletionHandler:^(BOOL success) {

        }];
    } else if (self.modelDatabase.documentState == UIDocumentStateNormal) {

    }
}


-(void)setModelDatabase:(UIManagedDocument *)modelDatabase
{
    if (_modelDatabase != modelDatabase)
        _modelDatabase = modelDatabase;
    [self userDocument];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GeometryView *myGeo = [GeometryView sharedInstance];
    NSString *name = [NSString stringWithCString:[myGeo getFemModel]->getName().c_str() 
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
    
    if (inputName.text != @"") 
    {
        GeometryView *myGeo = [GeometryView sharedInstance];
        CFemModelPtr femModel = [myGeo getFemModel];
        femModel->setName([inputName.text UTF8String]);
        
        
        //Check if modelname is taken
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Models"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", inputName.text];
        NSSortDescriptor *sortdescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortdescriptor];
        
        NSArray *modelList = [self.modelDatabase.managedObjectContext executeFetchRequest:request error:nil];
        model = [modelList lastObject];
        if ([modelList count] == 0) 
        {
            if (femModel->calculate(YES, YES) || (femModel->drawRedundancy() && femModel->getRedundancyBrain(femModel)->getm()==0))
            {
                [WriteCoreData saveModelToCore:self.modelDatabase];
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
        modelExistsVC.modelDatabase = self.modelDatabase;
        modelExistsVC.delegate = delegate;
    }
}

@end
