//
//  FFT.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/28/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

//not sure why this isn't working correctly

#import <math.h>

#import "FFT.h"

NSMutableArray* makeMagnitudes(float*, int);
float solveOneA(float);

@implementation FFT

-(id) initWithFFTSize:(int)size sampleRate:(int)rate {
	self = [self init];
	
	sampleRate = rate;
	fftSize = 512; //FIXME - WTF is this returning 511? exp2(size);
	fftSizeDamnApple = size;
	
	A.realp = (float*) malloc(fftSize / 2 * sizeof(float));
	A.imagp = (float*) malloc(fftSize / 2 * sizeof(float));
	originalReal = ( float* ) malloc ( fftSize * sizeof (float));
	obtainedReal = ( float* ) malloc ( fftSize * sizeof (float));

	if ( originalReal == NULL || A.realp == NULL || A.imagp ==  NULL  )
	{
		NSLog(@"could not malloc data for FFT");
		[NSApp terminate];
	}
	
	fftSetup = vDSP_create_fftsetup ( fftSizeDamnApple, FFT_RADIX2);
	
	[self makeScaleValues];
	
	return self;
}

-(void) dealloc {
	vDSP_destroy_fftsetup(fftSetup);
	free ( obtainedReal );
	free ( originalReal );
	free ( A.realp );
	free ( A.imagp );
	
	[super dealloc];
}

-(NSArray*) frequencies {
	NSMutableArray* freqs = [[[NSMutableArray alloc] init] autorelease];
	int i;
	
	for(i = 0; i < fftSize / 2 + 1; i++) {
		int oneValue = (float)i / fftSize * sampleRate;
		[freqs addObject:[NSNumber numberWithInt:oneValue]];
	}
	
	return freqs;
}

-(NSArray*)doEasyFFT:(NSArray *)samples {
	NSMutableArray *retVal;
	//why doesn't the apple suplied example work?
	//float scale = (float)1.0/(2*fftSize);
	float scale = (float)1.0/(4*fftSizeDamnApple);
	int i;
	int borked = 0;
	
	if ([samples count] != fftSize) {
		NSLog(@"FFTW: sample count of %i was not %i", [samples count], fftSize);
		return nil;
	}

	//NSLog(@"here %i", borked++);
	
	for(i = 0; i < fftSize; i += 2) {
		originalReal[i] = [[samples objectAtIndex:i] floatValue];
	}
	
	//NSLog(@"here %i", borked++);
	
	vDSP_ctoz ( ( COMPLEX * ) originalReal, 2, &A, 1, fftSize / 2 );
	
	//NSLog(@"here %i", borked++);

	
	vDSP_fft_zrip ( fftSetup, &A, 1, fftSizeDamnApple, FFT_FORWARD );
	
	//NSLog(@"here %i", borked++);
	
	vDSP_vsmul( A.realp, 1, &scale, A.realp, 1, fftSize / 2 );
	vDSP_vsmul( A.imagp, 1, &scale, A.imagp, 1, fftSize / 2 );
	//NSLog(@"here %i", borked++);
	
	
	//FIXME - this might be wrong
	vDSP_ztoc ( &A, 1, ( COMPLEX * ) obtainedReal, 2, fftSize / 2 );
	//NSLog(@"here %i", borked++);
	
	retVal = makeMagnitudes(obtainedReal, fftSize);
	//NSLog(@"here %i", borked++);

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
		
		//NSLog(@"correction is: %f freq is %f", correction, freq);
		
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
		
		newValue = oneValue * correction;
		
		//NSLog(@"one: %f new: %f correction: %f", oneValue, newValue, correction);
		
		//NSLog(@"one value: %f new value: %f max reading: %f", oneValue, newValue, (float)maxReading);
		
		[data replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newValue]];
	}
}


@end

NSMutableArray* makeMagnitudes(float* result, int size) {
	NSMutableArray* retVal = [[[NSMutableArray alloc] init] autorelease];
	int i;
	
	for(i = 0; i < size; i += 2) {
		double oneResult = sqrt((result[i] * result[i]) + (result[i + 1] * result[i + 1]));
		
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
	
	return answer;
}

