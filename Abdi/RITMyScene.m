//
//  RITMyScene.m
//  Abdi
//
//  Created by Dinesh Dommaraju on 1/30/14.
//  Copyright (c) 2014 Dinesh Dommaraju. All rights reserved.
//

#import "RITMyScene.h"

CGSize adjustedSize;
CFTimeInterval _lastUpdateTime;
CFTimeInterval _dt;
BOOL stopGame = NO;
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

@end

@implementation RITMyScene{
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
    UISwipeGestureRecognizer *swipeUpGesture;
    UISwipeGestureRecognizer *swipeLeftGesture;
    UISwipeGestureRecognizer *swipeRightGesture;
    NSTimeInterval lastSpawnTimeInterval;
    NSTimeInterval lastUpdateTimeInterval;
    
    
    SKSpriteNode *_villian;
    NSArray *_villianWalkingFramesArray;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.name = @"self";
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
       self.physicsBody.dynamic = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask=0;
        
        
        [self initalizingScrollingBackground];
        
        [self initializingCharacterImages];
        
        [self createFloor];
        
        //[self AddClimate];
        
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
    
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    
    // myParticle.particlePosition = CGPointMake(100, 100);
    //myParticle.particleBirthRate = 5;
    
    [self addChild:myParticle];
    
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
  
    [self addVillians];
    
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
    NSLog(@"%f",adjustedSize.height);
    NSLog(@"%f",adjustedSize.width);

 
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
    [self addChild:_villian];
    //NSLog(@"%@",_villian);
    
    [self moveSecondPerson];
}

-(void) handleSwipeRight{
    
    if(!stopGame)
    [self addHeroKicking];
    //[_hero runAction:[SKAction animateWithTextures: _kickingframes timePerFrame:0.1f]];
    
    
}


-(void) handleSwipeLeft{
    
    if(!stopGame)
    [self addHeroPunching];
    //[_hero runAction:[SKAction animateWithTextures: _punchingframes timePerFrame:0.1f]];
    
    
}


-(void) handleSwipeUp {
    
    if(!stopGame)
    [self addHeroJumping];
    //[_hero runAction:[SKAction animateWithTextures: _heroJumpingMovesArray timePerFrame:0.1f]];
    
}


- (void) escape:(SKSpriteNode *)hero usingFrames: (NSArray *) framesArray{
  
    if(hero.name == _hero.name){
        [hero runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:framesArray timePerFrame:0.1f resize:NO restore:YES]]];
    }else if (hero.name == _heroJumping.name){
        
        [_hero removeFromParent];
        [hero runAction:[SKAction sequence:@[[SKAction moveToY:hero.position.y + hero.size.height duration:0.5f],
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
    
    [_hero removeFromParent];
    [_heroDying runAction:[SKAction sequence:@[
                [SKAction animateWithTextures:_dyingFrames timePerFrame:0.1f],
                [SKAction runBlock:^{
                                [_villian removeFromParent];
                                [self removeFromParent];}],
                [SKAction runBlock:^{
                                [_heroDying removeFromParent];
                            }
                 ]]]];
}

- (void) hitPolice{
    [_villian removeFromParent];
    NSLog(@"Entered Hit Jump");
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

- (void)villian:(SKSpriteNode *)villian didCollideWithHero:(SKSpriteNode *)hero {
    NSLog(@"Hero Running");
    [self heroDie];
    
}

- (void)villian:(SKSpriteNode *)villian didPunchedByHero:(SKSpriteNode *)hero {
    NSLog(@"Hero Punched ");
    NSLog(@"%@",villian);
    [villian removeFromParent];
    [self hitPolice];
}

- (void)villian:(SKSpriteNode *)villian didKickedByHero:(SKSpriteNode *)hero {
    NSLog(@"Hero Kicked");
    NSLog(@"%@",hero.name);
    NSLog(@"%@",villian.name);
    [self hitPolice];
}

- (void)villian:(SKSpriteNode *)villian didJumpedByHero:(SKSpriteNode *)hero {
    NSLog(@"Hero Jumped");
    //[hero removeFromParent];
    
}

//logic to handle contact

- (void) didBeginContact:(SKPhysicsContact *) contact
{
    SKPhysicsBody *firstBody, *secondBody;
    NSLog(@"------------");
    NSLog(@"%@",contact.bodyA.node.name);
    NSLog(@"%@",contact.bodyB.node.name);
          NSLog(@"------------");
    
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
        
    }else if([contact.bodyA.node.name  isEqual: @"villian"])
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
        
    }else if([contact.bodyB.node.name  isEqual: @"villian"])
    {
        secondBody = contact.bodyB;
    }
    NSLog(@"**********");
    NSLog(@"%@",firstBody.node.name);
    NSLog(@"%@",secondBody.node.name);
    NSLog(@"**********");
    
    //
    
    //Calling different methods
    
    if([firstBody.node.name  isEqual: @"hero"] && [secondBody.node.name isEqual:@"villian"])
    {
        [self villian:(SKSpriteNode *) secondBody.node didCollideWithHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroJumping"] && [secondBody.node.name isEqual:@"villian"])
    {
        [self villian:(SKSpriteNode *) secondBody.node didJumpedByHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroKicking"] && [secondBody.node.name isEqual:@"villian"])
    {
        [self villian:(SKSpriteNode *) secondBody.node didKickedByHero:(SKSpriteNode *) firstBody.node];
        
    }else if ([firstBody.node.name  isEqual: @"heroPunching"] && [secondBody.node.name  isEqual: @"villian"])
    {
        [self villian:(SKSpriteNode *) secondBody.node didPunchedByHero:(SKSpriteNode *) firstBody.node];
        
    }
}


-(void) moveSecondPerson{
    
    CGPoint location = CGPointMake(_hero.position.x*-1,_hero.position.y);
    //CGFloat multiplierForDirection;
    
    //CGSize screenSize = self.frame.size;
    
   // float bearVelocity =  screenSize.width / 3.0;
    
    //x and y distances for move
    //CGPoint moveDifference = CGPointMake(location.x - _villian.position.x, location.y - _villian.position.y);
    //float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    float moveDuration = 5.0;//distanceToMove / bearVelocity;
    
    _villian.xScale = fabs(_villian.xScale) * -1;
    
    [_villian runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_villianWalkingFramesArray timePerFrame:0.1f resize:NO restore:YES]]];
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        //[_person2 removeAllActions];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [_villian runAction:moveActionWithDone];
    
    //[_person2 removeFromParent];
    if(_villian.position.x<0){
        [_villian removeFromParent];
        
    }
    
    
}

-(void) walkingBear{
    [_hero runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_heroWalkingFramesArray timePerFrame:0.1f resize:NO restore:YES]]];
    return;
}


-(void)bearMoveEnded

{
    
    [_hero removeAllActions];
    
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


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    lastSpawnTimeInterval += timeSinceLast;
    if (lastSpawnTimeInterval > 5 && !stopGame) {
        lastSpawnTimeInterval = 0;
        [self addVillians];
    }
}



-(void)update:(CFTimeInterval)currentTime
{
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
    
    
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 5) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        lastUpdateTimeInterval = currentTime;
        
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
