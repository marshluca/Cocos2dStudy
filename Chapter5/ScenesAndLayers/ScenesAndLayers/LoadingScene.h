//
//  LoadingScene.h
//  ScenesAndLayers
//
//  Created by Lin Zhang on 12-10-17.
//
//

#import "cocos2d.h"

typedef enum
{
    TargetScenesInvalid = 0,
    TargetScenesFirstScene,
    TargetScenesSecondScene,    
} TargetScenes;

@interface LoadingScene : CCScene
{
    TargetScenes _targetScene;
}

+ (id) sceneWithTargetScene:(TargetScenes)targetScene;
- (id) initWithTargetScene:(TargetScenes)targetScene;

@end
