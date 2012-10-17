//
//  LoadingScene.m
//  ScenesAndLayers
//
//  Created by Lin Zhang on 12-10-17.
//
//

#import "LoadingScene.h"
#import "FirstScene.h"
#import "SecondScene.h"

@implementation LoadingScene

+ (id) sceneWithTargetScene:(TargetScenes)targetScene
{
    return [[[self alloc] initWithTargetScene:targetScene] autorelease];
}

- (id) initWithTargetScene:(TargetScenes)targetScene
{
    if (self = [super init])
    {
        _targetScene = targetScene;
    }
    
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Loading" fontName:@"Marker Felt" fontSize:64];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    label.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:label];
    
    [self scheduleUpdate];
}

- (void) update:(ccTime)delta
{
    [self unscheduleAllSelectors];
    
    switch (_targetScene) {
        case TargetScenesFirstScene:
            [[CCDirector sharedDirector] replaceScene:[FirstScene scene]];
            break;
        case TargetScenesSecondScene:
            break;
            
        default:
            break;
    }
}

@end
