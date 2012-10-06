//
//  GameLayer.m
//  DoodleDrop
//
//  Created by Lin Zhang on 12-10-6.
//
//

#import "GameLayer.h"

@implementation GameLayer

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init
{
    if (self = [super init]) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    }
    
    return self;
}

- (void)dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super dealloc];
}

@end
