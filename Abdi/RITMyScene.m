//
//  RITMyScene.m
//  Abdi
//
//  Created by Dinesh Dommaraju on 1/30/14.
//  Copyright (c) 2014 Dinesh Dommaraju. All rights reserved.
//

#import "RITMyScene.h"
#import "RITViewController.h"
#import "EndScreen.h"


@import AVFoundation;

CGSize adjustedSize;
CFTimeInterval _lastUpdateTime;
CFTimeInterval _dt;
CFTimeInterval _levelUpTime=0;
BOOL stopGame = NO;
int availableVillians[3] = {0,0,0};
int availableDogs[2]={0,0};
int score = 0;
int level = 0;
float moveDuration = 5;
//int testVillian =10;

static const float BG_VELOCITY = 100.0;

static const uint32_t heroCategory     =  0x1 << 0;
static const uint32_t villianCategory  =  0x1 << 1;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@interface RITMyScene() <SKPhysicsContactDelegate>

@property (nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@end

@implementation RITMyScene{
    SKLabelNode *scoreText;
    SKLabelNode *levelText;
    SKSpriteNode *_hero;
    SKSpriteNode *_heroJumping;
    SKSpriteNode *_heroKicking;
    SKSpriteNode *_heroPunching;
    SKSpriteNode *_heroDying;
    SKSpriteNode *_villianBanged;
    NSArray *_heroWalkingFramesArray;
    NSArray *_heroJumpingMovesArray;
    NSArray *_punchingframes;
    NSArray *_kickingframes;
    NSArray *_dyingFrames;
    NSArray *_escapingFrames;
    NSArray *_bangFrames;
    NSArray *_dogFrames;
    UISwipeGestureRecognizer *swipeUpGesture;
    UISwipeGestureRecognizer *swipeLeftGesture;
    UISwipeGestureRecognizer *swipeRightGesture;
    NSTimeInterval lastSpawnTimeInterval;
    NSTimeInterval lastUpdateTimeInterval;
    
    
    
    SKSpriteNode *_dogAttacking;
    SKSpriteNode *_dogAttacking2;
    //SKSpriteNode *_dogAttacking3;
    
    SKSpriteNode *_villian;
    SKSpriteNode *_villian2;
    SKSpriteNode *_villian3;
    NSArray *_villianWalkingFramesArray;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.name = @"self";
        self.scaleMode=SKSceneScaleModeAspectFill;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
       self.physicsBody.dynamic = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask=0;
        
        //Adding background music
        
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac" withExtension:@"caf"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
        [self.backgroundMusicPlayer play];
        
        [self initalizingScrollingBackground];
        
        [self initializingCharacterImages];
        
        [self createFloor];
        [self intializeScore];
        [self intializeLevel];
        [self AddClimate];
        
        //setting up the physical world
        self.physicsWorld.gravity = CGVectorMake(0,0);
        //self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        
        
        
        // [self handleSwipeRight:(swipeRightGesture)];
        
        
        
    }
    return self;
}

-(void) AddClimate{
    
    NSString *rain = [[NSBundle mainBundle] pathForResource:@"Rainy" ofType:@"sks"];
    SKEmitterNode *rainy = [NSKeyedUnarchiver unarchiveObjectWithFile:rain];
    [self addChild:rainy];
    rainy.particlePosition = CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxX(self.frame));
    
}


-(void) didMoveToView:(SKView *)view{
    
    if(!stopGame){
    swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(handleSwipeUp)];
    [swipeUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [view addGestureRecognizer: swipeUpGesture];
    
    
    swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handleSwipeLeft)];
    [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer: swipeLeftGesture];
    swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(handleSwipeRight)];
    [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer: swipeRightGesture];
    }
}

-(void) createFloor{
    SKSpriteNode *floor = [self newFloor];
    floor.position = CGPointMake(0, 0);
    floor.name = @"ground";
    [self addChild:floor];
}

-(SKSpriteNode*) newFloor{
    SKSpriteNode *completeFloor = [[SKSpriteNode alloc] initWithColor:[SKColor darkGrayColor] size:CGSizeMake((CGRectGetWidth(self.frame)*2), 30)];
    
    return completeFloor;
}

