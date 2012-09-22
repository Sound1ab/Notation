//
//  Player.m
//  RecreateAudioQueue
//
//  Created by Phillip Parker on 28/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

@implementation Player

//Set inital state of queue playback to false
- init {
	if (self = [super init]) {
        
        playState.playing = false;

	}
	return self;
}

//Audio callback that takes sample information from the audio files and stores in buffer
void AudioOutputCallback(
                         void* inUserData,
                         AudioQueueRef outAQ,
                         AudioQueueBufferRef outBuffer)
{
	PlayState* playState = (PlayState*)inUserData;	

    if(!playState->playing)
    {
        printf("Not playing, returning\n");
        return;
    }
    
    AudioStreamPacketDescription* packetDescs = NULL;
    
    UInt32      bytesRead;
    UInt32      numPackets = 4096;
    OSStatus    status;
        
    status = AudioFileReadPackets(
                                  playState->audioFile,
                                  false,
                                  &bytesRead,
                                  outBuffer->mPacketDescriptions,
                                  playState->currentPacket,
                                  &numPackets,
                                  outBuffer->mAudioData);
    

    
    if(numPackets)
    {
        outBuffer->mAudioDataByteSize = bytesRead;
        status = AudioQueueEnqueueBuffer(
                                         playState->queue,
                                         outBuffer,
                                         0,
                                         packetDescs);
        
        playState->currentPacket += numPackets;
    }
    else
    {
        if(playState->playing)
        {
            AudioQueueStop(playState->queue, false);
            AudioFileClose(playState->audioFile);
            playState->playing = false;
        }
        
        AudioQueueFreeBuffer(playState->queue, outBuffer);
    }
    
}
//Configure the ASBD
- (void)setupAudioFormat:(AudioStreamBasicDescription*)format 
{
	format->mSampleRate = 44100.00;
	format->mFormatID = kAudioFormatLinearPCM;
	format->mFramesPerPacket = 1;
	format->mChannelsPerFrame = 1;
	format->mBytesPerFrame = 2;
	format->mBytesPerPacket = 2;
	format->mBitsPerChannel = 16;
	format->mReserved = 0;
	format->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
}
//Intialise playback. File location is imported into the method using the filePath parameter
- (void)startPlayback: (NSString *) filePath
{
    playState.currentPacket = 0;
    [self setupAudioFormat:&playState.dataFormat];
    
    fileURL =  CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [filePath UTF8String], [filePath length], NO);
    
    OSStatus status;
    status = AudioFileOpenURL(fileURL, kAudioFileReadWritePermission, kAudioFileCAFType, &playState.audioFile);
    if(status == 0)
    {
        status = AudioQueueNewOutput(
                                     &playState.dataFormat,
                                     AudioOutputCallback,
                                     &playState,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopCommonModes,
                                     0,
                                     &playState.queue);
        
        if(status == 0)
        {
            playState.playing = true;
            for(int i = 0; i < NUM_BUFFERS && playState.playing; i++)
            {
                if(playState.playing)
                {
                    AudioQueueAllocateBuffer(playState.queue, 44100, &playState.buffers[i]);
                    AudioOutputCallback(&playState, playState.queue, playState.buffers[i]);
                }
            }
            
            if(playState.playing)
            {
                status = AudioQueueStart(playState.queue, NULL);
                if(status == 0)
                {
                }
            }
        }        
    }
    
    if(status != 0)
    {
        [self stopPlayback];
    }
}
//When playback of file stops this method is called to flush and dispose of queue
- (void)stopPlayback
{
    playState.playing = false;
    
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(playState.queue, playState.buffers[i]);
    }
    
    AudioQueueDispose(playState.queue, true);
    AudioFileClose(playState.audioFile);
}


@end
