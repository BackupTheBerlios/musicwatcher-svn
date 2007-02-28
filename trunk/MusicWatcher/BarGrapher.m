//
//  BarGrapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "BarGrapher.h"

#define BAR_SPACING .1

@implementation BarGrapher

- (void)drawRect:(NSRect)viewArea {
	int dataSize = [xData count];
	int fullWidth = viewArea.size.width / dataSize;
	float barWidth = fullWidth - (fullWidth * BAR_SPACING * 2);
	int i = 0;
		
	[super drawRect:viewArea];
		
	[[NSColor whiteColor] set];
	
	for(; i < dataSize; i++) {
		NSNumber* dataPoint = [xData objectAtIndex:i];
		float x0 = (i * fullWidth) + barWidth / 8;
		float huh = [dataPoint floatValue];
		float height = huh * viewArea.size.height;
		NSRect rect = NSMakeRect(x0, 0, barWidth, height);
		NSRectFill(rect);
		
		//NSLog(@"stuff: %f %f %f", x0, barWidth, height);
	}
	
}

@end
