//
//  GeometryViewController.m
//  SimpleFrame
//
//  Created by Jonas Lindemann on 5/24/12.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "GeometryViewController.h"


@interface  GeometryViewController() <OpenTableViewControllerDelegate, SaveAsViewControllerDelegate>
@property (retain) GeometryView *myGeo;
@end

@implementation GeometryViewController
@synthesize orthoButtonOutlet;
@synthesize gridButtonOutlet;

@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize button6;
@synthesize button11;
@synthesize button22;
@synthesize button23;
@synthesize button100;
@synthesize geometryView=_geometryView;
@synthesize modelDatabase=_modelDatabase;
@synthesize terminateDatabase=_terminateDatabase;
@synthesize saveAsViewController;
@synthesize saveAsPopOverController;
@synthesize openPopOverController;
@synthesize examplesPopOverController;
@synthesize tabBarOutlet;
@synthesize myGeo;
@synthesize questionButton;
@synthesize buttonUndo;
@synthesize undoModelList;
@synthesize redoModelList;
@synthesize buttonRedo;
@synthesize buttonMenuView;



-(void)viewWillAppear:(BOOL)animated {
    //Refresh view
	[self.geometryView setNeedsDisplay];
    [self updateButtonStatus];
    [self.geometryView setNeedsDisplay];

    
    //Make sure buttons are placed very nicly
    vector<UIButton *> buttonList;
    buttonList.push_back(button22);
    buttonList.push_back(button100);
    buttonList.push_back(button23);
    buttonList.push_back(buttonUndo);
    buttonList.push_back(buttonRedo);
    buttonList.push_back(gridButtonOutlet);
    buttonList.push_back(orthoButtonOutlet);
    buttonList.push_back(questionButton);
    buttonList.push_back(button11);
    buttonList.push_back(button1);
    buttonList.push_back(button5);
    buttonList.push_back(button2);
    buttonList.push_back(button3);
    buttonList.push_back(button4);
    buttonList.push_back(button6);



    int buttonWidth = 45;
    int buttonHeight = 45;
    int numberofSpaces= 2;
    int nrOfSmallSpaceinSpace=7;
    
    int space = (768-buttonWidth*buttonList.size())/(buttonList.size()+1+numberofSpaces*nrOfSmallSpaceinSpace);
    
    buttonMenuView.frame = CGRectMake(0,44,768,buttonHeight+2*space);
    
    int xLocation=space;
    for (int i=0;i<buttonList.size();i++)
    {        
        if (i == 5 || i==8)
        {
            xLocation+=space*nrOfSmallSpaceinSpace;
        }
        
        buttonList[i].frame = CGRectMake(xLocation,space,buttonWidth,buttonHeight);
        xLocation+=buttonWidth+space;
    }
    
    
    
    
    //Make sure the undo/redo buttons are correctly enabled
    if (undoModelList->size()>1)
        buttonUndo.enabled = true;
    else
        buttonUndo.enabled = false;

    if (redoModelList->size()>0)
        buttonRedo.enabled = true;
    else
        buttonRedo.enabled = false;
    
    
    //Place the geometryview correct
    //geometryView.frame = CGRectMake(0, buttonHeight+2*space+44, 768, 1024-buttonHeight-2*space-44-49);
    scroll.frame = CGRectMake(0, buttonHeight+2*space+44, 920, 1024-buttonHeight-2*space-44-49);

    
    
   
    if (femModel->drawRedundancy())
    {
        bool beamConstrainsExists = false;
        for (int i=0; i<femModel->nodeCount(); i++)
        {
            if (femModel->getNode(i)->getBCCount() > 0)
            {
                if (femModel->getNode(i)->getBC(0)->getType() == 0 || femModel->getNode(i)->getBC(0)->getType() == 4)
                {
                    beamConstrainsExists = true;
                }
            }
        }
        
        if (beamConstrainsExists)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Beam constrains exists"
                                                           message: @"Beam constrains are not supported for the redundancy tool and will therefore be translated into bar constraints."
                                                          delegate: self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK",nil];
            
            
            [alert show];
            

        }
    }
}

