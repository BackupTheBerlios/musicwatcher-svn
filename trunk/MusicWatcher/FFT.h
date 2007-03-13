//
//  FFT.h
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/28/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Accelerate/Accelerate.h>


@interface FFT : FFTEngine {
	FFTSetup fftSetup;
	int fftSize;
	int fftSizeDamnApple;
	int sampleRate;
	int freqSize;
	float *FFTAnswer;
	float *freqAnswer;
	float *scaleValues;
	float *originalReal;
	float *obtainedReal;
	COMPLEX_SPLIT A;
}

@end
