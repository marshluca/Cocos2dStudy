//
//  SecondScene.m
//  ScenesAndLayers
//
//  Created by Lin Zhang on 12-10-17.
//
//

#import "SecondScene.h"
#import "LoadingScene.h"

@implementation SecondScene

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [SecondScene node];
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    if (self = [super init])
    {
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Second Scene" fontName:@"Marker Felt" fontSize:32];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    label.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:label];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
}

- (void) onExit
{
    [super onExit];
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark Public Methods

+ (void) simulateLongLoadingTime
{
	// Simulating a long loading time by doing some useless calculation a large number of times.
	double a = 122, b = 243;
	for (unsigned int i = 0; i < 1000000000; i++)
	{
		a = a / b;
	}
}

#pragma mark Touch Methods

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    LoadingScene *loadingScene = [LoadingScene sceneWithTargetScene:TargetScenesFirstScene];
    [[CCDirector sharedDirector] replaceScene:loadingScene];
}

@end
