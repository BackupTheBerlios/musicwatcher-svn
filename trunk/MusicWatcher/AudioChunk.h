//
//  AudioChunk.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AudioChunk : NSObject {
	int ourChannels;
	float** audioData;
	float* mixedAudioData;
	int audioDataSize;
}

-(id)initWithPCM:(float *)pcm size:(int)size channels:(int)channels;
-(float *)channel:(int)chanNum;
-(float *)mix;
-(int)numChannels;

@end
