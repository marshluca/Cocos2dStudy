//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Lin Zhang on 12-10-6.
//
//

#import "GameLayer.h"

#define kSpriteTag    1

#define kDeceleration 0.4f
#define kSensitivity  6.0f
#define kMaxVelocity  100

@interface GameLayer (PrivateMethods)
- (void) initSpiders;
- (void) resetSpiders;
- (void) spidersUpdate:(ccTime)delta;
- (void) runSpiderMoveSequence:(CCSprite *)spider;
- (void) spiderBelowScreen:(id)sender;
- (void) checkForCollision;
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
    
    [self scheduleUpdate];
    
    [self initSpiders];
    
    // add score label
    scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapfont.fnt"];
    scoreLabel.position = ccp(size.width * 0.5, size.height);
    scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
    [self addChild:scoreLabel z:-1];
}

- (void) update:(ccTime)delta
{
    CCLOG(@"%@, %@, %f", NSStringFromSelector(_cmd), self, delta);
    
    totoalTime += delta;
    if (score < totoalTime)
    {
        score = totoalTime;
        [scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
    }
    
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
    
    [self checkForCollision];
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
            [self resetSpiders];
        }
    }
}

#pragma mark Private Methods

- (void) initSpiders
{
    CCSprite *tmpSprite = [CCSprite spriteWithFile:@"spider.png"];
    float imageWidth = [tmpSprite texture].contentSize.width;
        
    CGSize size = [[CCDirector sharedDirector] winSize];
    int count = size.width / imageWidth;
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
        [spider stopAllActions];
    }
    
    [self unschedule:@selector(spidersUpdate:)];
    [self schedule:@selector(spidersUpdate:) interval:0.7f];
    
    numbersOfSpiderMoved = 0;
    spiderMoveDuration = 4.0f;
}

- (void) spidersUpdate:(ccTime)delta
{
    CCLOG(@"%@, %@, %f", NSStringFromSelector(_cmd), self, delta);
    
    for (int i = 0; i < 10; i++)
    {
        int randomSpiderIndex = CCRANDOM_0_1() * [spiders count];
        CCSprite *spider = [spiders objectAtIndex:randomSpiderIndex];
        if ([spider numberOfRunningActions] == 0)
        {
            [self runSpiderMoveSequence:spider];
        }
    }
}

- (void) runSpiderMoveSequence:(CCSprite *)spider
{
    numbersOfSpiderMoved++;    
    if (numbersOfSpiderMoved % 8 == 0 && spiderMoveDuration > 2.0f)
    {
        spiderMoveDuration -= 0.1f;
    }
    
    CGPoint belowScreenPosition = CGPointMake(spider.position.x, -[spider texture].contentSize.height);
    CCMoveTo *move = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
    CCCallFuncN *funcN = [CCCallFuncN actionWithTarget:self selector:@selector(spiderBelowScreen:)];
    CCSequence *sequence = [CCSequence actions:move, funcN, nil];
    [spider runAction:sequence];
}

- (void)spiderBelowScreen:(id)sender
{
    NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not a CCSprite");
    
    CCSprite *spider = (CCSprite *)sender;
    CGPoint point = spider.position;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    point.y = screenSize.height + [spider texture].contentSize.height;
    spider.position = point;
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

@end
