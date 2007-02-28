//
//  FFTW.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <FFTW3/fftw3.h>

@interface FFTW : NSObject {
	double* fftInput;
	fftw_complex* fftResult;
	fftw_plan fftPlan;
	int fftSize;
	float maxReading;
	int sampleRate;
	NSMutableArray* scaleValues;
}

@end
