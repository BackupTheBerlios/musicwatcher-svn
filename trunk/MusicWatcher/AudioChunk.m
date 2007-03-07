//
//  AudioChunk.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "AudioChunk.h"

float ** splitPCM(float*, int, int);

@implementation AudioChunk

-(id)initWithPCM:(float *)pcm size:(int)size channels:(int)channels {
	self = [self init];
	
	audioDataSize = size;
	audioData = splitPCM(pcm, size, channels);
	ourChannels = channels;
	
	mixedAudioData = malloc(sizeof(float) * size / channels);
	
	return self;
}

-(void) dealloc {
	if (audioData != nil) {
		int i;
		
		for(i = 0; i < ourChannels; i++) {
			free(audioData[i]);
		}
		
		free(audioData);
	}
	
	if (mixedAudioData != nil) {
		free(mixedAudioData);
	}
	
	[super dealloc];
}

//this returns the size of each channel or the channels mixed together
-(int)size {
	return audioDataSize / ourChannels;
}

-(float *)channel:(int)chanNum {
	return audioData[chanNum];
}

-(int)numChannels {
	return ourChannels;
}

//FIXME - should this use RMS instead of a mean?
-(float *)mix {
	int count = [self size];
	int i, j;
	
	for(i = 0; i < count; i++) {
		float mixed = 0;
		
		for(j = 0; j < ourChannels; j++) {
			mixed += audioData[j][i];
		}
		
		mixed = mixed / ourChannels;
				
		mixedAudioData[i] = mixed;
	}
	
	
	return mixedAudioData;
}

@end

float ** splitPCM(float* audio, int size, int channels) {
	float** retVal = malloc(sizeof(float *) * channels);
	int i;
	int offset = 0;
	
	for(i = 0; i < channels; i++) {
		retVal[i] = malloc(size / channels);
	}
	
	for(i = 0; i < size; i++) {
		int channel = i % channels;
				
		retVal[channel][offset] = audio[i];
		
		if (channel == channels) {
			offset++;
		}
	
		//NSLog(@"stuffed %f", audio[i]);
	}
	
	return retVal;
}