- (void)updateButtonStatus
{
    //Load status to buttons
    button1.enabled=YES;
    button2.enabled=YES;
    button3.enabled=YES;
    button4.enabled=YES;
    button5.enabled=YES;
    button6.enabled=YES;
    button11.enabled=YES;
    button22.enabled=YES;
    button23.enabled=YES;
    button100.enabled=YES;
    
    switch ([myGeo toolMode]) {
        case 1:
            button1.enabled=NO;
            break;
        case 2:
            button2.enabled=NO;
            break;
        case 3:
            button3.enabled=NO;
            break;
        case 4:
            button4.enabled=NO;
            break;
        case 5:
            button5.enabled=NO;
            break;
        case 6:
            button6.enabled=NO;
            break;
        case 11:
            button11.enabled=NO;
            break;
        case 22:
            button22.enabled=NO;
            break;
        case 23:
            button23.enabled=NO;
            break;
        case 100:
            button100.enabled=NO;
            break;
            
        default:
            break;
    }
    
    if (femModel->showGrid())
    {
        gridButtonOutlet.alpha = 0.4;
    } else {
        gridButtonOutlet.alpha = 1;
    }
    
    if (femModel->orthoMode())
    {
        orthoButtonOutlet.alpha = 0.4;
    } else {
        orthoButtonOutlet.alpha = 1;
    }
    
    
    if (tabBarOutlet.tag == 0)
        femModel->setDrawMode(YES, NO, NO, femModel->showGrid(), femModel->orthoMode(), NO, NO);
    if (tabBarOutlet.tag == 1)
        femModel->setDrawMode(NO, YES, YES, femModel->showGrid(), femModel->orthoMode(), NO, NO);
    if (tabBarOutlet.tag == 2)
        femModel->setDrawMode(NO, NO, NO, femModel->showGrid(), femModel->orthoMode(), YES, NO);
    if (tabBarOutlet.tag == 3)
        femModel->setDrawMode(NO, NO, NO, femModel->showGrid(), femModel->orthoMode(), NO, YES);
    
    [myGeo setNeedsRescale:YES];
    
}

- (void)userDocument:(UIManagedDocument *)document 
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) 
    {
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        }]; 
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {}];
    }
}

-(void)setModelDatabase:(UIManagedDocument *)modelDatabase
{
    if (_modelDatabase != modelDatabase)
        _modelDatabase = modelDatabase;
    [self userDocument:_modelDatabase];
}

- (void)viewDidLoad

{
    myGeo = [GeometryView sharedInstance];
    femModel = [myGeo getFemModel];
    femModel->setScale(100);
    femModel->setMomentScale(10000);
    
    undoModelList = [myGeo getUndoModelList];
    redoModelList = [myGeo getRedoModelList];

    
    //If first time showing the view set toolmode 22 (draw)
    if ([myGeo toolMode] < 1)
    {
        [myGeo setToolMode:22];
    }
    
    [super viewDidLoad];
    //button22.enabled = NO;
    
    [self.geometryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.geometryView action:@selector(handleTap:)]];
    
    [self.geometryView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.geometryView action:@selector(handlePan:)]];
    
    [scroll setScrollEnabled:YES];
    scroll.ContentSize = self.geometryView.bounds.size;
    scroll.delegate = self;
    scroll.minimumZoomScale=1;
    scroll.maximumZoomScale=3;
    [scroll setZoomScale:scroll.minimumZoomScale];
    

    //Set two fingers give scrollview panning
    for (UIGestureRecognizer *gestureRecognizer in scroll.gestureRecognizers) {     
        if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
            panGR.minimumNumberOfTouches = 2;               
        }
    }
    
    
    //Allocate database and delegate it out to popovers
    if (!self.modelDatabase) {
        self.modelDatabase = [DBManager database];
    }
    
    [self updateButtonStatus];
    [self.geometryView setNeedsDisplay];
    
    //Notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUndoModel:) name:kUndo object:nil];
 
    //Push back empty model as first undo
    if (undoModelList->size() == 0)
    {
        CFemModelPtr undoModel = new CFemModel;
        *undoModel = femModel;
        
        undoModelList->push_back(undoModel);
    }
    
    
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.geometryView;
}

