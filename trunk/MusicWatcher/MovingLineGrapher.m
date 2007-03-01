//
//  LineGrapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "MovingLineGrapher.h"

#define GRAPH_WIDTH 4096

@implementation MovingLineGrapher

- (void)awakeFromNib {
	int i;
	
	if (xData == nil) {
		xData = [[NSMutableArray alloc] init];
	}
	
	for(i = 0; i < GRAPH_WIDTH; i++) {
		[xData addObject:[NSNumber numberWithInt:0]];
	}
}

- (void)dealloc {
	if (xData != nil) {
		[xData release];
	}
	
	[super dealloc];
}

- (void)addXData:(NSArray*)newData {
	int size;
	
	[xData addObjectsFromArray:newData];
	
	size = [xData count];
	
	if (size >= GRAPH_WIDTH) {
		int trim = size - GRAPH_WIDTH;
		
		[xData removeObjectsInRange:NSMakeRange(0, trim)];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)viewArea {
	int dataSize = [xData count];
	float pointDistance = viewArea.size.width / dataSize;
	float viewHeight = viewArea.size.height;
	int i = 0;
	NSBezierPath* brush = [NSBezierPath bezierPath];
	
	[super drawRect:viewArea];
	
	[[NSColor whiteColor] set];
	
	[brush moveToPoint:NSMakePoint(0, 0)];
		
	for(; i < dataSize; i++) {
		NSNumber* num = [xData objectAtIndex:i]; 
		float height = viewHeight * [num floatValue] / 2 + viewHeight / 2;
		float x1 = pointDistance * i;
		float y1 = height;
		NSPoint curPoint = NSMakePoint(x1, y1);
		
		//NSLog(@"new point: %f %f", x1, y1);
		
		[brush lineToPoint:curPoint];
	}
	
	[brush stroke];
}

@end
