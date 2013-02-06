//
//  OpenTableViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-13.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "OpenTableViewController.h"
#import "DrawImages.h"

@implementation OpenTableViewController
@synthesize filelist;
@synthesize delegate;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    editButton = self.navigationItem.rightBarButtonItem = self.editButtonItem;
    editButton.title = @"Edit";
    
    [self updateFileList];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing)
    {
        NSLog(@"editMode on");
        editButton.title = @"Done";
        
    }
    else
    {
        NSLog(@"Done leave editmode");
        editButton.title = @"Edit";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

-(void)updateFileList
{
    NSFileManager *filemgr;
    filemgr =[NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"];
    
    
    filelist=[[NSMutableArray alloc]init];
    
    for (int i = 0; i<[[filemgr contentsOfDirectoryAtPath:docsDir error:NULL] count]; i++)
    {
        NSString *filename = [[filemgr contentsOfDirectoryAtPath:docsDir error:NULL] objectAtIndex:i];
        NSString *pathExtension = [filename pathExtension];
        if ([pathExtension isEqual:@"safx"])
             {
                 [filelist addObject:[[[filemgr contentsOfDirectoryAtPath:docsDir error:NULL] objectAtIndex:i] stringByDeletingPathExtension]];
             }

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filelist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"modelsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text=[filelist objectAtIndex:indexPath.row];
    

    NSFileManager *filemgr;
    filemgr =[NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"];
    
    NSString *imagePath = [[docsDir stringByAppendingPathComponent:[filelist objectAtIndex:indexPath.row]] stringByAppendingPathExtension:@"png"];
    
    cell.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    
    

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSFileManager *filemgr;
        filemgr =[NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"] stringByAppendingPathComponent:[filelist objectAtIndex:indexPath.row]] stringByAppendingPathExtension:@"safx" ];
        
        NSString *imageFilePath = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"users"] stringByAppendingPathComponent:[filelist objectAtIndex:indexPath.row]] stringByAppendingPathExtension:@"png" ];
        
        
        NSError *error = nil;
        if ([filemgr removeItemAtPath:filePath error:&error] != YES)
        {
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        
        error = nil;
        if ([filemgr removeItemAtPath:imageFilePath error:&error] != YES)
        {
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        
        [self updateFileList];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate openXML:[filelist objectAtIndex:indexPath.row]];
    [delegate openModel:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end



