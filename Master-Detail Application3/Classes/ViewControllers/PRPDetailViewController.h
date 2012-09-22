//
//  PRPDetailViewController.h
//  Master-Detail Application3
//
//  Created by Phillip Parker on 19/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Animation.h"
#import "Recorder.h"
#import "CorePlot-CocoaTouch.h"
#import "PRPAmplitudePlot.h"
#import "PRPFrequencyPlot.h"
#import "PRPPitchPlot.h"
#import "Player.h"
@class PRPMasterViewController;
@class PRPDrawScale;

@interface PRPDetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    PRPDrawScale                    *drawScale;
    Recorder                        *audioRecorder;
    Player                          *audioPlayer;
    IBOutlet CPTGraphHostingView    *_graphHostingView;
    PRPAmplitudePlot                *_scatterPlot;
    IBOutlet CPTGraphHostingView    *_graphPitchHost;
    PRPPitchPlot                    *_PitchPlot;
    UILabel                         *sliderLabel;
    NSTimer                         *packetTimer;


}
//Link to master view controller
@property (nonatomic, retain) PRPMasterViewController	*masterViewController;

//Link to audio queue objects
@property (nonatomic, retain) Recorder                  *audioRecorder;
@property (nonatomic, retain) Player                    *audioPlayer;
@property (strong, nonatomic) id                        detailItem;
@property (strong, nonatomic) NSString                  *label;

//Scatter plot setup
@property (nonatomic, retain) PRPAmplitudePlot          *scatterPlot;
@property (nonatomic, retain) PRPPitchPlot              *pitchPlot;

//Array setup
@property (strong, nonatomic) NSMutableArray            *sampleGraphData;
@property (strong, nonatomic) NSMutableArray            *frequencyGraphData;
@property (strong, nonatomic) NSMutableArray            *noteData;
@property (retain, nonatomic) NSString                  *fileToPlay;
@property (strong, nonatomic) NSArray                   *noteStringArray;

//Onscreen button configurations
@property (strong, nonatomic) IBOutlet UILabel      *noteLabel;
@property (nonatomic,   weak) IBOutlet UIButton     *movingButton1;
@property (nonatomic,   weak) IBOutlet UIButton     *movingButton2;
@property (strong, nonatomic) IBOutlet UIButton     *playButton;
@property (strong, nonatomic) IBOutlet UISlider     *slider;
@property (nonatomic, retain) IBOutlet UILabel      *sliderLabel;
@property (strong, nonatomic) IBOutlet PRPDrawScale *drawScale;
@property (strong, nonatomic) IBOutlet UISlider     *noteSlider;
@property (strong, nonatomic) IBOutlet UIView *infoView;

//Button attachements
- (IBAction)noteSliderChanged:  (id)sender;
- (IBAction)openInfoView:       (id)sender;
- (IBAction)closeInfoView:       (id)sender;
- (IBAction)record:             (id)sender;
- (IBAction)sliderChanged:      (id)sender;
- (IBAction)playButton:         (id)sender;

//Method called from master view controller
- (void)    grabData:  (NSString *) fileLocation;


@end
