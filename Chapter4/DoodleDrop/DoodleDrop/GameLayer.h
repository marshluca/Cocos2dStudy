//
//  GameLayer.h
//  DoodleDrop
//
//  Created by Lin Zhang on 12-10-6.
//
//

#import "cocos2d.h"

@interface GameLayer : CCLayer
{
    CCSprite *player;
    CGPoint playerVelocity;
    
    CCArray *spiders;
    float spiderMoveDuration;
    int numbersOfSpiderMoved;
    
    ccTime totoalTime;
    int score;
    CCLabelBMFont *scoreLabel;
}

+ (CCScene *) scene;

@end
