//
//  Grapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "Grapher.h"


@implementation Grapher

- (void) drawRect:(NSRect)viewSize {
	[[NSColor blackColor] set];
	NSRectFill(viewSize);
}


- (void) setYData:(NSMutableArray *)data {
	if (yData != nil) {
		[yData release];
	}
	
	yData = data;
	
	[yData retain];
		
	[self setNeedsDisplay:YES];
}

- (void) setXData:(NSMutableArray *)data {
	if (xData != nil) {
		[xData release];
	}
	
	xData = data;
		
	[xData retain];
	
	[self setNeedsDisplay:YES];
}

@end
