//
//  PRPMasterViewController.h
//  Master-Detail Application3
//
//  Created by Phillip Parker on 19/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PRPDetailViewController;

#import <CoreData/CoreData.h>
#import "Recorder.h"
#import "Player.h"
#import "MBProgressHUD.h"
#import "PRPDrawScale.h"

@interface PRPMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    PRPDrawScale    *drawScale;
    Recorder        *audioRecorder;   
    Player          *audioPlayer;
    NSString        *fileAtIndex;
    MBProgressHUD   *HUD;


}

//Link to audio queue objects
@property (nonatomic, retain) Recorder                      *audioRecorder;
@property (nonatomic, retain) Player                        *audioPlayer;
//Link to drawscale object
@property (strong, nonatomic) PRPDrawScale                  *drawScale;
@property (strong, nonatomic) PRPDetailViewController       *detailViewController;
//Persistent store access
@property (strong, nonatomic) NSFetchedResultsController    *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (strong, nonatomic) id                            masterDetailItem;
@property (strong, nonatomic) id                            masterDeleteItem;
//To set threshold
@property (strong, nonatomic) NSNumber                      *threshold;
//To locate file within list
@property (strong, nonatomic) NSString                      *fileAtIndex;

-(void) insertNewNewObject;
-(void) sendRecord:         (NSString *) fileLocation;
-(void) stopRecording;

@end
