//
//  BarGrapher.h
//  Musilyzer
//
//  Created by Tyler Riddle on 2/25/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Grapher.h"

@interface BarGrapher : Grapher {
	NSMutableArray* peakValues;
	float yMax;
}

-(void)setYMax:(float)newMax;

@end
