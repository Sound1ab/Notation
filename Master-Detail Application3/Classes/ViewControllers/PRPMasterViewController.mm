//
//  PRPMasterViewController.m
//  Master-Detail Application3
//
//  Created by Phillip Parker on 19/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPMasterViewController.h"
#import "PRPDetailViewController.h"
#import "NewSample.h"
#import <AudioToolbox/AudioToolbox.h>


@interface PRPMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface NSDate (extended)
-(NSDate *) dateWithCalendarFormat:(NSString *)format timeZone: (NSTimeZone *)timeZone;
@end

@implementation PRPMasterViewController

@synthesize detailViewController        = _detailViewController;
@synthesize fetchedResultsController    = __fetchedResultsController;
@synthesize managedObjectContext        = __managedObjectContext;
@synthesize audioRecorder;
@synthesize audioPlayer;
@synthesize masterDetailItem;
@synthesize fileAtIndex;
@synthesize masterDeleteItem;
@synthesize threshold;
@synthesize drawScale;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set name on navigation bar
    self.title = @"Notation";
    
    //Set colour of button
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];

    //Allocate button on navigation bar
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //Set the initial threshold level
    threshold = [NSNumber numberWithInt:-25];
    
    //Allocate detail view controller
    self.detailViewController = (PRPDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //Set background of tabel
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tablebackground.png"]];
    
    //Allocate instance of audio recorder
    Recorder *theRecorder = [[Recorder alloc] init];
    audioRecorder = theRecorder;
    
    //Allocate instance of audio player
    Player *thePlayer = [[Player alloc] init];
    audioPlayer = thePlayer;
    
    //Allocat instance of drawscale object
    PRPDrawScale *theDrawer = [[PRPDrawScale alloc] init];
    drawScale = theDrawer;
    
    //Set up audio session
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord; 
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    AudioSessionSetActive(true);
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

//Sets orientation only to landscape
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

//Method called when record button on the detail view controller is pressed
-(void)insertNewNewObject{
    //Present alert sheet to user
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Sample" 
                                                        message:@"Please enter a name. Recording starts when you press OK!" 
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;    
    [alertView show];
    
    //Set the threshold currently set in the detail view controller
    audioRecorder.threshold = threshold;

}

//Alertview delegate called when user presses a button. Return buttonindex = 0 for left button and =1 for right button
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //When OK button is pressed
    if (buttonIndex == 1) {
        
        //Pre-emptive call to stop recording after 10 seconds
        [self performSelector:@selector(stopRecording) withObject:NULL afterDelay:10.0f];
        
        //Get text from textfield
        UITextField *textField          = [alertView textFieldAtIndex:0];
        
        //Assign text to NSString variable "name"
        NSString *name                  = [NSString stringWithFormat:@"%@",textField.text];
        
        // Create a new dated file
        NSDate *now                     = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate               = [[now dateWithCalendarFormat:@"%b_%d_%H_%M_%S"
                                                timeZone:nil] description];
        audioRecorder.saveDate          = caldate;
        
        //Locate the apps document directory 
        NSString *documentsDirectory    = [NSHomeDirectory() 
                                        stringByAppendingPathComponent:@"Documents"];
                
        //Create the location the file will be saved at
        NSString* fileLocation          = [documentsDirectory stringByAppendingFormat:@"/%@_%@.aiff", caldate,name];
        
        [self sendRecord:fileLocation];
        
        //Setup the managed object conext and entity
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity     = [[self.fetchedResultsController fetchRequest] entity];
        NewSample *newSample            = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
        //Add the new sample names to memory
        newSample.name                  = name;
        newSample.date                  = [NSDate date];
        newSample.newDate               = caldate;
        
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            abort();
        }
    }
}

//Alertview delegate used to void ok button when no text is entered
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView

{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] == 0)
    {
        return NO;
    }
    return YES;
}

//Send record call to audio recorder object
- (void)sendRecord: (NSString *) fileLocation
    {
        //Call toggle method to start recording with the location specifed by fileLocation
        [self.audioRecorder toggleRecording:fileLocation];
        
        //Place recording indicator on screen using HUD class
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        //Dim the background
        HUD.dimBackground = YES;
        HUD.labelText = @"Recording";
        
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(hudDisplay) onTarget:self.audioRecorder withObject:nil animated:YES];
}

