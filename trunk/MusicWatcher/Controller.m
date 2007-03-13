#import <string.h>

#import "Controller.h"

#define FRAMES_PER_SECOND 30
//FFT_SIZE is in powers of 2
//for the apple FFT
#define FFT_SIZE 9
//for FFTW
//#define FFT_SIZE 512

float* mean(float **, int, int);

@implementation Controller

- (void)awakeFromNib {
	
	sampleBuffer = [[SampleBuffer alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDropped:) name:@"FileDrop" object:nil];
	
	//FIME - this won't always be 44100
	ourFFT = [[FFT alloc] initWithFFTSize:FFT_SIZE sampleRate:44100];
	
	stopRequested = NO;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
	
	[mainWindow setDelegate:self];
	[mainWindow registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	[mainWindow setAcceptsMouseMovedEvents:YES];
	
	[fileDisplay setStringValue:@""];
	
	[stopButton setEnabled:NO];
	[pauseButton setEnabled:NO];
	[playPosition setEnabled:NO];
	
	[self startInterfaceTimer];
}

//actions
- (IBAction)pauseButton:(id)sender
{
	[self pausePlaying];
}

- (IBAction)playButton:(id)sender
{
	[self startPlaying];
}

- (IBAction)stopButton:(id)sender
{
	[self stopPlaying];
}

-(IBAction)playPosition:(id)sender {
	//NSLog(@"requested seek to %f", [sender floatValue]);
	[ourPlayer setPlaybackPosition:[sender floatValue]];
}

//notifications
- (void)fileDropped:(id)notification {
	NSString* file = [notification userInfo];
	[fileDisplay setStringValue:file];
}

//timers
- (void)updateUI:(NSTimer *)theTimer {	
	NSArray* chunks = [sampleBuffer getAudioChunks];
	int count = [chunks count];
	int size;
	int i;
	float*** FFTResults;
	
	if (count == 0) {
		return;
	}
	
	size = [ourFFT freqSize];
	
	FFTResults = malloc(sizeof(float **) * 2);
	
	for(i = 0; i < 2; i++) {
		int j;
		FFTResults[i] = malloc(sizeof(float *) * count);
		
		for(j = 0; j < count; j++) {
			FFTResults[i][j] = malloc(sizeof(float) * size);
		}
	}
	
	for(i = 0; i < count; i++) {
		AudioChunk* chunk = [chunks objectAtIndex:i];
				
		[volumeGraph addXData:[chunk mix] size:[chunk size]];
		
		memcpy(FFTResults[0][i], [ourFFT doEasyFFT:[chunk channel:0] size:[chunk size]], sizeof(float) * size);
		memcpy(FFTResults[1][i], [ourFFT doEasyFFT:[chunk channel:1] size:[chunk size]], sizeof(float) * size);
	}
	
	[leftSpectrumGraph setXData:mean(FFTResults[0], count, size) size:size];
	[rightSpectrumGraph setXData:mean(FFTResults[1], count, size) size:size];
	
	[playPosition setFloatValue:[ourPlayer playbackPosition]];
	
	for(i = 0; i < 2; i++) {
		int j;
		
		for(j = 0; j < count; j++) {
			free(FFTResults[i][j]);
		}
		
		free(FFTResults[i]);
	}
	
	free(FFTResults);
}

//delegation

//QTSoundFilePlayer delegation
- (void)qtSoundFilePlayer:(QTSoundFilePlayer *)player didFinishPlaying:(BOOL)aBool {
	if (! stopRequested) {
		[self stopPlaying];
	}
}

- (void)qtSoundFilePlayer:(QTSoundFilePlayer *)Player didPlayAudioBuffer:(AudioBuffer *)buffer {
	[sampleBuffer addAudioBuffer:buffer];
}

//NSWindow delegation
- (unsigned int) draggingEntered:(id <NSDraggingInfo>)sender {
	return NSDragOperationCopy;
}

- (unsigned int) draggingUpdated:(id <NSDraggingInfo>)sender  {
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FileDrop" object:self userInfo:[files objectAtIndex:0]];
	}
	
    return YES;
}

//library methods
- (void)startPlaying {
	NSString* file = [fileDisplay stringValue];
	float span = 1.0 / FRAMES_PER_SECOND;
	
	if (file == nil) {
		return;
	}
	
	if (ourPlayer != nil) {
		//already playing
		return;
	}
	
	ourPlayer = [[QTSoundFilePlayer alloc] initWithContentsOfFile:file];
	
	if (ourPlayer == nil) {
		NSLog(@"QTSoundFilePlayer returned nil");
		return;
	}
	
	[ourPlayer setDelegate:self];
	
	[ourPlayer play];
	
	[playPosition setMaxValue:[ourPlayer duration]];
	
	NSLog(@"duration is %f", [ourPlayer duration]);
		
	[playButton setEnabled:NO];
	[stopButton setEnabled:YES];
	[pauseButton setEnabled:YES];
	[playPosition setEnabled:YES];

}

- (void)stopPlaying {
	if (ourPlayer == nil) {
		return;
	}
	
	stopRequested = YES;
	
	if ([ourPlayer isPaused]) {
		[self startInterfaceTimer];
	}
	
	[ourPlayer stop];
	
	[ourPlayer autorelease];
	
	ourPlayer = nil;
	
	stopRequested = NO;
	
	[playPosition setFloatValue:0];
	
	[pauseButton setTitle:@"Pause"];
	
	[playButton setEnabled:YES];
	[stopButton setEnabled:NO];
	[pauseButton setEnabled:NO];
	[playPosition setEnabled:NO];
	
	//[leftSpectrumGraph reset];
	//[rightSpectrumGraph reset];
	//[volumeGraph reset];
	
	[sampleBuffer reset];
}

- (void)pausePlaying {
	if (ourPlayer == nil) {
		return;
	}
	
	if ([ourPlayer isPaused]) {
		[ourPlayer resume];
		[pauseButton setTitle:@"Pause"];
		[self startInterfaceTimer];
	} else {
		[ourPlayer pause];
		[pauseButton setTitle:@"Resume"];
		[self stopInterfaceTimer];
	}
}

-(void)startInterfaceTimer {
	float span = (float)1 / FRAMES_PER_SECOND;
	
	if (interfaceUpdateTimer == nil) {
		interfaceUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:span target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];
	}
}

-(void)stopInterfaceTimer {
	
	if (interfaceUpdateTimer != nil) {
		[interfaceUpdateTimer invalidate];
		
		interfaceUpdateTimer = nil;	
	}
}

@end

float* mean(float **data, int count, int size) {
	int i, j;
	
	for(i = 0; i < size; i++) {
		float sum = 0;
		
		for(j = 0; j < count; j++) {
			sum += data[j][i];
		}
				
		data[0][i] = sum / count;
		
	}
	
	return data[0];
}
