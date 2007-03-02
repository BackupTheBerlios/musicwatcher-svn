#import "Controller.h"

#define FRAMES_PER_SECOND 30
//FFT_SIZE is in powers of 2
//for the apple FFT
#define FFT_SIZE 9
//for FFTW
//#define FFT_SIZE 512

NSArray* mean(NSArray *);

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
	NSLog(@"requested seek to %f", [sender floatValue]);
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
	NSMutableArray* leftFftValues = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray* rightFftValues = [[[NSMutableArray alloc] init] autorelease];
	int count = [chunks count];
	int i;
	
	if (count == 0) {
		return;
	}
	
	for(i = 0; i < count; i++) {
		NSArray* leftFftResult;
		NSArray* rightFftResult;
		
		[volumeGraph addXData:[[chunks objectAtIndex:i] mix]];
		
		leftFftResult = [ourFFT doEasyFFT:[[chunks objectAtIndex:i] channel:0]];
		rightFftResult = [ourFFT doEasyFFT:[[chunks objectAtIndex:i] channel:1]];
		
		[leftFftValues addObject:leftFftResult];
		[rightFftValues addObject:rightFftResult];
	}
	
	[leftSpectrumGraph setXData:mean(leftFftValues)];
	[rightSpectrumGraph setXData:mean(rightFftValues)];
	
	[playPosition setFloatValue:[ourPlayer playbackPosition]];
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
	
	[leftSpectrumGraph reset];
	[rightSpectrumGraph reset];
	[volumeGraph reset];
	
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

NSArray* mean(NSArray *arrays) {
	NSMutableArray* retVal = [[[NSMutableArray alloc] init] autorelease];
	int count = [[arrays objectAtIndex:0] count];
	int numArrays = [arrays count];
	int i, j;
	
	for(i = 0; i < count; i++) {
		float sum = 0;
		
		for(j = 0; j < numArrays; j++) {
			sum += [[[arrays objectAtIndex:j] objectAtIndex:i] floatValue];
		}
		
		sum = sum / numArrays;
		
		[retVal addObject:[NSNumber numberWithFloat:sum]];
	}
	
	return retVal;
}
