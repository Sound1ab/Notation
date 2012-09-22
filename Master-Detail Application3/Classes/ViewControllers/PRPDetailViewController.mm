//
//  PRPDetailViewController.m
//  Master-Detail Application3
//
//  Created by Phillip Parker on 19/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPDetailViewController.h"
#import "PRPIosAudioController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PRPMasterViewController.h"

int count;

@interface PRPDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation PRPDetailViewController
@synthesize audioRecorder;
@synthesize audioPlayer;
@synthesize detailItem = _detailItem;
@synthesize masterViewController = _masterViewController;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize label;
@synthesize scatterPlot;
@synthesize pitchPlot;
@synthesize sampleGraphData,frequencyGraphData,noteData;
@synthesize movingButton1;
@synthesize movingButton2;
@synthesize playButton;
@synthesize slider;
@synthesize fileToPlay;
@synthesize noteLabel;
@synthesize sliderLabel;
@synthesize drawScale;
@synthesize noteSlider;
@synthesize infoView;
@synthesize noteStringArray;


//Sets how the sample indicator moves
static int curveValues[] = {
    UIViewAnimationOptionCurveEaseInOut,
    UIViewAnimationOptionCurveEaseIn,
    UIViewAnimationOptionCurveEaseOut,
    UIViewAnimationOptionCurveLinear };

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}
- (void)setLabel:(NSString *)newlabel
{
    if (label != newlabel) {
        label = newlabel;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    
    if (self.label) {

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    infoView.hidden = YES;

	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"";
    
    //When app first loads disable the play button
    playButton.enabled = NO;
    
    //Slider images
    UIImage *minImage               = [UIImage imageNamed:@"sliderBarLeft.png"];
    UIImage *maxImage               = [UIImage imageNamed:@"sliderBarRight.png"];
    UIImage *noiseGateDepressed     = [UIImage imageNamed:@"noiseGateDepressed.png"];
    UIImage *noiseGatePressed       = [UIImage imageNamed:@"noiseGatePressed.png"];
    UIImage *noteFrequencyDepressed = [UIImage imageNamed:@"noteFreqeuncyDepressed.png"];
    UIImage *noteFrequencyPressed   = [UIImage imageNamed:@"noteFreqeuncyPressed.png"];

    //Set the min and maximum stretchable area for the bar images
    minImage = [minImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    maxImage = [maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    //Set slider images for threshold slider
    [slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [slider setThumbImage:noiseGateDepressed forState:UIControlStateNormal];
    [slider setThumbImage:noiseGatePressed forState:UIControlStateHighlighted];
    
    //Set slider images for note frequency slider
    [noteSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [noteSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [noteSlider setThumbImage:noteFrequencyDepressed forState:UIControlStateNormal];
    [noteSlider setThumbImage:noteFrequencyPressed forState:UIControlStateHighlighted];

    //Deallocate the images
    minImage                = nil;
    maxImage                = nil;
    noiseGateDepressed      = nil;
    noiseGatePressed        = nil;
    noteFrequencyPressed    = nil;
    noteFrequencyDepressed  = nil;
    
    //Initial data to load into the graphs when first loaded
    NSValue *test = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    NSMutableArray *startData = [[NSMutableArray alloc] initWithObjects:test, nil];
    
    //Initialise graphs to nothing when app loads
    self.scatterPlot = [[PRPAmplitudePlot alloc] initWithHostingView:_graphHostingView andData:startData];
    [self.scatterPlot initialisePlot];
    
    self.pitchPlot = [[PRPPitchPlot alloc] initWithHostingView:_graphPitchHost andData:startData];
    [self.pitchPlot initialisePlot]; 
    
    //Setup Record queue object
    Recorder *theRecorder = [[Recorder alloc] init];
    audioRecorder = theRecorder;
    
    //Setup Playback queue object
    Player *thePlayer = [[Player alloc] init];
    audioPlayer = thePlayer;
    
    //Setup connection to the master view controller
    self.masterViewController = (PRPMasterViewController *)[[self.splitViewController.viewControllers objectAtIndex:0] visibleViewController];
    
    //Load in the note frequencies
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    
    //the below variable is an instance of the NSString class and is declared inteh .h file 
    NSString *noteFrequencies = [documentFolder stringByAppendingPathComponent:@"noteValues.plist"];
    
    NSString *bundleFile = [[NSBundle mainBundle]pathForResource:@"noteValues" ofType:@"plist"];
    
    //copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:noteFrequencies error:nil];
    
    noteStringArray = [NSArray arrayWithContentsOfFile:noteFrequencies];
    
    NSNumber *initialIncrease = [NSNumber numberWithFloat:5.7];
    
    [self.drawScale increaseNotes:initialIncrease];

    
    
}

- (void)viewDidUnload
{
    [self setPlayButton:nil];
    [self setSlider:nil];
    [self setNoteLabel:nil];
    [self setDrawScale:nil];
    [self setDrawScale:nil];
    [self setNoteSlider:nil];
    [self setInfoView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//Sets orientation only to landscape
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

//Open infoview subview when info button is pressed
-(IBAction)openInfoView:(id)sender{
    infoView.hidden = NO;
}

//Close infoview subview when close button is pressed
-(IBAction)closeInfoView:(id)sender{
    infoView.hidden = YES;
}

//Slider to set how many notes appear on the stave
- (IBAction)noteSliderChanged:(id)sender {
    //Take value from slider
    int progressAsInt = (int)(noteSlider.value + 0.5f);
    
    //Set the int value as an NSNumber to send 
    NSNumber *increase = [NSNumber numberWithInt:progressAsInt];
    
    //Send the current slider value to the method within drawScale
    [self.drawScale increaseNotes:increase];
}

//Button connected to record on the detail view. Sends message to insert new object on master view
- (IBAction)record:(id)sender {
    [self.masterViewController insertNewNewObject];
}

//Slider to change the threshold
-(IBAction) sliderChanged:(id)sender {
    //Take value from slider
    int progressAsInt = (int)(slider.value + 0.5f);
    
    //Put the slider value in an NSString
    NSString *newText = [NSString stringWithFormat:@"%d",progressAsInt];
    
    //Update the slider label with the current threshold
    sliderLabel.text = newText;
    
    //Send the current slider value to the master view controller
    self.masterViewController.threshold = [NSNumber numberWithInt:progressAsInt];
}

//When play button is pressed starts a timer that will call onTick to show notes
-(void)startTimer {
    self->packetTimer = [NSTimer timerWithTimeInterval:0.089 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:packetTimer forMode:NSDefaultRunLoopMode];
}
- (void)onTick:(NSTimer *)aTimer{
    //Take current note value out of the noteData array
    NSNumber *noteNumber = [NSNumber numberWithInt:[[noteData objectAtIndex:count]intValue]];
   
    //Set the label to equal nothing if a 0 is outputted
    if ([noteNumber intValue] == 0) {
        noteLabel.text = @"";
    }
    
    //Using the note value from the noteData array, use that note to extract a string from
    //from the noteStringArray which holds the note letters
    if ([noteNumber intValue] > 0) {
        NSString *noteString = [NSString stringWithFormat:@"%@",[noteStringArray objectAtIndex:[noteNumber intValue]]];
        noteLabel.text = noteString;
    }
    
    //If the melody reaches the end stop the timer using invalidate
    if (count >= 102) {
        [aTimer invalidate];
        aTimer = nil;
        
    }
    
    count++;
}

//Method called when play button on screen is pressed
- (IBAction)playButton:(id)sender{
    count = 0;
    
    //Start indicator animations
    [self btnMoveToA];
    [self btnMoveToC];
    
    //Start timer to display note values
    [self startTimer];
    
    //Move back indicators to original position after 10.5 seconds
    [self performSelector:@selector(btnMoveToB) withObject:NULL afterDelay:10.5f];
    [self performSelector:@selector(btnMoveToD) withObject:NULL afterDelay:10.5f];

    //Disable play button
    playButton.enabled = NO;
    
    //Ignore user interaction when playing back
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents]; 
    
    //Start the audio playback queue
    [audioPlayer startPlayback:fileToPlay];

}

//Sample indiator animations
- (void) btnMoveToA
{
    //Move indicator 1 from the start point to new coordinates specified
    [movingButton1 moveTo:
     CGPointMake(682,
                 530)                
                duration:10 option:curveValues[3]];

}
- (void) btnMoveToB
{
    //Move indicator 1 from the end point back to start point specified
    [movingButton1 moveTo:
     CGPointMake(45,
                 530)                
                duration:1.0 option:curveValues[0]];
    playButton.enabled = YES;
    
    //Stop ignoring user interaction
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];    


}
- (void) btnMoveToC
{
    //Move indicator 2 from the start point to new coordinates specified
    [movingButton2 moveTo:
     CGPointMake(682,
                 330)                
                 duration:10 option:curveValues[3]];	
    
}
- (void) btnMoveToD
{
    //Move indicator 2 from the end point back to start point specified
    [movingButton2 moveTo:
     CGPointMake(45,
                 330)                
                 duration:1.0 option:curveValues[0]];	
    playButton.enabled = YES;
    
    //Stop ignoring user interaction
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];    
    
    
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Samples", @"Samples");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

//Method that loads data into the graphs
-(void)grabData:  (NSString *) fileLocation{
    
    //Enable the play button
    playButton.enabled = YES;

    //Setup arrays to hold data
    sampleGraphData     = [NSMutableArray arrayWithCapacity:4410];
    frequencyGraphData  = [NSMutableArray arrayWithCapacity:103];
    noteData            = [NSMutableArray arrayWithCapacity:103];

    //Redraw the graph with the contents specified by fileLocation
    [self.drawScale currentData:fileLocation];

    //Create index locations to retreive information from the dictionary
    NSString *sampleIndex       = [NSString stringWithFormat:@"sample_%@",fileLocation];
    NSString *frequencyIndex    = [NSString stringWithFormat:@"frequency_%@",fileLocation];
    NSString *noteIndex         = [NSString stringWithFormat:@"note_%@",fileLocation];
    
    //Locate the documents drectory and place in new string
    NSArray *documentPath       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder    = [documentPath objectAtIndex:0];
    NSString *plistFile         = [documentFolder stringByAppendingPathComponent:@"Storage.plist"];
    NSString *bundleFile        = [[NSBundle mainBundle]pathForResource:@"Storage" ofType:@"plist"];
    
    //Copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:plistFile error:nil];
    
    //Copy contents of plist to and NSDictionary
    NSDictionary *dict          = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    
    //Extract data from the dictionary at the keys specified
    NSMutableArray *sampleDataFromPlist     = [dict valueForKey:sampleIndex];
    NSMutableArray *frequencyDataFromPlist  = [dict valueForKey:frequencyIndex];
    NSMutableArray *noteDataFromPlist       = [dict valueForKey:noteIndex];


    //Save loaded sample data in sampleGraphData array to place into the plot
    for (int i = 0; i< 4410; i++){
        
        [sampleGraphData addObject:[NSValue valueWithCGPoint:CGPointMake(i, [(NSNumber *)[sampleDataFromPlist objectAtIndex:i] floatValue])]];
    }
    
    for (int i = 0; i < 103; i++) {
        
        //Save loaded frequnecy data into frequencyGraphData array to place into plot
        [frequencyGraphData addObject:[NSValue valueWithCGPoint:CGPointMake(i, [(NSNumber *)[frequencyDataFromPlist objectAtIndex:i] floatValue])]];
        
        //Save loaded note data to decipher values into strings versions
        [noteData insertObject:[noteDataFromPlist objectAtIndex:i] atIndex:i];
                
    }
    
    //Draw plots
    self.scatterPlot = [[PRPAmplitudePlot alloc] initWithHostingView:_graphHostingView andData:sampleGraphData];
    [self.scatterPlot initialisePlot];
    
    self.pitchPlot = [[PRPPitchPlot alloc] initWithHostingView:_graphPitchHost andData:frequencyGraphData];
    [self.pitchPlot initialisePlot]; 

}



@end