-(void) initializingCharacterImages{
    
    [self addHeroRunning];
    
    
    //Person 2 moving left
    
    NSMutableArray *villianArray = [NSMutableArray array];
    SKTextureAtlas *villianAtlasaFrames = [SKTextureAtlas atlasNamed:@"police"];
    int numOfImages = villianAtlasaFrames.textureNames.count;
    for (int i=1; i <= numOfImages-1; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"police%d", i];
        
        SKTexture *temp = [villianAtlasaFrames textureNamed:textureName];
        
        [villianArray addObject:temp];
        
    }
    
    _villianWalkingFramesArray = villianArray;
    
    //intializing the ther villians
    [self intializeVillians];
  
    [self addVillians];
    
    //[self addDogs];
    
}

-(void) intializeVillians{
    
    SKTexture *temp2 = _villianWalkingFramesArray[0];
    _villian2 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian2.xScale = fabs(_hero.xScale) * -1;
    _villian2.yScale = 0.4f;
    _villian2.position = CGPointMake(CGRectGetWidth(self.frame), 45);
    adjustedSize.height= 20;//_hero.frame.size.height/2.0;
    adjustedSize.height= 20;//_hero.frame.size.width/2.0;
    
    _villian2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _villian2.physicsBody.dynamic = YES;
    _villian2.physicsBody.categoryBitMask = villianCategory;
    _villian2.physicsBody.contactTestBitMask = heroCategory;
    _villian2.physicsBody.collisionBitMask = heroCategory;
    _villian2.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _villian2.name=@"villian2";
    //[self addChild:_villian2];
    //NSLog(@"%@",_villian);
    
    
    _villian3 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian3.xScale = fabs(_hero.xScale) * -1;
    _villian3.yScale = 0.4f;
    _villian3.position = CGPointMake(CGRectGetWidth(self.frame), 45);
    adjustedSize.height= 20;//_hero.frame.size.height/2.0;
    adjustedSize.height= 20;//_hero.frame.size.width/2.0;
    
    _villian3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _villian3.physicsBody.dynamic = YES;
    _villian3.physicsBody.categoryBitMask = villianCategory;
    _villian3.physicsBody.contactTestBitMask = heroCategory;
    _villian3.physicsBody.collisionBitMask = heroCategory;
    _villian3.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _villian3.name=@"villian3";
    
    
}


-(void) addHeroRunning{
    //Adding the images to the array
    NSMutableArray *personArray = [NSMutableArray array];
    
    SKTextureAtlas *frames = [SKTextureAtlas atlasNamed:@"prisoner"];
    
    int numImages = frames.textureNames.count;
    
    for (int i=1; i <= numImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        
        SKTexture *temp = [frames textureNamed:textureName];
        
          [personArray addObject:temp];
        
    }
    
    _heroWalkingFramesArray = personArray;
    
    SKTexture *temp = _heroWalkingFramesArray[0];
    
    _hero = [SKSpriteNode spriteNodeWithTexture:temp];
    
    _hero.position = CGPointMake(60, 45);
     //CGPoint adjustedSize = _hero.frame.size / 2 ;
    
    adjustedSize.height= 20;//_hero.frame.size.height;
    adjustedSize.width= 20;//_hero.frame.size.width;
 
    _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];

    _hero.physicsBody.dynamic = YES;
    _hero.physicsBody.usesPreciseCollisionDetection = YES;
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.contactTestBitMask = villianCategory;
    _hero.physicsBody.collisionBitMask = villianCategory;
    //_person.physicsBody.categoryBitMask =
    
    
    _hero.name=@"hero";
    _hero.xScale=0.6f;
    _hero.yScale=0.6f;
    [self addChild:_hero];
    
    
    NSMutableArray *escapeFramesArray = [NSMutableArray array];
    SKTextureAtlas *escapeFramesAtlas = [SKTextureAtlas atlasNamed:@"escape"];
    int numOfImages = escapeFramesAtlas.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"escape%d", i];
        SKTexture *temp = [escapeFramesAtlas textureNamed:textureName];
        [escapeFramesArray addObject:temp];
    }
    
    _escapingFrames = escapeFramesArray;
    [self escape:(SKSpriteNode*)_hero usingFrames:(NSArray *)_heroWalkingFramesArray];
    
    
}

