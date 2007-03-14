//
//  FFT.m
//  MusicWatcher
//
//  Created by Tyler Riddle on 2/28/07.
//  Copyright 2007 Tyler Riddle. All rights reserved.
//

//not sure why this isn't working correctly - the FFT is giving the data below the center mirrored on the data above the center - low pass filtering solves this for now

#import <math.h>

#import "FFTEngine.h"
#import "FFT.h"

//even the low pass filter isn't working right! this is really filtering at 10k
#define LOW_PASS_FILTER 0

void makeMagnitudes(float*, float*, int, float*, int);
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
	
	//generate the freq list
	[self frequencies];
	
	[self makeScaleValues];
	
	FFTAnswer = malloc(sizeof(float) * freqSize);
	
	return self;
}

-(void) dealloc {
	vDSP_destroy_fftsetup(fftSetup);
	free ( obtainedReal );
	free ( originalReal );
	free ( A.realp );
	free ( A.imagp );
	free (FFTAnswer);
	free (freqAnswer);
	free (scaleValues);
	
	[super dealloc];
}

-(NSArray*) frequencies {
	int i;

	freqSize = fftSize / 2 + 1;
	
	if (freqAnswer != nil) {
		return freqAnswer;
	}
	
	freqAnswer = malloc(sizeof(float) * freqSize);
	
	for(i = 0; i < freqSize; i++) {
		float oneValue = (float)i / fftSize * sampleRate;
		freqAnswer[i] = oneValue;
	}
	
	return freqAnswer;
}

-(int) freqSize {
	return freqSize;
}

-(float *)doEasyFFT:(float [])PCM size:(int)size {
	//why doesn't the apple suplied example work?
	//float scale = (float)1.0/(2*fftSize);
	float scale = (float)1/(4*fftSizeDamnApple);
	int offset = 0;
	int i;
	
	if (size != fftSize) {
		NSLog(@"FFTW: sample count of %i was not %i", size, fftSize);
		return nil;
	}

	//NSLog(@"here %i", borked++);
	
	//FIXME - this might be the problem, should we really increment by 2?
	for(i = 0; i < fftSize; i += 2) {
		originalReal[i] = PCM[offset];
		offset++;
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
	
	makeMagnitudes(FFTAnswer, obtainedReal, fftSize, [self frequencies], LOW_PASS_FILTER);
	//NSLog(@"here %i", borked++);

	[self scale];

	return FFTAnswer;
}	

-(void) makeScaleValues {
	int i;
	
	scaleValues = malloc(sizeof(float) * freqSize);
		
	for(i = 0; i < freqSize; i++) {
		float freq = freqAnswer[i];
		float correction = solveOneA(freq);
		
		//NSLog(@"correction is: %f freq is %f", correction, freq);
		
		if (freq < 10000) {
			scaleValues[i] = correction;
		} else {
			scaleValues[i] = 1.0;
		}
	}
}

-(void) scale {
	int i;
	
	for(i = 0; i < freqSize; i++) {
		float correction = scaleValues[i];
		float oneValue = FFTAnswer[i];
		float newValue;
		
		newValue = oneValue * correction;
		
		//NSLog(@"one: %f new: %f correction: %f", oneValue, newValue, correction);
		
		//NSLog(@"one value: %f new value: %f max reading: %f", oneValue, newValue, (float)maxReading);

		FFTAnswer[i] = newValue;
	}
}


@end

void makeMagnitudes(float* answer, float* result, int size, float* freqs, int lowPassFilter) {
	int i;
	int answerOffset = 0;
	
	//FIXME - again, should we really increment by 2?
	for(i = 0; i < size; i += 2) {
		double oneResult;
		float freq = freqs[i];
		
		if (lowPassFilter && freq > lowPassFilter) {
			break;
		}
		
		
		oneResult = sqrt((result[i] * result[i]) + (result[i + 1] * result[i + 1]));
		
		answer[answerOffset] = oneResult;
		answerOffset++;
	}
}

//solve the A curve for a single frequency
float solveOneA(float freq) {
	float term1 = (freq * freq) + (20.6 * 20.6);
	float term2 = (freq * freq) + + (12200.0 * 12200.0);
	float term3 = sqrt((freq * freq) + (107.7 * 107.7));
	float term4 = sqrt((freq * freq) + (737.9 * 737.9));
	float answer = (12200.0 * 12200.0) * (freq * freq * freq * freq) / (term1 * term2 * term3 * term4);
	
	return answer;
}

