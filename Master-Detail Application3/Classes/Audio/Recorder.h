//
//  PRPAudioQueueTest.h
//  AudioQueues
//
//  Created by Phillip Parker on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>
#import "pkmFFT.h"

//Number of buffers to be used in queue
#define NUM_BUFFERS 3
//Struct defining key variables needed to record audio to file
typedef struct
{
    AudioFileID                 audioFile;
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    UInt32                      bufferByteSize;
    SInt64                      currentPacket;
    BOOL                        recording;
    BOOL                        saving;
} RecordState;

@interface Recorder : NSObject
{
    //Ivar declarations of struct and file location
	RecordState recordState;
    CFURLRef fileURL;
}
//Arrays to store information about recorded audio
@property (strong,nonatomic) NSMutableArray *sampleArray;
@property (strong,nonatomic) NSMutableArray *frequencyArray;
@property (strong,nonatomic) NSMutableArray *magnitudeArray;
@property (strong,nonatomic) NSMutableArray *sampleData;
@property (strong,nonatomic) NSMutableArray *decibelArray;
//Location of plist file
@property (retain,nonatomic) NSString       *plistFile;
//Unique code used to save files
@property (retain,nonatomic) NSString       *saveDate;
//Threshold of noise gate set by user
@property (strong,nonatomic) NSNumber       *threshold;
//Arrays that contain the plist information on note frequencies and their notes
@property (strong,nonatomic) NSArray        *noteFrequencyArray;
@property (strong,nonatomic) NSMutableArray *noteValueArray;

- (BOOL) isRecording;
- (void) toggleRecording:   (NSString *) fileInit;
- (void) startRecording:    (NSString *) filePath;
- (void) stopRecording; 
- (void) reallyStopRecording;
- (void) hudDisplay;
- (void) hudDisplaySaving;
- (void) saveData;

@end