-(void) addHeroJumping{
    
    NSMutableArray *jumpingArray = [NSMutableArray array];
    SKTextureAtlas *jumpingAtlasFrames = [SKTextureAtlas atlasNamed:@"jumping"];
    int numImages = jumpingAtlasFrames.textureNames.count;
    for (int i=1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"jump%d",i];
        SKTexture *temp1 = [jumpingAtlasFrames textureNamed:textureName];
        [jumpingArray addObject:temp1];
    }
    
    _heroJumpingMovesArray = jumpingArray;
    SKTexture *temp = _heroJumpingMovesArray[0];
    
    _heroJumping= [SKSpriteNode spriteNodeWithTexture:temp];
    _heroJumping.xScale=0.6f;
    _heroJumping.yScale=0.6f;
    _heroJumping.position = CGPointMake(60, 45);
    //adjustedSize.height= _hero.frame.size.height/2.0;
    //adjustedSize.height= _hero.frame.size.width/2.0;
    _heroJumping.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.frame.size];
    //_heroJumping.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _heroJumping.physicsBody.dynamic = YES;
    _heroJumping.physicsBody.usesPreciseCollisionDetection = YES;
    //_heroJumping.physicsBody.
    _heroJumping.physicsBody.categoryBitMask = heroCategory;
    _heroJumping.physicsBody.contactTestBitMask = villianCategory;
    _heroJumping.physicsBody.collisionBitMask = villianCategory;
    //_person.physicsBody.categoryBitMask =
    
    
    _heroJumping.name=@"heroJumping";
    [self addChild:_heroJumping];
    [self escape:(SKSpriteNode*)_heroJumping usingFrames:(NSArray *)_heroJumpingMovesArray];
    
    
    
}

-(void) addHeroKicking{
    
    
    NSMutableArray *kickingArray = [NSMutableArray array];
    SKTextureAtlas *kickingAtlasFrames = [SKTextureAtlas atlasNamed:@"kick"];
    int numOfImages = kickingAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"kick%d", i];
        
        SKTexture *temp = [kickingAtlasFrames textureNamed:textureName];
        
        [kickingArray addObject:temp];
    }
    
    _kickingframes = kickingArray;
    
    SKTexture *temp = _kickingframes[0];
    
    _heroKicking= [SKSpriteNode spriteNodeWithTexture:temp];
    _heroKicking.xScale=0.6f;
    _heroKicking.yScale=0.6f;
    
    _heroKicking.position = CGPointMake(60, 45);
    
    //adjustedSize.height= _hero.frame.size.height/2.0;
    //adjustedSize.height= _hero.frame.size.width/2.0;
    
    _heroKicking.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.frame.size];
    //_heroKicking.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _heroKicking.physicsBody.dynamic = YES;
    _heroKicking.physicsBody.usesPreciseCollisionDetection = YES;
    _heroKicking.physicsBody.categoryBitMask = heroCategory;
    _heroKicking.physicsBody.contactTestBitMask = villianCategory;
    _heroKicking.physicsBody.collisionBitMask = villianCategory;
    //_person.physicsBody.categoryBitMask =
    
    
    _heroKicking.name=@"heroKicking";
    [self addChild:_heroKicking];
    [self escape:(SKSpriteNode*)_heroKicking usingFrames:(NSArray *)_kickingframes];
    
}

-(void) addHeroPunching{
    NSMutableArray *punchingArray = [NSMutableArray array];
    SKTextureAtlas *punchingAtlasFrames = [SKTextureAtlas atlasNamed:@"punch"];
    int numOfImages = punchingAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"punch%d", i];
        
        SKTexture *temp = [punchingAtlasFrames textureNamed:textureName];
        
        [punchingArray addObject:temp];
        
    }
    
    _punchingframes = punchingArray;
    
    SKTexture *temp = _punchingframes[0];
    
    _heroPunching= [SKSpriteNode spriteNodeWithTexture:temp];
    _heroPunching.xScale=0.6f;
    _heroPunching.yScale=0.6f;
    _heroPunching.position = CGPointMake(60, 45);
    //adjustedSize.height= _hero.frame.size.height/2.0;
    //adjustedSize.height= _hero.frame.size.width/2.0;
    _heroPunching.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.frame.size];
    //_heroPunching.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _heroPunching.physicsBody.dynamic = YES;
    _heroPunching.physicsBody.usesPreciseCollisionDetection = YES;
    _heroPunching.physicsBody.categoryBitMask = heroCategory;
    _heroPunching.physicsBody.contactTestBitMask = villianCategory;
    _heroPunching.physicsBody.collisionBitMask = villianCategory;
    //_person.physicsBody.categoryBitMask =
    
    
    _heroPunching.name=@"heroPunching";
    [self addChild:_heroPunching];
    [self escape:(SKSpriteNode*)_heroPunching usingFrames:(NSArray *)_punchingframes];
    
    
}