//Stop the recording. Called with the pre-emptive method
- (void)stopRecording {
    //Call method within the recorder class
    [self.audioRecorder reallyStopRecording];
    
    //Place saving indicator on screen
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    //Dim background
    HUD.dimBackground = YES;
    HUD.labelText = @"Saving";
    
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(saveData) onTarget:self.audioRecorder withObject:nil animated:YES];
    

            
   
}
#pragma mark - Table View

//Returns the number of sections. Only one in this case
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

//Returns the number of rows within the section. This corresponds to the number of samples within the store
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //When edit button is pressed change edit style to delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Setup the fetched results controller
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        //Delete object from the store at the indexPath   supplied
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        //Call delete method to delete the sample from the directory
        [self delete:indexPath];

        //Save the changes made to the store
        NSError *error = nil;
        if (![context save:&error]) {
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Setup the fetched results controller retreiving results from the store at indexPath
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //Asssign to variable object
    self.masterDetailItem = object;
    
    //Take the variables from the store assigned to the key value codes specified
    NSString *playDate = [[self.masterDetailItem valueForKey:@"newDate"] description];
    NSString *playName = [[self.masterDetailItem valueForKey:@"name"] description];
    
    //Locate the home directory of the app
    NSString *documentsDirectory = [NSHomeDirectory() 
                                    stringByAppendingPathComponent:@"Documents"];
    
    //Create the file name of the sample that is required to play using the variables created
    fileAtIndex = [documentsDirectory stringByAppendingFormat:@"/%@_%@.aiff", playDate,playName];
        
    //Send that filename to the instance variable in the detail view controller
    self.detailViewController.fileToPlay = fileAtIndex;
        
    [self.detailViewController grabData:playDate];
}

- (void) delete: (NSIndexPath *) indexLocation{    
    
    //Setup a fetched results controller locating data in the 	store at the indexPath
    NewSample *newObject            = [[self fetchedResultsController] objectAtIndexPath:indexLocation];
    //Find the documents directory
    NSString *documentsDirectory    = [NSHomeDirectory() 
                                    stringByAppendingPathComponent:@"Documents"];
    //Create the delete pathURL using the fetched results
    NSString *deletePath            = [documentsDirectory stringByAppendingFormat:@"/%@_%@.aiff", newObject.newDate,newObject.name];
    // For error information
    NSError *error;
    // Create file manager
    NSFileManager *fileMgr          = [NSFileManager defaultManager];
    //Delete items formt he documents directory with the name 	specified by the delete path
    if ([fileMgr removeItemAtPath:deletePath error:&error] != YES)
    
    NSString *test = [NSString stringWithFormat:@"sample"];
    NSString *sampleIndex           = [NSString stringWithFormat:@"sample_%@",newObject.newDate];
    NSString *frequencyIndex        = [NSString stringWithFormat:@"frequency_%@",newObject.newDate];
    NSString *noteIndex             = [NSString stringWithFormat:@"note_%@",newObject.newDate];

    //Delete items from plist
    NSArray *documentPath           = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder        = [documentPath objectAtIndex:0];
    
    //the below variable is an instance of the NSString class and is declared inteh .h file 
    NSString *plistFile             = [documentFolder stringByAppendingPathComponent:@"Storage.plist"];
    
    NSString *bundleFile            = [[NSBundle mainBundle]pathForResource:@"Storage" ofType:@"plist"];
    
    //copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:plistFile error:nil];
    
    NSMutableDictionary *dict       = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    
    [dict removeObjectForKey:sampleIndex];
    [dict removeObjectForKey:frequencyIndex];
    [dict removeObjectForKey:noteIndex];

    [dict writeToFile:plistFile atomically:YES];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"button4.png"]];

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewSample" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Notes"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    abort();
	}
    
    return __fetchedResultsController;
}    


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            


            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


//Set cells name by accessing the persistent store at the index path specified
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NewSample *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", 
                                  info.date];
}

@end
