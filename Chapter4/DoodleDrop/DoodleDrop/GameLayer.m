//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Lin Zhang on 12-10-6.
//
//

#import "GameLayer.h"
#import "SimpleAudioEngine.h"

#define kSpriteTag    11
#define kGameOverTag  22
#define kTouchTag     33

#define kDeceleration 0.4f
#define kSensitivity  6.0f
#define kMaxVelocity  100

@interface GameLayer (PrivateMethods)
- (void) initSpiders;
- (void) resetSpiders;
- (void) spidersUpdate:(ccTime)delta;
- (void) runSpiderMoveSequence:(CCSprite *)spider;
- (void) runSpiderWiggleSequence:(CCSprite *)spider;
- (void) spiderBelowScreen:(id)sender;
- (void) checkForCollision;
- (void) showGameOver;
- (void) resetGame;
@end

@implementation GameLayer

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    if (self = [super init])
    {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        self.isAccelerometerEnabled = YES;
    }
    
    return self;
}

- (void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [spiders release];
    spiders = nil;
    
    [super dealloc];
}

- (void) onEnter
{
    [super onEnter];
    
    // add sprite
    player = [CCSprite spriteWithFile:@"alien.png"];
    [self addChild:player z:0 tag:kSpriteTag];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    float imageHeight = [[player texture] contentSize].height;
    player.position = ccp(size.width/2, imageHeight/2);

    // add score label
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
    scoreLabel.position = ccp(size.width * 0.5, size.height);
    scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
    [self addChild:scoreLabel z:-1];
    
    [self scheduleUpdate];    
    [self initSpiders];
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"blues.mp3" loop:YES];
    [[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
    
    srandom(time(NULL));
}

- (void) update:(ccTime)delta
{
    // CCLOG(@"%@, %@, %f", NSStringFromSelector(_cmd), self, delta);
    
    // update score label
    totoalTime += delta;
    if (score < totoalTime)
    {
        score = totoalTime;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
    }
    
    // update player's position
    CGPoint point = player.position;
    point.x +=  playerVelocity.x;

    CGSize size = [[CCDirector sharedDirector] winSize];
    float imageWidthHalved = [player texture].contentSize.width * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = size.width -imageWidthHalved;
    
    if (point.x < leftBorderLimit)
    {
        point.x = leftBorderLimit;
        playerVelocity = CGPointZero;
    }
    else if (point.x > rightBorderLimit)
    {
        point.x = rightBorderLimit;
        playerVelocity = CGPointZero;
    }
    
    player.position = point;
    
    // check the collision to decide whether to reset spiders 
    [self checkForCollision];
}


#pragma mark Private Methods

- (void) initSpiders
{
    CCSprite *tmpSprite = [CCSprite spriteWithFile:@"spider.png"];
    float imageWidth = [tmpSprite texture].contentSize.width;
        
    CGSize size = [[CCDirector sharedDirector] winSize];
    int count = size.width / imageWidth;    
    NSAssert(spiders == nil, @"%@: spiders array is already initialized.", NSStringFromSelector(_cmd));
    spiders = [[CCArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        CCSprite *spider = [CCSprite spriteWithFile:@"spider.png"];
        [self addChild:spider z:0 tag:2];
        
        [spiders addObject:spider];
    }
    
    [self resetSpiders];
}

- (void) resetSpiders
{
    CCSprite *tmpSprite = [spiders lastObject];
    CGSize size = [tmpSprite texture].contentSize;
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    for (int i = 0; i < [spiders count]; i++)
    {
        CCSprite *spider = [spiders objectAtIndex:i];
        spider.position = CGPointMake(size.width * i + size.width * 0.5f, screenSize.height + size.height);
        spider.scale = 1.0f;
        [spider stopAllActions];
    }
    
    [self unschedule:@selector(spidersUpdate:)];
    [self schedule:@selector(spidersUpdate:) interval:0.6f];
    
    numbersOfSpiderMoved = 0;
    spiderMoveDuration = 8.0f;
}

- (void) spidersUpdate:(ccTime)delta
{
    for (int i = 0; i < 8; i++)
    {
        int randomSpiderIndex = CCRANDOM_0_1() * [spiders count];
        CCSprite *spider = [spiders objectAtIndex:randomSpiderIndex];
        if ([spider numberOfRunningActions] == 0)
        {
            if (i > 0)
            {
                CCLOG(@"Dropping a Spider after %i retries.", i);
            }
            
            [self runSpiderMoveSequence:spider];
            
            break;
        }
    }
}

- (void) runSpiderMoveSequence:(CCSprite *)spider
{
    numbersOfSpiderMoved++;    
    if (numbersOfSpiderMoved % 4 == 0 && spiderMoveDuration > 2.0f)
    {
        spiderMoveDuration -= 0.1f;
    }
    
    CGPoint belowScreenPosition = CGPointMake(spider.position.x, -[spider texture].contentSize.height);
    CCMoveTo *move = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
    CCCallFuncN *funcN = [CCCallFuncN actionWithTarget:self selector:@selector(spiderBelowScreen:)];
    CCSequence *sequence = [CCSequence actions:move, funcN, nil];
    [spider runAction:sequence];
}

- (void) runSpiderWiggleSequence:(CCSprite *)spider
{
    CCScaleTo *scale1 = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:1.2f];
    CCEaseBackInOut *ease1 = [CCEaseBackInOut actionWithAction:scale1];
    CCScaleTo *scale2 = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:0.8f];
    CCEaseBackInOut *ease2 = [CCEaseBackInOut actionWithAction:scale2];
    CCSequence *sequence = [CCSequence actions:ease1, ease2, nil];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:sequence];    
    [spider runAction:repeat];
}