-(void) addVillians{
    
    
    
    SKTexture *temp2 = _villianWalkingFramesArray[0];
    _villian = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian.xScale = fabs(_hero.xScale) * -1;
    _villian.yScale = 0.4f;
    _villian.position = CGPointMake(CGRectGetWidth(self.frame), 45);
    adjustedSize.height= 20;//_hero.frame.size.height/2.0;
    adjustedSize.height= 20;//_hero.frame.size.width/2.0;
    
    _villian.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _villian.physicsBody.dynamic = YES;
    _villian.physicsBody.categoryBitMask = villianCategory;
    _villian.physicsBody.contactTestBitMask = heroCategory;
    _villian.physicsBody.collisionBitMask = heroCategory;
    _villian.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _villian.name=@"villian";
    availableVillians[0]=1;
    [self addChild:_villian];
    //NSLog(@"%@",_villian);
    
    [self moveSecondPerson:_villian];
}

-(void) addVillians2{
    
    
    
    SKTexture *temp2 = _villianWalkingFramesArray[0];
    _villian2 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian2.xScale = fabs(_hero.xScale) * -1;
    _villian2.yScale = 0.4f;
    _villian2.position = CGPointMake(CGRectGetWidth(self.frame), 45);
    adjustedSize.height= 20;//_hero.frame.size.height/2.0;
    adjustedSize.width= 20;//_hero.frame.size.width/2.0;
    
    _villian2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _villian2.physicsBody.dynamic = YES;
    _villian2.physicsBody.categoryBitMask = villianCategory;
    _villian2.physicsBody.contactTestBitMask = heroCategory;
    _villian2.physicsBody.collisionBitMask = heroCategory;
    _villian2.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _villian2.name=@"villian2";
    availableVillians[1]=1;
    [self addChild:_villian2];
    //NSLog(@"%@",_villian);
    
    [self moveSecondPerson:_villian2];
}

-(void) addVillians3{
    
    
    
    SKTexture *temp2 = _villianWalkingFramesArray[0];
    _villian3 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian3.xScale = fabs(_hero.xScale) * -1;
    _villian3.yScale = 0.4f;
    _villian3.position = CGPointMake(CGRectGetWidth(self.frame), 45);
    adjustedSize.height= 20;//_hero.frame.size.height/2.0;
    adjustedSize.width= 20;//_hero.frame.size.width/2.0;
    
    _villian3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _villian3.physicsBody.dynamic = YES;
    _villian3.physicsBody.categoryBitMask = villianCategory;
    _villian3.physicsBody.contactTestBitMask = heroCategory;
    _villian3.physicsBody.collisionBitMask = heroCategory;
    _villian3.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _villian3.name=@"villian3";
    availableVillians[2]=1;
    [self addChild:_villian3];
    //NSLog(@"%@",_villian);
    
    [self moveSecondPerson:_villian3];
}

- (void) addDogs{
    
    
    NSMutableArray *dogArray = [NSMutableArray array];
    SKTextureAtlas *dogAtlasFrames = [SKTextureAtlas atlasNamed:@"dog"];
    int numOfImages = dogAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"dog%d", i];
        
        SKTexture *temp = [dogAtlasFrames textureNamed:textureName];
        
        [dogArray addObject:temp];
        
    }
    
    _dogFrames = dogArray;
    SKTexture *temp2 = _dogFrames[0];
    _dogAttacking = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _dogAttacking.xScale = fabs(_hero.xScale) * -1;
    _dogAttacking.yScale = 0.4f;
    _dogAttacking.position = CGPointMake(CGRectGetWidth(self.frame), 20);
    adjustedSize.height= _hero.frame.size.height/2.0;
    adjustedSize.width= _hero.frame.size.width/4.0;
    
    _dogAttacking.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _dogAttacking.physicsBody.dynamic = YES;
    _dogAttacking.physicsBody.categoryBitMask = villianCategory;
    _dogAttacking.physicsBody.contactTestBitMask = heroCategory;
    _dogAttacking.physicsBody.collisionBitMask = heroCategory;
    _dogAttacking.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _dogAttacking.name=@"dog";
    [self addChild:_dogAttacking];
    //NSLog(@"%@",_villian);
    
    [self dogAttack:_dogAttacking];
}

