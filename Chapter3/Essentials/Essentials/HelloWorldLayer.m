//
//  HelloWorldLayer.m
//  Essentials
//
//  Created by Lin Zhang on 12-10-3.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "MenuLayer.h"

@interface HelloWorldLayer (PrivateMethods)
- (void) onCallFunc;
- (void) onCallFuncN:(id)sender;
- (void) onCallFuncND:(id)sender data:(void *)data;
@end

@implementation HelloWorldLayer

+ (CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

- (id) init
{
	if( (self=[super init]) )
    {
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
	}
    
	return self;
}

- (void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);    
	[super dealloc];
}

- (void) onEnter
{
    [super onEnter];
    
    // winSize should be called in init function, or it is not lanscape size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // load the backgoroud sprite
    CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
    background.position = CGPointMake(size.width / 2.0, size.height / 2.0);
    background.scaleX = 3;
    // background.scaleY = 30;
    [self addChild:background];
    
    // text label
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Cocos2D" fontName:@"AppleGothic" fontSize:64];
    label.opacity = 160;
    label.position = CGPointMake(size.width / 2.0, size.height / 2.0);
    [self addChild:label];
    
    // touch label
    CCLabelTTF *touchLabel = [CCLabelTTF labelWithString:@"Touch the screen" fontName:@"AppleGothic" fontSize:32];
    touchLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 60);
    [self addChild:touchLabel];
    
    CCMoveTo *moveTo1 = [CCMoveTo actionWithDuration:3 position:ccp(size.width/2+50, size.height/2)];
    CCEaseInOut *ease1 = [CCEaseInOut actionWithAction:moveTo1 rate:4];
    
    CCCallFunc *func = [CCCallFunc actionWithTarget:self selector:@selector(onCallFunc)];
    CCCallFuncN *funcN = [CCCallFuncN actionWithTarget:self selector:@selector(onCallFuncN:)];
    CCCallFuncND *funcND = [CCCallFuncND actionWithTarget:self selector:@selector(onCallFuncND:data:) data:(void *)self];
    
    CCRotateBy *rotateBy = [CCRotateBy actionWithDuration:2 angle:360];
    CCRepeat *repeat = [CCRepeat actionWithAction:rotateBy times:2];    
    // CCRepeatForever can not be passed to CCSequence
    // CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotateBy];

    CCMoveTo *moveTo2 = [CCMoveTo actionWithDuration:3 position:ccp(size.width/2, size.height/2-60)];
    CCEaseInOut *ease2 = [CCEaseInOut actionWithAction:moveTo2 rate:4];

    CCSequence *seq = [CCSequence actions:ease1, func, funcN, funcND, repeat, ease2, nil];

    [touchLabel runAction:seq];
}

#pragma mark Private Methods
- (void) onCallFunc
{
    CCLOG(@"%@, %@", NSStringFromSelector(_cmd), self);
}

- (void) onCallFuncN:(id)sender
{
    CCLOG(@"%@, %@, %@", NSStringFromSelector(_cmd), self, sender);
}

- (void)onCallFuncND:(id)sender data:(void *)data
{
    CCLOG(@"%@, %@, %@", NSStringFromSelector(_cmd), self, data);
}

#pragma mark Touch Delegate Methods
- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"%@ - %@", NSStringFromSelector(_cmd), self);
    
    CCScene *menuScene = [MenuLayer scene];
    CCTransitionScene *tran = [CCTransitionRotoZoom transitionWithDuration:1 scene:menuScene];
    [[CCDirector sharedDirector] replaceScene:tran];
}

#pragma mark Accelerate Delegate Methods
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    
}

@end