- (void) spiderBelowScreen:(id)sender
{
    NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not a CCSprite");
    
    CCSprite *spider = (CCSprite *)sender;
    CGPoint point = spider.position;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    point.y = screenSize.height + [spider texture].contentSize.height;
    spider.position = point;
}

- (void) checkForCollision
{
    float playerImageSize = [player texture].contentSize.width;
    float spiderImageSize = [[spiders lastObject] texture].contentSize.width;
    float playerCollisionRadius = playerImageSize * 0.4f;
    float spiderCollisionRadius = spiderImageSize * 0.4f;
    float maxCollisionDistance = playerCollisionRadius + spiderCollisionRadius;
    
    for (int i = 0; i < [spiders count]; i++)
    {
        CCSprite *spider = [spiders objectAtIndex:i];
        if ([spider numberOfRunningActions] == 0)
        {
            continue;
        }
        
        float actualDistance = ccpDistance(player.position, spider.position);
        if (actualDistance < maxCollisionDistance)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
            [self showGameOver];
        }
    }
}

- (void) showGameOver
{
    // CCLOG(@"%@, %@", NSStringFromSelector(_cmd), self);
    
    // have each child node stop
    CCNode *node;
    CCARRAY_FOREACH([self children], node)
    {
        [node stopAllActions];
    }
    
    // have each spider scale in and out
    CCSprite *spider;
    CCARRAY_FOREACH(spiders, spider)
    {
        [self runSpiderWiggleSequence:spider];
    }
    
    self.isTouchEnabled = YES;
    self.isAccelerometerEnabled = NO;    
    [self unscheduleAllSelectors];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    // add label to show game over
    CCLabelTTF *gameOverLabel = [CCLabelTTF labelWithString:@"Game Over" fontName:@"Marker Felt" fontSize:64];
    gameOverLabel.position = ccp(screenSize.width * 0.5, screenSize.height * 0.5);
    [self addChild:gameOverLabel z:100 tag:kGameOverTag];
    
    // touch label
    CCLabelTTF *touchLabel = [CCLabelTTF labelWithString:@"tap screen to play again" fontName:@"Arial" fontSize:24];
    touchLabel.position = ccp(screenSize.width * 0.5, screenSize.height * 0.25);
    [self addChild:touchLabel z:100 tag:kTouchTag];

    // action for game over label
    CCRotateTo *rotate1 = [CCRotateTo actionWithDuration:2 angle:5];
    CCEaseBounceInOut *ease1 = [CCEaseBounceInOut actionWithAction:rotate1];    
    CCRotateTo *rotate2 = [CCRotateTo actionWithDuration:2 angle:-5];
    CCEaseBounceInOut *ease2 = [CCEaseBounceInOut actionWithAction:rotate2];
    CCSequence *sequence = [CCSequence actions:ease1, ease2, nil];
    CCRepeatForever *repeatRotate = [CCRepeatForever actionWithAction:sequence];
    [gameOverLabel runAction:repeatRotate];
    
    CCJumpBy *jump = [CCJumpBy actionWithDuration:3 position:CGPointZero height:screenSize.height * 0.3 jumps:1];
    CCRepeatForever *repeatJump = [CCRepeatForever actionWithAction:jump];
    [gameOverLabel runAction:repeatJump];
    
    // action for touch label
    CCBlink *blink = [CCBlink actionWithDuration:1 blinks:2];
    CCRepeatForever *repeatBlink = [CCRepeatForever actionWithAction:blink];
    [touchLabel runAction:repeatBlink];
}

- (void) resetGame
{
    [self removeChildByTag:kGameOverTag cleanup:YES];
    [self removeChildByTag:kTouchTag cleanup:YES];
    
    self.isTouchEnabled = NO;
    self.isAccelerometerEnabled = YES;
    
    [self resetSpiders];
    [self scheduleUpdate];
    
    score = 0;
    totoalTime = 0;
    [scoreLabel setString:@"0"];
}


// Only draw this debugging information in, well, debug builds.
-(void) draw
{
#if DEBUG
	// Iterate through all nodes of the layer.
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		// Make sure the node is a CCSprite and has the right tags.
		if ([node isKindOfClass:[CCSprite class]] && (node.tag == 1 || node.tag == 2))
		{
			// The sprite's collision radius is a percentage of its image width. Use that to draw a circle
			// which represents the sprite's collision radius.
			CCSprite* sprite = (CCSprite*)node;
			float radius = [sprite texture].contentSize.width * 0.4f;
			float angle = 0;
			int numSegments = 10;
			bool drawLineToCenter = NO;
			ccDrawCircle(sprite.position, radius, angle, numSegments, drawLineToCenter);
		}
	}
#endif
    
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	// always keep variables you have to calculate only once outside the loop
	float threadCutPosition = screenSize.height * 0.75f;
    
	// Draw a spider thread using OpenGL
	// CCARRAY_FOREACH is a bit faster than regular for loop
	CCSprite* spider;
	CCARRAY_FOREACH(spiders, spider)
	{
		// only draw thread up to a certain point
		if (spider.position.y > threadCutPosition)
		{
			// vary thread position a little so it looks a bit more dynamic
			float threadX = spider.position.x + (CCRANDOM_0_1() * 2.0f - 1.0f);
			
			// glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
			ccDrawLine(spider.position, CGPointMake(threadX, screenSize.height));
		}
	}
}

#pragma mark Acceleration Methods
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    playerVelocity.x = playerVelocity.x * kDeceleration + acceleration.x * kSensitivity;
    if (playerVelocity.x > kMaxVelocity)
    {
        playerVelocity.x = kMaxVelocity;
    }
    else if (playerVelocity.x < -kMaxVelocity)
    {
        playerVelocity.x = -kMaxVelocity;
    }
}

#pragma mark Touch Methods

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetGame];
}

@end
