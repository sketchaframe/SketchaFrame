//
//  OpenTableViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "OpenTableViewController.h"
#import "OpenViewController.h"
#import "WriteCoreData.h"

@implementation OpenTableViewController

@synthesize table;
@synthesize modelDatabase=_modelDatabase;
@synthesize delegate;

-(void)setupFetchedResultsControler:(UIManagedDocument *)document
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Models"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}


- (void)userDocument 
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.modelDatabase.fileURL path]]) 
    {
        [self.modelDatabase saveToURL:self.modelDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsControler:self.modelDatabase];
        }]; 
        
        
    } else if (self.modelDatabase.documentState == UIDocumentStateClosed) {
        [self.modelDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsControler:self.modelDatabase];
        }];
    } else if (self.modelDatabase.documentState == UIDocumentStateNormal) {
        [self setupFetchedResultsControler:self.modelDatabase];
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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"modelsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Models *models = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = models.name;
    

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:models.date];
    [dateFormatter release];

    cell.detailTextLabel.text = [@"Added: " stringByAppendingString:dateString]; 	
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete; 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Models *models = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.modelDatabase.managedObjectContext deleteObject:models];
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Models *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [WriteCoreData readModel:model:self.modelDatabase];

    [delegate openModel:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}



- (void)dealloc {
    [table release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}
@end



