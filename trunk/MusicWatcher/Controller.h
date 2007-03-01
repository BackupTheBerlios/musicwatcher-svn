/* Controller */

#import <Cocoa/Cocoa.h>

#import "QTSoundFilePlayer.h"
#import "SampleBuffer.h"
#import "MovingLineGrapher.h"
#import "BarGrapher.h"
#import "FFTEngine.h"
#import "FFT.h"
#import "FFTW.h"

@interface Controller : NSObject
{
    IBOutlet NSTextField* fileDisplay;
	IBOutlet MovingLineGrapher* volumeGraph;
	IBOutlet BarGrapher* leftSpectrumGraph;
	IBOutlet BarGrapher* rightSpectrumGraph;
	IBOutlet NSWindow* mainWindow;
	IBOutlet NSButton* pauseButton;
	IBOutlet NSButton* playButton;
	IBOutlet NSButton* stopButton;
	
	QTSoundFilePlayer* ourPlayer;
	SampleBuffer* sampleBuffer;
	NSTimer* interfaceUpdateTimer;
	FFTEngine* ourFFT;
	BOOL stopRequested;
	float graphScale;
	
}
- (IBAction)pauseButton:(id)sender;
- (IBAction)playButton:(id)sender;
- (IBAction)stopButton:(id)sender;
- (IBAction)graphScale:(id)sender;
@end
