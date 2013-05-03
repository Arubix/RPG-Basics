//
//  HelloWorldLayer.m
//  rpg
//
//  Created by Havana on 2/2/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize theMap;
@synthesize bglayer;
@synthesize robot;
@synthesize stLayer;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
		
		self.theMap = [CCTMXTiledMap tiledMapWithTMXFile:@"map1.tmx"];
        self.bglayer = [theMap layerNamed:@"Tile Layer 1"];
        self.stLayer = [theMap layerNamed:@"st"];
        
        //prevents player from seeing the collision layer but its still there
        stLayer.visible = NO;
        
        CCTMXObjectGroup *objects = [theMap objectGroupNamed:@"oj"];
        NSMutableDictionary *startingPoint = [objects objectNamed:@"startPoint"];
        
        int x = [[startingPoint valueForKey:@"x"] intValue];
        int y = [[startingPoint valueForKey:@"y"] intValue];
        
        self.robot = [CCSprite spriteWithFile:@"robot.png"];
        robot.position = ccp(x, y);
        
        [self addChild:robot];
        
        [self setCenterOfScreen:robot.position];
        [self addChild:theMap z:-1];

	}
	return self;
}
- (void) dealloc{
	self.bglayer = nil;
    self.theMap = nil;
    self.robot = nil;
    self.stLayer = nil;
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

//sliding the background layer into the cameras view
-(void)setCenterOfScreen:(CGPoint) position{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, screenSize.width / 2);
    int y = MAX(position.y, screenSize.height / 2);
    
    x = MIN(x, theMap.mapSize.width * theMap.tileSize.width - screenSize.width / 2);
    y = MIN(y, theMap.mapSize.height * theMap.tileSize.height - screenSize.height / 2);
    
    CGPoint goodPoint = ccp(x, y);
    
    CGPoint centerOfScreen = ccp(screenSize.width / 2, screenSize.height / 2);
    CGPoint difference = ccpSub(centerOfScreen, goodPoint);
    
    self.position = difference;
}
-(void) registerWithTouchDispatcher{
    [[CCTouchDispatcher sharedDispatcher]addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector]convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos = robot.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    
    //moves guy up/down or left/right
    if (abs(diff.x) > abs(diff.y)) 
        if(diff.x > 0)
            playerPos.x += theMap.tileSize.width;
        else
            playerPos.x -= theMap.tileSize.width;
    else
        if (diff.y > 0) 
            playerPos.y += theMap.tileSize.height;
        else
            playerPos.y -= theMap.tileSize.height;
    
    //makes sure new position isnt off the map
    if(playerPos.x <= (theMap.mapSize.width * theMap.tileSize.width) &&
       playerPos.y <= (theMap.mapSize.height * theMap.tileSize.height) &&
       playerPos.x >= 0 &&
       playerPos.y >= 0)
        [self setPlayerPosition:playerPos];
    
    [self setCenterOfScreen:robot.position];
}
-(void)setPlayerPosition:(CGPoint)position{
    CGPoint tileCoord = [self tileCoordForPosition:position];
    
    int tileGID = [stLayer tileGIDAt:tileCoord];
    
    if(tileGID){
        NSDictionary *properties = [theMap propertiesForGID:tileGID];
        
        if(properties){
            NSString *collision = [properties valueForKey:@"Collidable"];
            if(collision && [collision compare:@"True"] == NSOrderedSame)
               return;
        }
    }
    robot.position = position;
}
-(CGPoint)tileCoordForPosition:(CGPoint)position{
    int x = position.x / theMap.tileSize.width;
    int y = ((theMap.tileSize.height * theMap.mapSize.height)- position.y) / theMap.tileSize.height;
    return ccp(x, y);
}
@end
