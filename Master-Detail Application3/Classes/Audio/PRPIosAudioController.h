//
//  PRPIosAudioController.h
//  Master-Detail Application3
//
//  Created by Phillip Parker on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

@interface PRPIosAudioController : NSObject
@property (readonly) AudioComponentInstance audioUnit;
@property (readonly) AudioBuffer tempBuffer;

- (void) start;
- (void) stop;
- (void) processAudio: (AudioBufferList*) bufferList;

@end
extern PRPIosAudioController* iosAudio;