- (void) addDog2{
    
    
    NSMutableArray *dogArray = [NSMutableArray array];
    SKTextureAtlas *dogAtlasFrames = [SKTextureAtlas atlasNamed:@"dog"];
    int numOfImages = dogAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"dog%d", i];
        
        SKTexture *temp = [dogAtlasFrames textureNamed:textureName];
        
        [dogArray addObject:temp];
        
    }
    
    _dogFrames = dogArray;
    SKTexture *temp2 = _dogFrames[0];
    _dogAttacking2 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _dogAttacking2.xScale = fabs(_hero.xScale) * -1;
    _dogAttacking2.yScale = 0.4f;
    _dogAttacking2.position = CGPointMake(CGRectGetWidth(self.frame), 20);
    adjustedSize.height= _hero.frame.size.height/2.0;
    adjustedSize.width= _hero.frame.size.width/4.0;
    
    
    
    //_dogAttacking2.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:<#(CGFloat)#>]
    _dogAttacking2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:adjustedSize];
    _dogAttacking2.physicsBody.dynamic = YES;
    _dogAttacking2.physicsBody.categoryBitMask = villianCategory;
    _dogAttacking2.physicsBody.contactTestBitMask = heroCategory;
    _dogAttacking2.physicsBody.collisionBitMask = heroCategory;
    _dogAttacking2.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    
    //_villian.name = [@"villian" stringByAppendingString: [NSString stringWithFormat:@"%i",testVillian]];
    //testVillian += 1;
    _dogAttacking2.name=@"dog2";
    [self addChild:_dogAttacking2];
    //NSLog(@"%@",_villian);
    
    [self dogAttack:_dogAttacking2];
}


-(void) handleSwipeRight{
    
    if(!stopGame)
    [self addHeroKicking];
    
    
}


-(void) handleSwipeLeft{
    
    if(!stopGame)
    [self addHeroPunching];
    
}


-(void) handleSwipeUp {
    
    if(!stopGame)
    [self addHeroJumping];
    
}


- (void) escape:(SKSpriteNode *)hero usingFrames: (NSArray *) framesArray{
  
    if(hero.name == _hero.name){
        [hero runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:framesArray timePerFrame:0.1f resize:NO restore:YES]]];
    }else if (hero.name == _heroJumping.name){
        
        [_hero removeFromParent];
        [hero runAction:[SKAction sequence:@[[SKAction moveToY:hero.position.y + hero.size.height duration:0.6f],
                                             [SKAction moveToY:hero.position.y duration:0.5f],
                                             [SKAction runBlock:^{
            [hero removeFromParent];
            [self addHeroRunning];
        }]]]];
    }
    else{
        [_hero removeFromParent];
        
        [hero runAction:[SKAction sequence:@[
                        [SKAction animateWithTextures:framesArray timePerFrame:0.1f resize:NO restore:YES],
                        
                        [SKAction runBlock:^{
                                        [hero removeFromParent];
                                        [self addHeroRunning];
        }]]]];
        
    }
    
}


- (void) heroDie {
    
    
    NSMutableArray *dyingArray = [NSMutableArray array];
    SKTextureAtlas *dieAtlasFrames = [SKTextureAtlas atlasNamed:@"heroDie"];
    int numOfImages = dieAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages-1; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"heroDie%d", i];
        
        SKTexture *temp = [dieAtlasFrames textureNamed:textureName];
        
        [dyingArray addObject:temp];
        
    }
    
    _dyingFrames = dyingArray;
    
    SKTexture *temp2 = _dyingFrames[0];
    _heroDying = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _heroDying.position = CGPointMake(60, 45);
    _heroDying.xScale=0.6f;
    _heroDying.yScale=0.6f;
   
    _heroDying.name=@"heroBanged";
    [self addChild:_heroDying];
    stopGame = TRUE;
    //SKAction *load = [SKAction playSoundFileNamed:@"Comedy_Punch.mp3" waitForCompletion:YES];
   // [_heroDying runAction:load];
    [_hero removeFromParent];
    [_heroDying runAction:[SKAction sequence:@[
                [SKAction animateWithTextures:_dyingFrames timePerFrame:0.1f],
                [SKAction runBlock:^{
        
                                //[_villian removeFromParent];
                                //[self removeFromParent];
    }],
                [SKAction runBlock:^{
                                [_heroDying removeFromParent];
                [scoreText runAction:[SKAction sequence:@[[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:2.0],
                                                          [SKAction scaleTo:2.0 duration:2.0]]] completion:^{
                    SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
                    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
                    [self.view presentScene:gameOverScene transition:doors];
                }];
                            }
                 ]]]];
}