- (void)viewDidUnload
{

    [self setButton1:nil];
    [self setButton2:nil];
    [self setButton3:nil];
    [self setButton4:nil];
    [self setButton5:nil];
    [self setButton6:nil];
    [self setButton11:nil];
    [self setButton22:nil];
    [self setButton23:nil];
    [self setButton100:nil];
    [self setTabBarOutlet:nil];
    [self setGridButtonOutlet:nil];
    [self setOrthoButtonOutlet:nil];
    [self setQuestionButton:nil];
    [self setButtonUndo:nil];
    [self setButtonRedo:nil];
    [self setButtonMenuView:nil];
    [super viewDidUnload];
    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}





- (void)dealloc {
    [scroll release];
    [button1 release];
    [button2 release];
    [button3 release];
    [button4 release];
    [button5 release];
    [button6 release];
    [button11 release];
    [button22 release];
    [button100 release];
    [button23 release];
    [tabBarOutlet release];
    [gridButtonOutlet release];
    [orthoButtonOutlet release];
    [questionButton release];
    [buttonUndo release];
    [buttonRedo release];
    [buttonMenuView release];
    [super dealloc];
}



- (IBAction)ToolButton:(id)sender {
    UIButton *btn = (UIButton*)sender;
    [myGeo setToolMode:btn.tag];
    
    button1.enabled=YES;
    button2.enabled=YES;
    button3.enabled=YES;
    button4.enabled=YES;
    button5.enabled=YES;
    button6.enabled=YES;
    button11.enabled=YES;
    button22.enabled=YES;
    button23.enabled=YES;
    button100.enabled=YES;
    
    switch (btn.tag) {
        case 1:
            button1.enabled=NO;
            break;
        case 2:
            button2.enabled=NO;
            break;
        case 3:
            button3.enabled=NO;
            break;
        case 4:
            button4.enabled=NO;
            break;
        case 5:
            button5.enabled=NO;
            break;
        case 6:
            button6.enabled=NO;
            break;
        case 11:
            button11.enabled=NO;
            break;
        case 22:
            button22.enabled=NO;
            break;
        case 23:
            button23.enabled=NO;
            break;
        case 100:
            button100.enabled=NO;
            break;
            
        default:
            break;
    }

}



- (IBAction)clearButton:(id)sender {
    
    if (femModel->nodeCount()>0)
    {
    // open a alert with an OK and cancel button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear" message:@"All unsaved changes will be lost. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                          [alert show];
                          [alert release];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        NSLog(@"Cancel clear model");
    }
    else
    {
        NSLog(@"Clear model");
        femModel->clear();
        femModel->calculate(YES, YES);
        [self.geometryView setNeedsDisplay];
        [myGeo setFirstDraw:YES];
        [myGeo setFirstRelease:YES];
        
        undoModelList->clear();
        redoModelList->clear();
        
        //Push back empty undo model
        CFemModelPtr undoModel = new CFemModel;
        *undoModel = femModel;
        
        undoModelList->push_back(undoModel);
        buttonUndo.enabled=false;
    }
}

- (IBAction)feedback:(id)sender {
    [TestFlight openFeedbackView];
}


-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
    if (popoverController == openPopOverController)
    {
        openPopOverController = nil;
        [openPopOverController release];
    } else if (popoverController == saveAsPopOverController) {
        saveAsPopOverController = nil;
        [saveAsPopOverController release];
    } else if (popoverController == examplesPopOverController) {
        examplesPopOverController = nil;
        [examplesPopOverController release];
    }
}

