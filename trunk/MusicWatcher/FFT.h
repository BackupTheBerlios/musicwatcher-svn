//
//  FFT.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/28/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>


@interface FFT : NSObject {
	FFTSetup fftSetup;
	int fftSize;
	int fftSizeDamnApple;
	int sampleRate;
	float *originalReal;
	float *obtainedReal;
	COMPLEX_SPLIT A;
	NSMutableArray* scaleValues;
}

@end
