//
//  Grapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "Grapher.h"

#import <string.h>

#define DOT_SIZE 10
#define SIDE_ADJUSTER_X_OFFSET 10
#define SIDE_ADJUSTER_X_SIZE 5
#define SIDE_ADJUSTER_Y_OFFSET 10

@implementation Grapher

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	
	return self;
}

-(void)dealloc {
	if (yData != nil) {
		[yData release];
	}
	
	if (xData != nil) {
		free(xData);
	}
	
	[super dealloc];
}


- (void) setYData:(NSMutableArray *)data {
	if (yData != nil) {
		[yData release];
	}
	
	yData = data;
	
	[yData retain];
		
	[self setNeedsDisplay:YES];
}

- (void) setXData:(float *)data size:(int)size{
	int i;
	
	if (xDataSize != size) {
		if (xData != nil) {
			free(xData);
		}
				
		xData = malloc(sizeof(float) * size);
		xDataSize = size;
	}
	
	for(i = 0; i < size; i++) {
		xData[i] = data[i];
	}
		
	[self setNeedsDisplay:YES];
}

-(void)setYMax:(float)maxValue {
	yMax = maxValue;
}

- (void)drawRect:(NSRect)viewArea {
	[[NSColor blackColor] set];
	NSRectFill(viewArea);
}

@end
