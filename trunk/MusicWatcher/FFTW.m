//
//  FFTW.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/27/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

#include <math.h>

#import "FFTW.h"

//tested by running some audio through the system, may not be accurate
#define HARD_SCALE 50 

NSArray* makeMagnitudes(fftw_complex*, int);
float solveOneA(float);

@implementation FFTW

-(id)initWithFFTSize:(int)size sampleRate:(int)rate {
	self = [self init];
	
	maxReading = 0.0;
	fftSize = size;
	sampleRate = rate;
	
	fftInput = fftw_malloc(sizeof(double) * fftSize);
	fftResult = fftw_malloc(sizeof(fftw_complex) * fftSize);
	
	if (fftInput == NULL) {
		NSLog(@"could not malloc fftInput");
		[NSApp terminate];
	}
	
	if (fftResult == NULL) {
		NSLog(@"could not malloc fftResult");
		[NSApp terminate];
	}
	
	fftPlan = fftw_plan_dft_r2c_1d(fftSize, fftInput, fftResult, FFTW_MEASURE);
	
	[self makeScaleValues];
	
	return self;
}

-(void) dealloc {
	fftw_destroy_plan(fftPlan);
	
	if (fftInput != nil) {
		fftw_free(fftInput);
	}

	if (fftResult != nil) {
		fftw_free(fftResult);
	}
	
	[super dealloc];
}

-(NSArray*) frequencies {
	NSMutableArray* freqs = [[[NSMutableArray alloc] init] autorelease];
	int i;
	
	for(i = 0; i < fftSize / 2 + 1; i++) {
		int oneValue = (float)i / fftSize * sampleRate;
		[freqs addObject:[NSNumber numberWithInt:oneValue]];
		
		NSLog(@"freq is %i", oneValue);
	}
		
	return freqs;
}

-(NSArray*)doEasyFFT:(NSArray *)samples {
	NSMutableArray *retVal;
	int i;
	
	if ([samples count] != fftSize) {
		NSLog(@"FFTW: sample count of %i was not %i", [samples count], fftSize);
		return nil;
	}
	
	for(i = 0; i < fftSize; i++) {
		fftInput[i] = [[samples objectAtIndex:i] doubleValue];
	}
	
	fftw_execute(fftPlan);
	
	retVal = makeMagnitudes(fftResult, fftSize / 2 + 1);
	
	[self scale:retVal];
	
	return retVal;
}

-(void) makeScaleValues {
	NSArray* freqs = [self frequencies];
	int count = [freqs count];
	int i;
	
	scaleValues = [[NSMutableArray alloc] init];
	
	for(i = 0; i < count; i++) {
		float freq = [[freqs objectAtIndex:i] floatValue];
		float correction = solveOneA(freq);
		
		//NSLog(@"correction is: %f", correction);
		
		if (freq < 10000) {
			[scaleValues addObject:[NSNumber numberWithFloat:correction]];
		} else {
			[scaleValues addObject:[NSNumber numberWithFloat:1.0]];
		}
				
	}
}

-(void) scale:(NSMutableArray*)data {
	int count = [data count];
	int i;

	for(i = 0; i < count; i++) {
		float correction = [[scaleValues objectAtIndex:i] floatValue];
		float oneValue = [[data objectAtIndex:i] floatValue];
		float newValue;
		
		newValue = oneValue / (float)HARD_SCALE;
		newValue = newValue * correction;
		
		//NSLog(@"one: %f new: %f correction: %f", oneValue, newValue, correction);
		
		//NSLog(@"one value: %f new value: %f max reading: %f", oneValue, newValue, (float)maxReading);
		
		[data replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newValue]];
	}
}

@end

NSArray* makeMagnitudes(fftw_complex* result, int size) {
	NSMutableArray* retVal = [[[NSMutableArray alloc] init] autorelease];
	int i;
		
	for(i = 0; i < size; i++) {
		double oneResult = sqrt((result[i][0] * result[i][0]) + (result[i][1] * result[i][1]));
				
		[retVal addObject:[NSNumber numberWithDouble:oneResult]];
	}
	
	return retVal;
}

float solveOneA(float freq) {
	float term1 = (freq * freq) + (20.6 * 20.6);
	float term2 = (freq * freq) + + (12200.0 * 12200.0);
	float term3 = sqrt((freq * freq) + (107.7 * 107.7));
	float term4 = sqrt((freq * freq) + (737.9 * 737.9));
	float answer = (12200.0 * 12200.0) * (freq * freq * freq * freq) / (term1 * term2 * term3 * term4);
		
	NSLog(@"term1: %f term2: %f term3: %f term4: %f freq: %f", term1, term2, term3, term4, freq);
	NSLog(@"answer: %f", answer);
	
	return answer;
}
