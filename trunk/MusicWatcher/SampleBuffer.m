//
//  SampleBuffer.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <string.h>
#import <unistd.h>

#import "SampleBuffer.h"
#import "AudioChunk.h"

AudioBuffer* copyAudioBuffer(AudioBuffer *);
void freeAudioBuffer(AudioBuffer *);
NSArray* convertToChunks(AudioBuffer* [], int);
void byte_reverse(float *, int);

@implementation SampleBuffer

-(id)init {
	self = [super init];
	
	bufferLock = [[NSLock alloc] init];
	
	return self;
}

-(void)addAudioBuffer:(AudioBuffer *)aBuffer {
	[bufferLock lock];
	
	if (bufferCount >= NUM_BUFFERS) {
		NSLog(@"No room left in sample buffer - dropping data");
	} else {
		AudioBuffer* newBuffer = copyAudioBuffer(aBuffer);
				
		sampleBuffer[bufferCount] = newBuffer;
		bufferCount++;
	}
	
	[bufferLock unlock];
}

-(void)reset {
	//getAudioChunks does a good job of resetting the buffer
	[self getAudioChunks];
}

-(NSArray*)getAudioChunks {
	AudioBuffer* tmpBuffer[NUM_BUFFERS];
	NSArray* retVal;
	int i;
	int bufSize;

	//to avoid locking the buffer very long (we want low latency on the input side) copy the buffer to a local buffer and make it available ASAP
	
	[bufferLock lock];
	
	bufSize = bufferCount;

	for(i = 0; i < bufSize; i++) {
		tmpBuffer[i] = sampleBuffer[i];
	}

	//resets the buffer for the future
	bufferCount = 0;
	
	[bufferLock unlock];
		
	//int r;
	//for(r = 0; r < 512; r++) {
	//	AudioBuffer* foo = tmpBuffer[0];
	//	float* foobar = (float *)foo->mData;
	//	NSLog(@"foobar: %f", foobar[r]);
	//}
	
		
	retVal = convertToChunks(tmpBuffer, bufSize);
	
	for(i = 0; i < bufSize; i++) {
		freeAudioBuffer(tmpBuffer[i]);
	}
		
	return retVal;
}

@end


//FIXME - this code needs to take into account different endianess and sample types (ints, floats, and sizes of each)
NSArray* convertToChunks(AudioBuffer* samples[], int count) {
	NSMutableArray* retVal = [[[NSMutableArray alloc] init] autorelease];
	int i;
	
	//iterate over each buffer
	for(i = 0; i < count; i++) {
		AudioBuffer* buf = samples[i];
		AudioChunk* newChunk;
		
		//for(r = 0; r < buf->mDataByteSize; r++) {
		//	float* foobar = (float *)buf->mData;
		//	NSLog(@"foobar: %f", foobar[r]);
		//}

		
#ifdef __LITTLE_ENDIAN__
		byte_reverse(buf->mData, buf->mDataByteSize);
#endif
		
		newChunk = [[[AudioChunk alloc] initWithPCM:buf->mData size:buf->mDataByteSize / sizeof(float) channels:buf->mNumberChannels] autorelease];
						
		[retVal addObject:newChunk];
	}
	
	return retVal;
}

AudioBuffer* copyAudioBuffer(AudioBuffer *buffer) {
	AudioBuffer* newBuffer = malloc(sizeof(AudioBuffer));
		
	*newBuffer = *buffer;
		
	newBuffer->mData = malloc(buffer->mDataByteSize);
	
	memcpy(newBuffer->mData, buffer->mData, buffer->mDataByteSize);
		
	return newBuffer;
}

void freeAudioBuffer(AudioBuffer *buffer) {
	free(buffer->mData);
	free(buffer);
}

//shamelessly stolen^H^H^H^H^Hborrowed from the Apache HTTP server project
void byte_reverse(float *buffer, int count) {
    int i;
    char ct[4], *cp;
	
	count /= sizeof(float);
	cp = (char *) buffer;
	for (i = 0; i < count; ++i) {
		ct[0] = cp[0];
		ct[1] = cp[1];
		ct[2] = cp[2];
		ct[3] = cp[3];
		cp[0] = ct[3];
		cp[1] = ct[2];
		cp[2] = ct[1];
		cp[3] = ct[0];
		cp += sizeof(float);
	}
}
