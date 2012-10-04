//
//  MenuLayer.m
//  Essentials
//
//  Created by Lin Zhang on 12-10-4.
//
//

#import "MenuLayer.h"

@implementation MenuLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MenuLayer *layer = [MenuLayer node];
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

@end