- (void) hitPolice:(SKSpriteNode *)villian{
    [self removeVillian:villian];
    //[_villian removeFromParent];
    // NSLog(@"Entered Hit Jump");
    NSMutableArray *bangArray = [NSMutableArray array];
    SKTextureAtlas *bangAtlasFrames = [SKTextureAtlas atlasNamed:@"bang"];
    int numOfImages = bangAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages-1; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"bang%d", i];
        
        SKTexture *temp = [bangAtlasFrames textureNamed:textureName];
        
        [bangArray addObject:temp];
        
    }
    
    _bangFrames = bangArray;
    
    
    
    SKTexture *temp2 = _bangFrames[0];
    _villianBanged = [SKSpriteNode spriteNodeWithTexture:temp2];
    //_villianBanged.name = @"banged";
    _villianBanged.position = CGPointMake(100, 45);
    _villianBanged.xScale=0.6f;
    _villianBanged.yScale=0.6f;
    _villianBanged.name=@"Banged";
     
    [self addChild:_villianBanged];
    //[_hero removeAllActions];
    [_villianBanged runAction:[SKAction sequence:@[
                                    [SKAction animateWithTextures:_bangFrames timePerFrame:0.1f],
                                    [SKAction runBlock:^{
                                        [_villianBanged removeFromParent];
                                    }]
                                    ]]];
}

-(void) removeVillian:(SKSpriteNode *)villian
{
    //NSLog(@"---------------");
    //NSLog(@"Entered remove Villian");
    //NSLog(@"%@",villian.name);
    //NSLog(@"---------------");

    if([villian.name isEqualToString:@"villian"])
    {
        //NSLog(@"villian1 removed");
        availableVillians[0]=0;
        [_villian removeFromParent];

        
            
    }else if([villian.name isEqualToString:@"villian2"] )
    {
         //NSLog(@"villian2 removed");
        availableVillians[1]=0;
        [_villian2 removeFromParent];

    }else if([villian.name isEqualToString:@"villian3"])
    {
         //NSLog(@"villian3 removed");
        availableVillians[2]=0;
        [_villian3 removeFromParent];

    }
}

- (void) dogAttack:(SKSpriteNode *) dog{
    
    
    
    CGPoint location = CGPointMake(_hero.position.x*-1,_hero.position.y-20);
    float moveDuration = 5.0;
    
    dog.xScale = fabs(dog.xScale) * -1;
    
    [dog runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_dogFrames timePerFrame:0.1f resize:NO restore:YES]]];
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"Animation Completed");
        //[_person2 removeAllActions];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [dog runAction:moveActionWithDone];
    
    //[_person2 removeFromParent];
    if(dog.position.x<0){
        //NSLog(@"testing whether dog is removed");
        if([dog.name isEqualToString:@"dog"])
        {
            availableDogs[0]=0;
            
        }else if([dog.name isEqualToString:@"dog2"])
        {
            availableDogs[1]=0;
            
        }
        
        [dog removeFromParent];
        
    }
    
}

- (void)villian:(SKSpriteNode *)villian didCollideWithHero:(SKSpriteNode *)hero {
    
    //NSLog(@"Hero Running");
    
    [self heroDie];
    [_hero removeFromParent];
    
}

- (void)villian:(SKSpriteNode *)villian didPunchedByHero:(SKSpriteNode *)hero {
    score+=200;
    
    SKAction *load = [SKAction playSoundFileNamed:@"Super Punch.mp3" waitForCompletion:YES];
    [_heroPunching runAction:load];
    [self hitPolice:villian];
}

- (void)villian:(SKSpriteNode *)villian didKickedByHero:(SKSpriteNode *)hero {
    score+=200;

    SKAction *load = [SKAction playSoundFileNamed:@"Kick.mp3" waitForCompletion:YES];
    [_heroKicking runAction:load];
    [self hitPolice:villian];
}

- (void)villian:(SKSpriteNode *)villian didJumpedByHero:(SKSpriteNode *)hero {
    [self heroDie];
    [_heroJumping removeFromParent];
}

//logic to handle contact

