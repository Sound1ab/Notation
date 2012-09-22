//
//  Player.h
//  RecreateAudioQueue
//
//  Created by Phillip Parker on 28/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

//Number of buffers to be used in queue
#define NUM_BUFFERS 3
//Number of seconds to record
#define SECONDS_TO_RECORD 10
//Struct defining key variables needed to playback file
typedef struct
{
    AudioStreamBasicDescription  dataFormat;
    AudioQueueRef                queue;
    AudioQueueBufferRef          buffers[NUM_BUFFERS];
    AudioFileID                  audioFile;
    SInt64                       currentPacket;
    bool                         playing;
} PlayState;

@interface Player : NSObject{
    //Ivar declarations
    PlayState   playState;
    CFURLRef    fileURL;
}


- (void)startPlayback: (NSString *) filePath;
- (void)stopPlayback;

@end
