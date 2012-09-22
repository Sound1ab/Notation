//
//  PRPAudioQueueTest.m
//  AudioQueues
//
//  Created by Phillip Parker on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Recorder.h"

//total number of samples recorded for 10 seconds of audio
#define kArraySize 441000
//Offset to normalise decibel
#define DBOFFSET -74.0
#define LOWPASSFILTERTIMESLICE .001

//Allocate new FFT
pkmFFT *fft;
//Allocate accessble buffers from callback function
float *allocated_magnitude_buffer;
float *allocated_phase_buffer;
float *samplesAsFloats;
float *sampleBuffer;
float *magnitudeBuffer;
float *decibelBuffer;

//Call magic cookie if using compressed file formats to supply info about format
OSStatus SetMagicCookieForFile (
                                AudioQueueRef inQueue,
                                AudioFileID   inFile
                               ){
    OSStatus result = noErr;
    UInt32 cookieSize;
    //Get size properties from audio queue
    if (
        AudioQueueGetPropertySize (
                                   inQueue,
                                   kAudioQueueProperty_MagicCookie,
                                   &cookieSize
                                   ) == noErr
        ) {
        //Allocate byte buffer to hold cookie
        char* magicCookie =
        (char *) malloc (cookieSize);
        //Cope magic cookie to buffer
        if (
            AudioQueueGetProperty (
                                   inQueue,
                                   kAudioQueueProperty_MagicCookie,
                                   magicCookie,
                                   &cookieSize
                                   ) == noErr
            )
            //Set the properties on file. Send byte buffer as value
            result =  AudioFileSetProperty (
                                            inFile,
                                            kAudioFilePropertyMagicCookieData,
                                            cookieSize,
                                            magicCookie
                                            );
        free (magicCookie);
    }
    return result;
}

static void HandleInputBuffer (
                               void                                 *aqData,
                               AudioQueueRef                        inAQ,
                               AudioQueueBufferRef                  inBuffer,
                               const AudioTimeStamp                 *inStartTime,
                               UInt32                               inNumPackets,
                               const AudioStreamPacketDescription   *inPacketDesc
                               )  {
    RecordState *pAqData = (RecordState *) aqData;    

    if (inNumPackets == 0 &&
        pAqData->dataFormat.mBytesPerPacket != 0)
        inNumPackets =
        inBuffer->mAudioDataByteSize / pAqData->dataFormat.mBytesPerPacket;
        
    if (AudioFileWritePackets (
                               pAqData->audioFile,
                               NO,
                               inBuffer->mAudioDataByteSize,
                               inPacketDesc,
                               pAqData->currentPacket,
                               &inNumPackets,
                               inBuffer->mAudioData
                               ) == noErr) {
        
        //Take samples from buffers and place into new variable
        SInt16 *buf = (SInt16 *)inBuffer->mAudioData;
        
        //Take samples from mAudioData and transfer to samplesAsFloats for FFT. All Samples also
        //transfered  to sampleBuffer by incrementing the write position on sampleBuffer 4068 indexs 
        //everytime the callback is called.
        for(int i = 0; i < inNumPackets; i++) {
            samplesAsFloats[i] = buf[i] / 32768.0f;
            sampleBuffer[i+pAqData->currentPacket] = buf[i] / 32768.0f;
            decibelBuffer[i+pAqData->currentPacket] = buf[i];
            
        }
        
        
        //Add samples into FFT output into magnitude buffer
        fft->forward(0, samplesAsFloats, allocated_magnitude_buffer, allocated_phase_buffer);
            
        //Get all magnitudes and placed them into the magnitude buffer. Anything below half the FFT 
        //size gets added anything above gets zeroed to remove unnecessary data
        for(int i = 0; i < inNumPackets; i++) {
            
            if (i < inNumPackets/2) {
                magnitudeBuffer[i+pAqData->currentPacket] = allocated_magnitude_buffer[i];
            }
            if (i >= inNumPackets/2) {
                magnitudeBuffer[i+pAqData->currentPacket] = 0.00000;
            }
        }

        pAqData->currentPacket += inNumPackets;

        
        if (pAqData->recording == 0)
            return;
        AudioQueueEnqueueBuffer (
                                 pAqData->queue,
                                 inBuffer,
                                 0,
                                 NULL
                                 );
    }
}
                               
