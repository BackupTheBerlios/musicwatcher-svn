/* Controller */

#import <Cocoa/Cocoa.h>

#import "QTSoundFilePlayer.h"
#import "SampleBuffer.h"
#import "MovingLineGrapher.h"
#import "BarGrapher.h"
#import "FFTW.h"

@interface Controller : NSObject
{
    IBOutlet NSTextField* fileDisplay;
	IBOutlet MovingLineGrapher* volumeGraph;
	IBOutlet BarGrapher* spectrumGraph;
	
	QTSoundFilePlayer* ourPlayer;
	SampleBuffer* sampleBuffer;
	NSTimer* interfaceUpdateTimer;
	FFTW* ourFFT;
	
}
- (IBAction)pauseButton:(id)sender;
- (IBAction)playButton:(id)sender;
- (IBAction)stopButton:(id)sender;
@end