-(void)closePopups
{
    if (openPopOverController != nil)
        if ([openPopOverController isPopoverVisible])
        {
            [openPopOverController dismissPopoverAnimated:YES];
            openPopOverController = nil;
        }
    
    if (saveAsPopOverController != nil)
        if ([saveAsPopOverController isPopoverVisible])
        {
            [saveAsPopOverController dismissPopoverAnimated:YES];
            saveAsPopOverController = nil;
        }
    if (examplesPopOverController != nil)
    {
        if ([examplesPopOverController isPopoverVisible])
        {
            [examplesPopOverController dismissPopoverAnimated:YES];
            examplesPopOverController = nil;
        }
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Open Model List"]) 
    {
        [self closePopups]; 
        NSArray *temp = [[segue destinationViewController] childViewControllers];
        OpenTableViewController *openTableViewController = [temp objectAtIndex:0];
        openTableViewController.delegate = self;
        openTableViewController.modelDatabase = self.modelDatabase;
        openPopOverController = [(UIStoryboardPopoverSegue*)segue popoverController];
        openPopOverController.delegate = self;
        

        
    } else if ([segue.identifier isEqualToString:@"Save Model"]) 
    {
        [self closePopups];        
        NSArray *temp = [[segue destinationViewController] childViewControllers];
        saveAsViewController = [temp objectAtIndex:0];
        saveAsViewController.delegate = self;
        saveAsViewController.modelDatabase = self.modelDatabase;
        saveAsPopOverController = [(UIStoryboardPopoverSegue*)segue popoverController];
        saveAsPopOverController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Examples"]) {
        [self closePopups];
        NSArray *temp = [[segue destinationViewController] childViewControllers];
        examplesPopOverController = [temp objectAtIndex:0];
        examplesPopOverController.delegate = self;
        examplesPopOverController = [(UIStoryboardPopoverSegue*)segue popoverController];
        examplesPopOverController.delegate = self;
    }

}

-(void)openModel:(id)sender
{
    [myGeo setFirstDraw:NO];
    [myGeo setFirstRelease:NO];
    femModel->calculate(YES, YES);
//    [self autoButton:self];
    [myGeo setNeedsRescale:YES];
    [self.geometryView setNeedsDisplay];
    [myGeo setFirstDraw:NO];
    [myGeo setFirstRelease:NO];
    
    
    
    if (femModel->drawRedundancy())
    {
        bool beamConstrainsExists = false;
        for (int i=0; i<femModel->nodeCount(); i++)
        {
            if (femModel->getNode(i)->getBCCount() > 0)
            {
                if (femModel->getNode(i)->getBC(0)->getType() == 0 || femModel->getNode(i)->getBC(0)->getType() == 4)
                {
                    beamConstrainsExists = true;
                }
            }
        }
        
        if (beamConstrainsExists)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Beam constrains exists"
                                                           message: @"Beam constrains are not supported for the redundancy tool and will therefore be translated into bar constraints."
                                                          delegate: self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK",nil];
            
            
            [alert show];
            
            
        }
    }

    undoModelList->clear();
    redoModelList->clear();

    //Push back undo model
    CFemModelPtr undoModel = new CFemModel;
    *undoModel = femModel;
    
    undoModelList->push_back(undoModel);
    buttonUndo.enabled=false;
    buttonRedo.enabled=false;
    
    
 
}


-(double)maxDisp:(MenuViewController *)sender
{
    return femModel->getMaxDisp();
}

-(double)maxMoment:(MenuViewController *)sender
{
    return femModel->getMaxMoment();
}

-(void)saveModel:(OpenTableViewController *)sender
{
    [saveAsPopOverController dismissPopoverAnimated:YES];
    saveAsPopOverController = nil;
 }



- (IBAction)saveButton:(id)sender {
    if (saveAsPopOverController !=nil)
    {
        [self closePopups];
        saveAsPopOverController = nil;
    } else {
        [self performSegueWithIdentifier:@"Save Model" sender:self];
    }
}

- (IBAction)openButton:(id)sender {
    if (openPopOverController !=nil)
    {
        [self closePopups];
        openPopOverController = nil;
    } else {
        [self performSegueWithIdentifier:@"Open Model List" sender:self];
    }
}

