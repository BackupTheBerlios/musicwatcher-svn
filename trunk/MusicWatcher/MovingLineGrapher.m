//
//  LineGrapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "MovingLineGrapher.h"

#import <string.h>

#define GRAPH_WIDTH 4096

@implementation MovingLineGrapher

- (void)awakeFromNib {
	tmpAudioData = malloc(sizeof(float) * GRAPH_WIDTH);
}

-(void)dealloc {	
	if (tmpAudioData != nil) {
		free(tmpAudioData);
	}
	
	[super dealloc];
}

- (void)addXData:(float*)newData size:(int)size {
	int i;
	
	if (size == 0) {
		return;
	}
	
	if (size > GRAPH_WIDTH) {
		size = GRAPH_WIDTH;
	}
	
	for(i = 0; i < GRAPH_WIDTH - size; i++) {
		tmpAudioData[i] = tmpAudioData[i + size];
	}
	
	for(i = 0; i < size; i++) {
		tmpAudioData[i + GRAPH_WIDTH - size] = newData[i];
	}
	
	[self setXData:tmpAudioData size:GRAPH_WIDTH];
}

- (void)drawRect:(NSRect)viewArea {
	float pointDistance = viewArea.size.width / xDataSize;
	float viewHeight = viewArea.size.height;
	NSBezierPath* brush = [NSBezierPath bezierPath];
	int i;
	
	[super drawRect:viewArea];
	
	[[NSColor whiteColor] set];
	
	[brush moveToPoint:NSMakePoint(0, 0)];
			
	for(i = 0; i < xDataSize; i++) {
		float height = viewHeight * xData[i] / 2 + viewHeight / 2;
		float x1 = pointDistance * i;
		float y1 = height;
		NSPoint curPoint = NSMakePoint(x1, y1);
						
		[brush lineToPoint:curPoint];
	}
	
	[brush stroke];
}

@end
