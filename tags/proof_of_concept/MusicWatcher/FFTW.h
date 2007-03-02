//
//  FFTW.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

//A class that performs an FFT and scales the output with the A curve

#import <Cocoa/Cocoa.h>

#import <FFTW3/fftw3.h>

#import "FFTEngine.h"

@interface FFTW : FFTEngine {
	double* fftInput;
	fftw_complex* fftResult;
	fftw_plan fftPlan;
	int fftSize;
	float maxReading;
	int sampleRate;
	NSMutableArray* scaleValues;
}

@end
