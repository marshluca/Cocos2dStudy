//
//  MenuLayer.m
//  Essentials
//
//  Created by Lin Zhang on 12-10-4.
//
//

#import "MenuLayer.h"
#import "HelloWorldLayer.h"

@interface MenuLayer (PrivateMethods)
- (void) goBack;
- (void) changeScene:(id)sender;
@end

@implementation MenuLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MenuLayer *layer = [MenuLayer node];
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    if (self = [super init]) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
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
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Go Back" target:self selector:@selector(menuItem1Touched:)];
    
    CCSprite *normalSprite = [CCSprite spriteWithFile:@"Icon.png"];
    normalSprite.color = ccGREEN;
    CCSprite *selectedSprite = [CCSprite spriteWithFile:@"Icon.png"];
    selectedSprite.color = ccRED;
    CCMenuItemSprite *item2 = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:@selector(menuItem2Touched:)];
    
    CCMenuItemFont *toggleOn = [CCMenuItemFont itemWithString:@"On"];
    CCMenuItemFont *toggleOff = [CCMenuItemFont itemWithString:@"Off"];
    CCMenuItemToggle *item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuItem3Touched:) items:toggleOn,toggleOff, nil];
    
    CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
    [menu alignItemsVerticallyWithPadding:50];
    menu.tag = 100;
    [self addChild:menu];
}

- (void) menuItem1Touched:(id)sender
{
    [self goBack];
}

- (void) menuItem2Touched:(id)sender
{
    // nothing to do
}

- (void) menuItem3Touched:(id)sender
{
    // nothing to do
}

#pragma mark Private Methods
- (void) goBack
{
    CCNode *node = [self getChildByTag:100];
    NSAssert([node isKindOfClass:[CCMenu class]], @"node is not a CCMenu");
    
    CCMenu *menu = (CCMenu *)node;
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCMoveTo *moveTo = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width/2), size.height/2)];
    CCEaseBackInOut *ease = [CCEaseBackInOut actionWithAction:moveTo];
    CCCallFunc *func = [CCCallFunc actionWithTarget:self selector:@selector(changeScene:)];
    CCSequence *seq = [CCSequence actions:ease, func, nil];
    [menu runAction:seq];
}

- (void) changeScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

@end