- (void) didBeginContact:(SKPhysicsContact *) contact
{
    SKPhysicsBody *firstBody, *secondBody;
    //NSLog(@"------------");
    //NSLog(@"%@",contact.bodyA.node.name);
    //NSLog(@"%@",contact.bodyB.node.name);
          //NSLog(@"------------");
    
    //finding the first and second bodies
    //first body should always be Hero and its different categories
    //second body should always be Villian
    
    if([contact.bodyA.node.name  isEqual: @"hero"])
    {
        firstBody = contact.bodyA;
    }else if([contact.bodyA.node.name  isEqual: @"heroJumping"])
    {
        firstBody = contact.bodyA;
        
    }else if ([contact.bodyA.node.name  isEqual: @"heroKicking"])
    {
        firstBody = contact.bodyA;
    }
    else if([contact.bodyA.node.name  isEqual: @"heroPunching"])
    {
        firstBody = contact.bodyA;
        
    }else if([contact.bodyA.node.name  isEqual: @"villian"] || [contact.bodyA.node.name  isEqual: @"villian2"] || [contact.bodyA.node.name  isEqual: @"villian3"] )
    {
        secondBody = contact.bodyA;
    }else if([contact.bodyA.node.name  isEqual: @"dog"] || [contact.bodyA.node.name  isEqual: @"dog2"])
    {
        secondBody = contact.bodyA;
    }
    
    //
    //
    if([contact.bodyB.node.name  isEqual: @"hero"])
    {
        firstBody = contact.bodyB;
    }else if([contact.bodyB.node.name  isEqual: @"heroJumping"])
    {
        firstBody = contact.bodyB;
        
    }else if ([contact.bodyB.node.name  isEqual: @"heroKicking"])
    {
        firstBody = contact.bodyB;
    }
    else if([contact.bodyB.node.name  isEqual: @"heroPunching"])
    {
        firstBody = contact.bodyB;
        
    }else if([contact.bodyB.node.name  isEqual: @"villian"]|| [contact.bodyB.node.name  isEqual: @"villian2"] || [contact.bodyB.node.name  isEqual:@"villian3"] )
    {
        secondBody = contact.bodyB;
    }else if([contact.bodyB.node.name  isEqual: @"dog"] || [contact.bodyB.node.name  isEqual: @"dog2"])
    {
        secondBody = contact.bodyB;
    }
    
    //NSLog(@"**********");
    //NSLog(@"%@",firstBody.node.name);
    //NSLog(@"%@",secondBody.node.name);
    //NSLog(@"**********");
    
    //
    
    //Calling different methods
    if(([firstBody.node.name  isEqual: @"hero"] ||[firstBody.node.name  isEqual: @"heroKicking"] || [firstBody.node.name  isEqual: @"heroPunching"])  && ([secondBody.node.name isEqual:@"dog"] || [secondBody.node.name isEqual:@"dog2"]) )
    {
        [self villian:(SKSpriteNode *) secondBody.node didCollideWithHero:(SKSpriteNode *) firstBody.node];
    }
    
    else if([firstBody.node.name  isEqual: @"hero"] && ([secondBody.node.name isEqual:@"villian"] ||             [secondBody.node.name isEqual:@"villian2"] || [secondBody.node.name isEqual:@"villian3"] ))
    {
        [self villian:(SKSpriteNode *) secondBody.node didCollideWithHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroJumping"] && ([secondBody.node.name isEqual:@"villian"] ||[secondBody.node.name isEqual:@"villian2"] || [secondBody.node.name isEqual:@"villian3"]))
    {
        [self villian:(SKSpriteNode *) secondBody.node didJumpedByHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroKicking"] && ([secondBody.node.name isEqual:@"villian"] ||[secondBody.node.name isEqual:@"villian2"] || [secondBody.node.name isEqual:@"villian3"]))    {
        [self villian:(SKSpriteNode *) secondBody.node didKickedByHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroPunching"] && ([secondBody.node.name isEqual:@"villian"] ||[secondBody.node.name isEqual:@"villian2"] || [secondBody.node.name isEqual:@"villian3"]))
    {
        [self villian:(SKSpriteNode *) secondBody.node didPunchedByHero:(SKSpriteNode *) firstBody.node];
        
    }
}


-(void) moveSecondPerson:(SKSpriteNode *) villian {
    
    villian.position = CGPointMake(CGRectGetWidth(self.frame), 35);

    CGPoint location = CGPointMake(_hero.position.x*-1,_hero.position.y);
    
    //float moveDuration = 5.0;
    
    villian.xScale = fabs(villian.xScale) * -1;
    
    [villian runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_villianWalkingFramesArray timePerFrame:0.1f resize:NO restore:YES]]];
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"Villian Created");
        //NSLog(@"%@",villian.name);
              
        //[_person2 removeAllActions];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [villian runAction:moveActionWithDone];
    
    //[_person2 removeFromParent];
    if(villian.position.x<0){
        if([villian.name isEqualToString:@"villian"])
        {
            availableVillians[0]=0;
            
        }else if([villian.name isEqualToString:@"villian2"])
        {
            availableVillians[1]=0;
            
        }else if([villian.name isEqualToString:@"villian3"])
        {
            availableVillians[2]=0;
            
        }
        
        [villian removeFromParent];
        
    }
    
    
}



-(void)initalizingScrollingBackground
{
    for(int i =0 ; i < 2 ; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"2"];
        bg.name = @"bg";
        bg.yScale=1.5f;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
        
    }
}



- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         bg.name = @"bg";
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
    
    
}