@implementation Recorder

@synthesize sampleArray, frequencyArray, magnitudeArray,sampleData,decibelArray;
@synthesize plistFile,saveDate;
@synthesize threshold;
@synthesize noteFrequencyArray;
@synthesize noteValueArray;

//Initialise variables such as the FFT and buffers for sample information
- (id) init
{
    self = [super init];
    //Set initial record state to no so recording does not begin when class is instantiated
    recordState.recording = NO;
    //Variable for buffersize
    float bufferSize = 4096;
    //Declare new fft
    fft = new pkmFFT(bufferSize);
    //Declare new buffers to store sample information
    samplesAsFloats             =  (float *) malloc (sizeof(float) * bufferSize); 
    allocated_magnitude_buffer  =  (float *) malloc (sizeof(float) * (bufferSize / 2));
    allocated_phase_buffer      =  (float *) malloc (sizeof(float) * (bufferSize / 2));
    sampleBuffer                =  (float *)malloc(sizeof(float) * (kArraySize));
    magnitudeBuffer             =  (float *)malloc(sizeof(float) * (kArraySize));
    decibelBuffer               =  (float *)malloc(sizeof(float) * (kArraySize));
    //Locate documents directory and copy note frequencies
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    NSString *noteFrequencies = [documentFolder stringByAppendingPathComponent:@"noteFrequencies.plist"];
    NSString *bundleFile = [[NSBundle mainBundle]pathForResource:@"noteFrequencies" ofType:@"plist"];
    
    //copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:noteFrequencies error:nil];
    
    noteFrequencyArray = [NSArray arrayWithContentsOfFile:noteFrequencies];

    return self;
}
- (void)saveData{
        
    //Intermediary store of samples from buffer
    sampleArray         = [NSMutableArray arrayWithCapacity:kArraySize];
    //Intermediary store of magnitudes from buffer
    magnitudeArray      = [NSMutableArray arrayWithCapacity:kArraySize];
    //Intermediary store of decibels from buffer
    decibelArray        = [NSMutableArray arrayWithCapacity:kArraySize];
    //Stores the dominant frequencies
    frequencyArray      = [NSMutableArray arrayWithCapacity:(kArraySize/4096)+1];
    //Store the rendered down sampleArray
    sampleData          = [NSMutableArray arrayWithCapacity:(kArraySize/100)];
    //Stores the dominant frequencies note location in the plist
    noteValueArray      = [NSMutableArray arrayWithCapacity:(kArraySize/4096)+1];

    
    int count = 0;
    //Convert samples in allocated buffers to NSNumbers in arrays so that they can be saved, loaded and manipulated in other parts of the app
    for (int i = 0; i< kArraySize; i++){
        
        //Store samples from sampleBuffer in sampleArray
        NSNumber *sampleNumber = [NSNumber numberWithFloat:sampleBuffer[i]];
        [sampleArray insertObject:sampleNumber atIndex:i];

                //Find the amplitude of the signal to use as a gate when finding the pitch
                Float32 decibels = DBOFFSET;
                Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude;
                Float32 peakValue = DBOFFSET;   
                //For each sample, get its amplitude's absolute value.
                Float32 absoluteValueOfSampleAmplitude = abs(decibelBuffer[i]);
                //For each sample's absolute value, run it through a simple low-pass filter
                // Begin low-pass filter
                currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
                previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
                Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
                // End low-pass filter
        
                Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
                //For each sample's filtered absolute value, convert it into decibels
                // For each sample's filtered absolute value in 				decibels, add an offset value that 
                //normalizes the clipping point of the device to zero.
                
                // if it's a rational number and isn't infinite
                if((sampleDB == sampleDB) && (sampleDB <= DBL_MAX && sampleDB >= -DBL_MAX)) { 
                // Keep the highest value you find.
                if(sampleDB > peakValue) peakValue = sampleDB; 
                //Crude noise gate. 
                if(peakValue > [threshold intValue]) decibels = peakValue; // final value
                if(peakValue < [threshold intValue]) decibels = DBOFFSET;
                }   
        
        //Store the amplitude from the decibelBuffer into decibelArray
        NSNumber *decibelNumber = [NSNumber numberWithFloat:decibels];
        [decibelArray insertObject:decibelNumber atIndex:i];
        
        //Store the magnitudes from the madnitudeBuffer into the magnitudeArray. Removes zeros from magnitudeBuffer.
        if (!magnitudeBuffer[i] == 0.00000) {
            //If decibel value is above threshold store the magnitude values
            if (decibels > [threshold intValue]) {
                NSNumber *magnitudeNumber = [NSNumber numberWithFloat:magnitudeBuffer[i]];
                [magnitudeArray insertObject:magnitudeNumber atIndex:count];
            }
            //If not place zeros into the magnitude
            else{
                NSNumber *magnitudeNumber = [NSNumber numberWithFloat:0.00000];
                [magnitudeArray insertObject:magnitudeNumber atIndex:count];
            }
            count++;
        }   
    }
    
    //Start variables
    int integer = 2048;
    int count1 = 1;
    int noteCounter = 0;

    //First iteration using number of callbacks
    for (int i = 0; i < (kArraySize/4096)-4; i++) {

        float dominantFrequency = 0;
        float maxIndex = 0;
        int inlinecounter = 0;
        
        //To split the magnitudeBuffer into blocks of 2048 the inner for loop uses the outer for 
        //loop to scale up variable "a" in blocks of 2048
        for (int a = (integer*i); a < (integer*count1); a++) {
            
            
            //Find domiant frequency by determining largest value in current array
            if ([[magnitudeArray objectAtIndex:a]floatValue] > dominantFrequency) {
                dominantFrequency = [[magnitudeArray objectAtIndex:a] floatValue];
                //Max index equals the index of the largets value in the array
                if(inlinecounter < 280)
                maxIndex = inlinecounter;  
                else {
                    maxIndex = maxIndex;
                }
            }
            inlinecounter++;
        }
        
        
        
        //Take the bin of the dominant frequency, multiply by buffersize divided by FFT size to get 
        //the frequency in Hz
        float currentFrequency = maxIndex * 44100/4096;
        NSNumber *frequency = [NSNumber numberWithFloat:currentFrequency];
        
        //Insert dominant frequency into frequencyArray
        [frequencyArray insertObject:frequency atIndex:i];
        
        //Takes the current dominant frequency, tests it against the frequnecies within the noteFrequencyArray to determine
        //which note value is represented by that dominant frequnecy
        for (int i = 1; i < [noteFrequencyArray count]-1; i++) {
            
            float lower             = [[noteFrequencyArray objectAtIndex:i-1] intValue];
            float higher            = [[noteFrequencyArray objectAtIndex:i+1] intValue];
            float current           = [[noteFrequencyArray objectAtIndex:i] intValue];
            float initialLowerHalf  = (current-lower)/2;
            float lowerHalf         = current-initialLowerHalf;
            float initialHigherHalf = (higher-current)/2;
            float higherHalf        = current+initialHigherHalf;
            
            //If the dominant frequency is out of range set the note value to 0 
            if (currentFrequency < 508.5 || currentFrequency > 4068.5) {
                NSNumber *noteNumber = [NSNumber numberWithInt:0];
                [noteValueArray insertObject:noteNumber atIndex:noteCounter];
            }
            //If in range set the note value to the index equalivent to the frequency range
            if (currentFrequency > lowerHalf && currentFrequency <= higherHalf) {
                NSNumber *noteNumber = [NSNumber numberWithInt:i];
                [noteValueArray insertObject:noteNumber atIndex:noteCounter];
            }
        }
        noteCounter++;
        count1++;
    }
    
    
    //Render down the sampleArray to a useable size for storage
    for (int i = 0; i< (kArraySize/100); i++){
        
        NSNumber *sampleNumber = [sampleArray objectAtIndex:i*100];
        [sampleData insertObject:sampleNumber atIndex:i];
    }
    
    //Location of the documents directory
    NSArray *documentPath           = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder        = [documentPath objectAtIndex:0];
    
    //The below variable is an instance of the NSString class and is declared in the .h file 
    plistFile = [documentFolder stringByAppendingPathComponent:@"Storage.plist"];
    
    //Path to the plist file
    NSString *bundleFile            = [[NSBundle mainBundle]pathForResource:@"Storage" ofType:@"plist"];
    
    //Copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:plistFile error:nil];
    //Create unique names for the arrays using date values set in the master view controller
    NSString *sampleIndex           = [NSString stringWithFormat:@"sample_%@",saveDate];
    NSString *frequencyIndex        = [NSString stringWithFormat:@"frequency_%@",saveDate];
    NSString *noteIndex             = [NSString stringWithFormat:@"note_%@",saveDate];
    //Copy the contents of the plist to an NSDictionary
    NSMutableDictionary *addData    = [NSMutableDictionary dictionaryWithContentsOfFile:plistFile];
    
    
    //Modify the NSDictionary by adding the new objects
    [addData setObject:sampleData forKey:sampleIndex];
    [addData setObject:frequencyArray forKey:frequencyIndex];
    [addData setObject:noteValueArray forKey:noteIndex];

    //finally saving the changes made to the file
    [addData writeToFile:plistFile atomically:YES];

    printf("Data saved");
     
}
     
