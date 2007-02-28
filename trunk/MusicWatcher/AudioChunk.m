//
//  AudioChunk.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "AudioChunk.h"


@implementation AudioChunk

-(id)initWithSamples:(NSArray *)samples channels:(int)channels {
	self = [self init];
	int count = [samples count];
	int sampleNum = 0;
	int i;
	
	ourChannels = channels;
	ourSamples = [[NSMutableArray alloc] init];
	
	for(i = 0; i < ourChannels; i++) {
		[ourSamples addObject:[[[NSMutableArray alloc] init] autorelease]];
	}
	
	//split apart the samples into their channels
	for(i = 0; i < count; i++) {
		int arrayNum = sampleNum % channels;
		
		[[ourSamples objectAtIndex:arrayNum] addObject:[samples objectAtIndex:i]];
				
		sampleNum++;
	}
	
	return self;
}

-(void) dealloc {
	if (ourSamples != nil) {
		[ourSamples release];
	}

	[super dealloc];
}

-(NSArray*)channel:(int)chanNum {
	return [ourSamples objectAtIndex:chanNum];
}

-(int)numChannels {
	return ourChannels;
}

@end
