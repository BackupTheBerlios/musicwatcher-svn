//
//  Grapher.h
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Grapher : NSView {
	float*	xData; 
	int xDataSize;
	NSMutableArray*	yData; 
	BOOL showAdjuster;
	float yMax;
}

- (void) setYData:(NSMutableArray *)data;
- (void) setXData:(float *)data size:(int)size;
-(void)setYMax:(float)newMax;

@end