-(int) getRandomNumberBetween:(int) from to:(int) to {
    
    return (int)from + arc4random() %(to - from +1);
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    lastSpawnTimeInterval += timeSinceLast;
    if (lastSpawnTimeInterval > 2 && !stopGame) {
        lastSpawnTimeInterval = 0;
        //NSLog(@"Entered check available villians");
        //check for available villians
        //NSLog(@"%d",availableVillians[0]);
        //NSLog(@"%d",availableVillians[1]);
        //NSLog(@"%d",availableVillians[2]);
        
        int random = [self getRandomNumberBetween:0 to:1];
        if(random == 0)
        {
        
        if(availableVillians[0]==0)
        {
            availableVillians[0]=1;
            //add the villian to the parent node
           // [self addChild:_villian];
            
            //[self moveSecondPerson:_villian];
            
            
            
        }else if(availableVillians[1]==0)
        {
            availableVillians[1]=1;
            [self addVillians2];
            //add the villian to the parent node
            //[self addChild:_villian2];
            //[self moveSecondPerson:_villian2];
            

            
            }else if(availableVillians[2]==0)
        {
            availableVillians[2]=1;
            [self addVillians3];
            //add the villian to the parent node
            //[self addChild:_villian3];
            //[self moveSecondPerson:_villian3];
            
            
        }}
        if(random==1)
        {
        
        if(availableDogs[0]==0)
        {
            availableDogs[0]=1;
            [self addDogs];
        }else if(availableDogs[1]==0)
        {
            availableDogs[1]=1;
            [self addDog2];
        }}
        
        //[self addVillians];
    }
}

-(void) intializeLevel{
    levelText=[SKLabelNode labelNodeWithFontNamed:@"Courier"];
    levelText.name = @"kScoreHudName";
    levelText.fontColor = [SKColor blackColor];
    levelText.fontSize = 15;
    levelText.position = CGPointMake(self.frame.size.width* 0.8,self.frame.size.height*0.75);
    [self addChild:levelText];
}

-(void) intializeScore{
    
    scoreText=[SKLabelNode labelNodeWithFontNamed:@"Courier"];
    scoreText.name = @"kScoreHudName";
    scoreText.fontColor = [SKColor blackColor];
    scoreText.fontSize = 15;
    scoreText.position = CGPointMake(self.frame.size.width* 0.8,self.frame.size.height*0.8);
    [self addChild:scoreText];

    
    
    
}

-(void) updateScore
{
    scoreText.text = [NSString stringWithFormat:@"Score: %d", score];
}

-(void) updateLevel
{
    levelText.text = [NSString stringWithFormat:@"Level: %d", level];
}

-(void)update:(CFTimeInterval)currentTime
{
    if(_dogAttacking.position.x < 0)
    {
        availableDogs[0]=0;
    }else if(_dogAttacking2.position.x < 0)
    {
        availableDogs[1]=0;
    }
    if(!stopGame)
    {
    score = score + 1;
    [self updateScore];
    
    }
    
    
    /* Called before each frame is rendered */
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    [self moveBg];
    
    //[self runImages];
    //
    if(currentTime - _levelUpTime > 10)
    {
        level+=1;
        moveDuration-=0.2;
        NSLog(@"level up");
        _levelUpTime = currentTime;
        [self updateLevel];
    }
    
    //
    //
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 5) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        lastUpdateTimeInterval = currentTime;
        
    }
    
    
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
