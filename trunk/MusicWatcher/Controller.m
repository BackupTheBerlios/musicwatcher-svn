#import "Controller.h"

#define FRAMES_PER_SECOND 30
#define FFT_SIZE 512

@implementation Controller

- (void)awakeFromNib {
	[[NSApp mainWindow] registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	[[NSApp mainWindow] setDelegate:self];
	
	if ([NSApp mainWindow] == nil) {
		NSLog(@"ah ha");
	}
	
	sampleBuffer = [[SampleBuffer alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDropped:) name:@"FileDrop" object:nil];
	
	//FIME - this won't always be 44100
	ourFFT = [[FFTW alloc] initWithFFTSize:FFT_SIZE sampleRate:44100];
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

//notifications
- (void)fileDropped:(id)notification {
	NSString* file = [notification userInfo];
	[fileDisplay setStringValue:file];
	
	NSLog(@"got a file drop: %@", file);
}

//timers
- (void)updateUI:(NSTimer *)theTimer {	
	NSArray* chunks = [sampleBuffer getAudioChunks];
	int count = [chunks count];
	int i;
	
	for(i = 0; i < count; i++) {
		NSArray* fftResult;
		
		[volumeGraph addXData:[[chunks objectAtIndex:i] channel:0]];
		
		fftResult = [ourFFT doEasyFFT:[[chunks objectAtIndex:i] channel:0]];
		
		[spectrumGraph setXData:fftResult];
	}
}

//delegation

//QTSoundFilePlayer delegation
- (void)qtSoundFilePlayer:(QTSoundFilePlayer *)player didFinishPlaying:(BOOL)aBool {
	[interfaceUpdateTimer invalidate];
	
	interfaceUpdateTimer = nil;
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
	
	[ourPlayer setDelegate:self];
	
	[ourPlayer play];
	
	interfaceUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:span target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];
}

- (void)stopPlaying {
	if (ourPlayer == nil) {
		return;
	}
	
	[ourPlayer stop];
	
	[ourPlayer autorelease];
	
	ourPlayer = nil;
}

- (void)pausePlaying {
	if (ourPlayer == nil) {
		return;
	}
	
	if ([ourPlayer isPaused]) {
		[ourPlayer resume];
	} else {
		[ourPlayer pause];
	}
}

@end
