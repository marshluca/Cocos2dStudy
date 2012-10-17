//
//  FirstScene.m
//  ScenesAndLayers
//
//  Created by Lin Zhang on 12-10-17.
//
//

#import "FirstScene.h"
#import "SecondScene.h"

@implementation FirstScene

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [FirstScene node];
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
    
    [SecondScene simulateLongLoadingTime];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"First Scene" fontName:@"Marker Felt" fontSize:32];
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

#pragma mark Touch Methods

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCTransitionSlideInB *transition = [CCTransitionSlideInB transitionWithDuration:3 scene:[SecondScene scene]];
    [[CCDirector sharedDirector] replaceScene:transition];
}

@end
