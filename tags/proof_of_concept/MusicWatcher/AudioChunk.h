//
//  AudioChunk.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AudioChunk : NSObject {
	NSMutableArray* ourSamples;
	int ourChannels;
}

-(NSArray*)channel:(int)chanNum;
-(int)numChannels;

@end