//Set inital ASBD information
- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
    format->mSampleRate = 44100.00;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags =  kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format->mChannelsPerFrame = 1; // mono
    format->mBitsPerChannel = 16;
    format->mFramesPerPacket = 1;
    format->mBytesPerPacket = 2;
    format->mBytesPerFrame = 2; // not used, apparently required
    format->mReserved = 0;
}

//Start recording, called from master view controller with filePath declared using the date
- (void) startRecording: (NSString *) filePath
{
    [self setupAudioFormat:&recordState.dataFormat];
    fileURL =  CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *)
                                                        [filePath UTF8String], [filePath length], NO);
    recordState.currentPacket = 0;
        
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                HandleInputBuffer,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    if (status != 0) {
        printf("Could not establish new queue\n");
        return;
    }
    status = AudioFileCreateWithURL(fileURL,
                                    kAudioFileCAFType,
                                    &recordState.dataFormat,
                                    kAudioFileFlags_EraseFile,
                                    &recordState.audioFile);
    if (status != 0)
    {
        printf("Could not create file to record audio\n");
        return;
    }
  
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        status = AudioQueueAllocateBuffer(recordState.queue,
                                          8192,
                                          &recordState.buffers[i]);
        if (status) {
            printf("Error allocating buffer %d\n", i);
            return;
        }
        status = AudioQueueEnqueueBuffer(recordState.queue,
                                         recordState.buffers[i], 0, NULL);
        if (status) {
            printf("Error enqueuing buffer %d\n", i);
            return;
        }
    }
    status = SetMagicCookieForFile(recordState.queue, recordState.audioFile);
    if (status != 0)
    {
        printf("Magic cookie failed\n");
        return;
    }
    status = AudioQueueStart(recordState.queue, NULL);
    if (status != 0)
    {
        printf("Could not start Audio Queue\n");
        return;
    }
    recordState.currentPacket = 0;
    recordState.recording = YES;
    return;
}
//Called while recording is displayed to display recording indicator on master view controller
-(void) hudDisplay{
    while (recordState.recording == YES) {
    }
    if (recordState.recording == NO) {
        printf("recording ending");
    }
}
//Called while saving is displayed to display recording indicator on master view controller
-(void) hudDisplaySaving{
    printf("savingCALLED");    
    int i = 1;
    while (i == 1) {
        
    }
    
    if (recordState.saving == YES) {
        printf(" saving");
    }
    if (recordState.saving == NO) {
        printf("not saving");
    }

}
//Stop, flush and dispose of audio queue
- (void) reallyStopRecording
{
    recordState.saving = YES;
    recordState.recording = NO;
    AudioQueueFlush(recordState.queue);
    AudioQueueStop(recordState.queue, NO);
    SetMagicCookieForFile(recordState.queue, recordState.audioFile);
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        
        AudioQueueFreeBuffer(recordState.queue,
                             recordState.buffers[i]);
    }
    AudioQueueDispose(recordState.queue, YES);
    AudioFileClose(recordState.audioFile);
    
}
//Stop recording and change recordState variables 
- (void) stopRecording
{
    recordState.saving = YES;
    recordState.recording = NO;

}

- (void) toggleRecording: (NSString *) fileInit
{
    NSString *filePath = [NSString stringWithFormat:@"%@",fileInit];
    
    if(!recordState.recording)
    {
        printf("Starting recording\n");
        [self startRecording: filePath];
    }
    else
    {
        //printf("Stopping recording\n");
        [self stopRecording];
    }
}

- (BOOL) isRecording
{
    return recordState.recording;
}


@end
