//
//  HelloWorldLayer.h
//  rpg
//
//  Created by Havana on 2/2/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>{
    CCTMXTiledMap *theMap;
    CCTMXLayer *bglayer;
    CCSprite *robot;
    CCTMXLayer *stLayer;
}

@property(nonatomic, retain) CCTMXTiledMap *theMap;
@property(nonatomic, retain) CCTMXLayer *bglayer;
@property(nonatomic, retain) CCSprite *robot;
@property(nonatomic, retain) CCTMXLayer *stLayer;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)setPlayerPosition:(CGPoint)position;
-(void)setCenterOfScreen:(CGPoint) position;
-(CGPoint)tileCoordForPosition:(CGPoint)position;
@end