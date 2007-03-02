//
//  SampleBuffer.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

//a low latency buffer on the input side for AudioBuffers from CoreAudio - we need this because the thread that stores the samples is the high-priority thread
//for feeding data into CoreAudio and it can not be busy for very long or the audio will drop out.

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudioTypes.h>

#define NUM_BUFFERS 10

@interface SampleBuffer : NSObject {
	NSLock* bufferLock;
	AudioBuffer* sampleBuffer[NUM_BUFFERS];
	int bufferCount;
}

@end
