//
//  Grapher.h
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Grapher : NSView {
	NSMutableArray*	xData; 
	NSMutableArray*	yData; 
	BOOL showAdjuster;
	float yMax;
	BOOL draggingSideDot;
}

- (NSRect) sideDotRect;
- (void) setYData:(NSMutableArray *)data;
- (void) setXData:(NSMutableArray *)data;
-(void)setYMax:(float)newMax;
-(float)leftDrawingOffset;

@end
