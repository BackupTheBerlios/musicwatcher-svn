//
//  Grapher.m
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import "Grapher.h"

#define DOT_SIZE 10
#define SIDE_ADJUSTER_X_OFFSET 10
#define SIDE_ADJUSTER_X_SIZE 5
#define SIDE_ADJUSTER_Y_OFFSET 10

@implementation Grapher

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	
	yMax = 1.0;
	draggingSideDot = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(barGrapherDidChangeYScale:) name:@"BarGrapherDidChangeYScale" object:nil];
	
	return self;
}

-(void) barGrapherDidChangeYScale:(NSNotification *)theNotification {
	float newScale = [[[theNotification userInfo] objectForKey:@"newValue"] floatValue];

	if (draggingSideDot) {
		//we sent the notification
		return;
	}
	
	yMax = newScale;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)resetCursorRects
{
    [self discardCursorRects];
	[self addTrackingRect:[self visibleRect] owner:self userData:nil assumeInside:NO];
}

- (void)mouseEntered:(NSEvent *)theEvent {
	showAdjuster = YES;
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	showAdjuster = NO;
	[self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)event {
	NSPoint clickLocation;
	NSRect sideDotRect = [self sideDotRect];
    
	clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (NSPointInRect(clickLocation, sideDotRect)) {
		draggingSideDot = YES;
	}

	[self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)event
{
    if (draggingSideDot) {
		NSRect viewSize = [self bounds];
		NSPoint newDragLocation=[self convertPoint:[event locationInWindow] fromView:nil];
		float sliderSpan = viewSize.size.height - SIDE_ADJUSTER_Y_OFFSET * 2;
		float adjustedMouseY = newDragLocation.y - SIDE_ADJUSTER_Y_OFFSET * 2 + DOT_SIZE;
		float newScale = adjustedMouseY / sliderSpan;
		NSMutableDictionary* userInfo = [[[NSMutableDictionary alloc] init] autorelease];
		
		if (newScale > 1) {
			newScale = 1;
		} else if (newScale <= 0) {
			newScale = 0.001;
		}
		
		yMax = newScale;
		
		[userInfo setObject:[NSNumber numberWithFloat:newScale] forKey:@"newValue"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"BarGrapherDidChangeYScale" object:self userInfo:userInfo];
		
		[self setNeedsDisplay:YES];
	}
}

-(void)mouseUp:(NSEvent *)event {
	draggingSideDot = NO;
	[self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)viewSize {
	[[NSColor blackColor] set];
	
	NSRectFill(viewSize);
}

- (void) drawAdjuster {
	[self drawSideAdjuster];
}

- (void) drawSideAdjuster {
	NSRect viewSize = [self bounds];
	float xOffset = SIDE_ADJUSTER_X_OFFSET;
	float xSize = SIDE_ADJUSTER_X_SIZE;
	float yOffset = SIDE_ADJUSTER_Y_OFFSET;
	float ySize = viewSize.size.height - yOffset * 2;
	//float dotXSize = DOT_SIZE;
	//float dotXOffset = xOffset - dotXSize * .25;
	//float dotYSize = DOT_SIZE;
	//float dotYOffset = ySize * yMax - dotYSize * .5 + yOffset;
	NSRect adjusterRect = NSMakeRect(xOffset, yOffset, xSize, ySize);
	//NSRect dotRect = NSMakeRect(dotXOffset, dotYOffset, dotXSize, dotYSize);
	NSRect dotRect = [self sideDotRect];
	[NSBezierPath strokeRect:adjusterRect];
	[[NSBezierPath bezierPathWithOvalInRect:dotRect] fill];
}

- (NSRect) sideDotRect {
	NSRect viewSize = [self bounds];
	float ySize = viewSize.size.height - SIDE_ADJUSTER_Y_OFFSET * 2;
	float dotXSize = DOT_SIZE;
	float dotXOffset = SIDE_ADJUSTER_X_OFFSET - dotXSize * .25;
	float dotYSize = DOT_SIZE;
	float dotYOffset = ySize * yMax - dotYSize * .5 + SIDE_ADJUSTER_Y_OFFSET;

	return NSMakeRect(dotXOffset, dotYOffset, dotXSize, dotYSize);
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

-(void)setYMax:(float)maxValue {
	NSLog(@"setting new max to %f", maxValue);
	yMax = maxValue;
}

-(float)leftDrawingOffset {
	if (showAdjuster) {
		return (float)SIDE_ADJUSTER_Y_OFFSET + (float)SIDE_ADJUSTER_Y_OFFSET / 2;
	} else {
		return 0;
	}
}

-(void)reset {
	[xData removeAllObjects];
	[yData removeAllObjects];
	
	[self setNeedsDisplay:YES];
}

@end