- (IBAction)examplesButton:(id)sender {
    femModel->printCode();
    if (examplesPopOverController !=nil)
    {
        [self closePopups];
        examplesPopOverController = nil;
    } else {
        [self performSegueWithIdentifier:@"Examples" sender:self];
    }
}

- (IBAction)updateUndoModel:(id)sender {

    if (!femModel->compareModelWith(undoModelList->data()[undoModelList->size()-1]))
    {
        CFemModelPtr undoModel = new CFemModel;
        *undoModel = femModel;
        
        undoModelList->push_back(undoModel);
        buttonUndo.enabled = true;
    }
    
    //Empty redo list when changes are made
    redoModelList->clear();
    
    //Limit number of undo steps
    if (undoModelList->size() > 100)
    {
        undoModelList->erase(undoModelList->begin());
    }
    
    
    if (undoModelList->size()>1)
        buttonUndo.enabled = true;
    else
        buttonUndo.enabled = false;
    
    if (redoModelList->size()>0)
        buttonRedo.enabled = true;
    else
        buttonRedo.enabled = false;
    
}

- (IBAction)undoButton:(id)sender {
    buttonRedo.enabled = true;
    CFemModelPtr redoModel = new CFemModel;
    *redoModel = femModel;
    
    redoModelList->push_back(redoModel);
    
    if (undoModelList->size() > 0)
    {
        *femModel = undoModelList->data()[undoModelList->size()-2];
        
        undoModelList->erase(undoModelList->end());
        [myGeo setNeedsRescale:YES];
        [self.geometryView setNeedsDisplay];
    }
    if (undoModelList->size() == 1)
    {
        buttonUndo.enabled = false;
    }
    
    //cout << "Redo count: " << redoModelList->size() << " Undo: " << undoModelList->size() << endl;
    
}

- (IBAction)redoButton:(id)sender {
    
    //Read latest redo model
    if (redoModelList->size() > 0)
    {
        *femModel = redoModelList->data()[redoModelList->size()-1];
        redoModelList->erase(redoModelList->end());
        [myGeo setNeedsRescale:YES];
        [self.geometryView setNeedsDisplay];
    }
    
    if (redoModelList->size() == 0)
    {
        buttonRedo.enabled=false;
    }

    CFemModelPtr undoModel = new CFemModel;
    *undoModel = femModel;

    undoModelList->push_back(undoModel);
    buttonUndo.enabled = true;

        cout << "Redo count: " << redoModelList->size() << " Undo: " << undoModelList->size() << endl;
}

- (IBAction)gridButton:(id)sender {
    if (femModel->showGrid()) {
        femModel->setDrawMode(femModel->drawDeformation(), femModel->drawMoment(), femModel->drawNormal(), NO, femModel->orthoMode(), femModel->tensionMode(),femModel->drawRedundancy());
        gridButtonOutlet.alpha = 1;
    } else {
        femModel->setDrawMode(femModel->drawDeformation(), femModel->drawMoment(), femModel->drawNormal(), YES, NO, femModel->tensionMode(),femModel->drawRedundancy());
        gridButtonOutlet.alpha = 0.4;
        orthoButtonOutlet.alpha = 1;
    }
    [self.geometryView setNeedsDisplay];
    
}
- (IBAction)orthoButton:(id)sender {
    if (femModel->orthoMode()) {
        femModel->setDrawMode(femModel->drawDeformation(), femModel->drawMoment(), femModel->drawNormal(), femModel->showGrid(), NO, femModel->tensionMode(),femModel->drawRedundancy());
        orthoButtonOutlet.alpha = 1;
    } else {
        femModel->setDrawMode(femModel->drawDeformation(), femModel->drawMoment(), femModel->drawNormal(), NO, YES, femModel->tensionMode(),femModel->drawRedundancy());
        orthoButtonOutlet.alpha = 0.4;
        gridButtonOutlet.alpha = 1;
        [self.geometryView setNeedsDisplay];
    }
}

- (IBAction)infoButton:(id)sender {
}
@end
