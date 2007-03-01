//
//  BarGrapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "BarGrapher.h"

#define BAR_SPACING .1
#define PEAK_VERTICAL_SIZE .01
#define PEAK_FALL .005

void zeroArray(NSMutableArray*, int);

@implementation BarGrapher

-(void) awakeFromNib {
	peakValues = [[NSMutableArray alloc] init];
	yMax = 1.0;
}

-(void) dealloc {
	if (peakValues != nil) {
		[peakValues release];
	}
	
	[super dealloc];
}


- (void)drawRect:(NSRect)viewArea {
	float leftOffset = [self leftDrawingOffset];
	int dataSize = [xData count];
	float fullWidth = (viewArea.size.width - leftOffset) / dataSize;
	float barWidth = fullWidth - (fullWidth * BAR_SPACING * 2);
	int i = 0;
			
	[super drawRect:viewArea];
		
	[[NSColor whiteColor] set];
	
	if ([peakValues count] < dataSize) {
		zeroArray(peakValues, dataSize);
	}
	
	for(; i < dataSize; i++) {
		float dataPoint = [[xData objectAtIndex:i] floatValue] / yMax;
		NSNumber* peakValue = [peakValues objectAtIndex:i];
		float x0 = (i * fullWidth) + barWidth / 8 + leftOffset;
		float height = dataPoint * viewArea.size.height;
		float peakHeight = viewArea.size.height * PEAK_VERTICAL_SIZE;
		float peakBottom;
		float newPeak;
		NSRect bar;
		NSRect peak;
		
		//NSLog(@"ymax is %f", yMax);
		
		if (dataPoint > [peakValue floatValue]) {
			peakValue = [NSNumber numberWithFloat:dataPoint];
			[peakValues replaceObjectAtIndex:i withObject:peakValue];
		}		
		
		peakBottom = [peakValue floatValue] * viewArea.size.height - peakHeight;
		
		bar = NSMakeRect(x0, 0, barWidth, height);
		peak = NSMakeRect(x0, peakBottom, barWidth, peakHeight);
		
		NSRectFill(bar);
		NSRectFill(peak);
		
		newPeak = [peakValue floatValue] - PEAK_FALL;
		
		[peakValues replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newPeak]];
	}
	
	if (showAdjuster){
		[self drawAdjuster];
	}
}

@end

void zeroArray(NSMutableArray* theArray, int count) {
	int toAdd = count - [theArray count];
	int i;
	
	for(i = 0; i < toAdd; i++) {
		[theArray addObject:[NSNumber numberWithInt:0]];
	}
}