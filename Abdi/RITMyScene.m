//
//  RITMyScene.m
//  Abdi
//
//  Created by Dinesh Dommaraju on 1/30/14.
//  Copyright (c) 2014 Dinesh Dommaraju. All rights reserved.
//

#import "RITMyScene.h"

CFTimeInterval _lastUpdateTime;
CFTimeInterval _dt;

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
    NSArray *_heroWalkingFramesArray;
    NSArray *_heroJumpingMovesArray;
    NSArray *_punchingframes;
    NSArray *_kickingframes;
    UISwipeGestureRecognizer *swipeUpGesture;
    UISwipeGestureRecognizer *swipeLeftGesture;
    UISwipeGestureRecognizer *swipeRightGesture;
    
    
    SKSpriteNode *_villian;
    NSArray *_villianWalkingFramesArray;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.dynamic = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        
        [self initalizingScrollingBackground];
        
        [self initializingCharacterImages];
        
        [self createFloor];
        
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
    
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    
   // myParticle.particlePosition = CGPointMake(100, 100);
    //myParticle.particleBirthRate = 5;
    
    [self addChild:myParticle];
    
}


-(void) didMoveToView:(SKView *)view{
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
    //Adding the images to the array
    NSMutableArray *personArray = [NSMutableArray array];
    
    SKTextureAtlas *frames = [SKTextureAtlas atlasNamed:@"prisoner"];
    
    int numImages = frames.textureNames.count;
    
    for (int i=1; i <= numImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        
        SKTexture *temp = [frames textureNamed:textureName];
        
        //_hero = [SKSpriteNode spriteNodeWithTexture:temp];
        //_hero.name = [NSString stringWithFormat:@"move%d",i ];
        [personArray addObject:temp];
        
    }
    
    _heroWalkingFramesArray = personArray;
    
    //temp purpose
    
    
    NSMutableArray *jumpingArray = [NSMutableArray array];
    SKTextureAtlas *jumpingAtlasFrames = [SKTextureAtlas atlasNamed:@"jumping"];
    numImages = jumpingAtlasFrames.textureNames.count;
    for (int i=1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"jump%d",i];
        SKTexture *temp1 = [jumpingAtlasFrames textureNamed:textureName];
        [jumpingArray addObject:temp1];
    }
    
    _heroJumpingMovesArray = jumpingArray;
    
    
    //Create bear sprite, setup position in middle of the screen, and add to Scene
    
    SKTexture *temp = _heroWalkingFramesArray[0];
    
    _hero = [SKSpriteNode spriteNodeWithTexture:temp];
    
    _hero.position = CGPointMake(60, 65);
    _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.frame.size];
    _hero.physicsBody.dynamic = YES;
    _hero.physicsBody.usesPreciseCollisionDetection = YES;
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.contactTestBitMask = villianCategory;
    _hero.physicsBody.collisionBitMask = villianCategory;
    //_person.physicsBody.categoryBitMask =
    
    
    _hero.name=@"hero";
    [self addChild:_hero];
    [self escape];
    // [self walkingBear];
    // [self handleSwipeRight:swipeRightGesture];
    
    
    //Person 2 moving left
    
    NSMutableArray *villianArray = [NSMutableArray array];
    SKTextureAtlas *villianAtlasaFrames = [SKTextureAtlas atlasNamed:@"prisoner"];
    int numOfImages = villianAtlasaFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        
        SKTexture *temp = [villianAtlasaFrames textureNamed:textureName];
        
        [villianArray addObject:temp];
        
    }
    
    _villianWalkingFramesArray = villianArray;
    
    
    NSMutableArray *kickingArray = [NSMutableArray array];
    SKTextureAtlas *kickingAtlasFrames = [SKTextureAtlas atlasNamed:@"kick"];
    numOfImages = kickingAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"kick%d", i];
        
        SKTexture *temp = [kickingAtlasFrames textureNamed:textureName];
        
        [kickingArray addObject:temp];
        
    }
    
    _kickingframes = kickingArray;
    
    
    NSMutableArray *punchingArray = [NSMutableArray array];
    SKTextureAtlas *punchingAtlasFrames = [SKTextureAtlas atlasNamed:@"punch"];
    numOfImages = punchingAtlasFrames.textureNames.count;
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"punch%d", i];
        
        SKTexture *temp = [punchingAtlasFrames textureNamed:textureName];
        
        [punchingArray addObject:temp];
        
    }
    
    _punchingframes = punchingArray;

    
    
    

    
    SKTexture *temp2 = _villianWalkingFramesArray[0];
    _villian = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _villian.xScale = fabs(_hero.xScale) * -1;
    _villian.position = CGPointMake(CGRectGetWidth(self.frame), 60);
    
    _villian.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_villian.size];
    _villian.physicsBody.dynamic = YES;
    _villian.physicsBody.categoryBitMask = villianCategory;
    _villian.physicsBody.contactTestBitMask = heroCategory;
    _villian.physicsBody.collisionBitMask = heroCategory;
    _villian.physicsBody.usesPreciseCollisionDetection = YES;
    
    _villian.name=@"villian";
    [self addChild:_villian];
    
    [self moveSecondPerson];
    /*
     NSLog(@"Im here");
     
     SKAction *moveTo = [SKAction moveToX:_person.xScale duration:4.0];
     SKAction *keepRunning = [SKAction animateWithTextures:_walkingFrames2 timePerFrame:0.1f resize:NO restore:YES];
     //Actions
     SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
     
     NSLog(@"Animation Completed");
     
     //[self bearMoveEnded];
     [_person2 removeAllActions];
     
     }];
     
     
     
     
     SKAction *moveActionWithDone = [SKAction sequence:@[moveTo, doneAction ]];
     [_person2 runAction: [SKAction sequence:@[keepRunning,moveActionWithDone]]];*/
    /* [_person2 runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_walkingFrames2 timePerFrame:0.1f resize:NO restore:YES]]];*/
    //return;
    /*
     _person2.xScale = fabs(_person.xScale) * -1;
     
     
     [_person2 runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_walkingFrames2 timePerFrame:0.1f resize:NO restore:YES]]];
     return;
     
     //CGPoint moveDifference = (location.x - _person.position.x, location.y - _person.position.y);
     
     SKAction *moveAction = [SKAction moveTo:_person.position duration:4.0];
     
     SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
     
     NSLog(@"Animation Completed");
     
     // [self bearMoveEnded];
     [_person2 removeAllActions];
     
     }];
     
     
     
     SKAction *moveActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
     
     
     
     [_person runAction:moveActionWithDone withKey:@"bearMoving"];*/
    
    
}

-(void) handleSwipeRight{
    
    
    [_hero runAction:[SKAction animateWithTextures: _kickingframes timePerFrame:0.1f]];
    
    
}


-(void) handleSwipeLeft{
    
    
    [_hero runAction:[SKAction animateWithTextures: _punchingframes timePerFrame:0.1f]];
    
    
}


-(void) handleSwipeUp {
    
    [_hero runAction:[SKAction animateWithTextures: _heroJumpingMovesArray timePerFrame:0.1f]];
    
}


- (void) escape{
    
    NSMutableArray *escapeFramesArray = [NSMutableArray array];
    
    SKTextureAtlas *escapeFramesAtlas = [SKTextureAtlas atlasNamed:@"escape"];
    
    int numOfImages = escapeFramesAtlas.textureNames.count;
    
    for (int i=1; i <= numOfImages; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"escape%d", i];
        
        SKTexture *temp = [escapeFramesAtlas textureNamed:textureName];
        
        [escapeFramesArray addObject:temp];
        
    }
    
    NSArray *_escapingFrames = escapeFramesArray;
    
    
    [_hero runAction:[SKAction repeatAction:[SKAction animateWithTextures:_escapingFrames timePerFrame:(2.0f)] count:4]];
    [_hero runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_heroWalkingFramesArray timePerFrame:0.1f resize:NO restore:YES]]];
}

- (void)villian:(SKSpriteNode *)villian didCollideWithHero:(SKSpriteNode *)hero {
    //NSLog(@"%@",villian);
    NSLog(@"Hit");
    NSLog(@"%@",hero.name);
    NSLog(@"%@",villian.name);
    [villian removeFromParent];
    [hero removeFromParent];
    //[projectile removeFromParent];
    //[monster removeFromParent];
}



//logic to handle contact

- (void) didBeginContact:(SKPhysicsContact *) contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & heroCategory ) != 0 &&
        (secondBody.categoryBitMask & villianCategory) != 0)
    {
        [self villian:(SKSpriteNode *) firstBody.node didCollideWithHero:(SKSpriteNode *) secondBody.node];
    }
    
}


-(void) moveSecondPerson{
    
    CGPoint location = CGPointMake(-80, 80);
    //CGFloat multiplierForDirection;
    
    CGSize screenSize = self.frame.size;
    
    float bearVelocity =  screenSize.width / 3.0;
    
    //x and y distances for move
    CGPoint moveDifference = CGPointMake(location.x - _villian.position.x, location.y - _villian.position.y);
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    float moveDuration = distanceToMove / bearVelocity;
    
    _villian.xScale = fabs(_villian.xScale) * -1;
    
    [_villian runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_villianWalkingFramesArray timePerFrame:0.1f resize:NO restore:YES]]];
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        //[_person2 removeAllActions];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [_villian runAction:moveActionWithDone withKey:@"bearMoving"];
    
    //[_person2 removeFromParent];
    if(_villian.position.x<0){
        [_villian removeFromParent];
        
    }
    
    
}
/*
 
 CGPoint location = [[touches anyObject] locationInNode:self];
 CGFloat multiplierForDirection;
 
 CGSize screenSize = self.frame.size;
 
 float bearVelocity =  screenSize.width / 3.0;
 
 //x and y distances for move
 CGPoint moveDifference = CGPointMake(location.x - _bear.position.x, location.y - _bear.position.y);
 float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
 
 float moveDuration = distanceToMove / bearVelocity;
 
 if (moveDifference.x < 0) {
 multiplierForDirection = 1;
 } else {
 multiplierForDirection = -1;
 }
 _bear.xScale = fabs(_bear.xScale) * multiplierForDirection;
 
 if ([_bear actionForKey:@"bearMoving"]) {
 //stop just the moving to a new location, but leave the walking legs movement running
 [_bear removeActionForKey:@"bearMoving"];
 }
 
 if (![_bear actionForKey:@"walkingInPlaceBear"]) {
 //if legs are not moving go ahead and start them
 [self walkingBear];  //start the bear walking
 }
 
 SKAction *moveAction = [SKAction moveTo:moveDifference duration:moveDuration];
 SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
 NSLog(@"Animation Completed");
 [self bearMoveEnded];
 }];
 
 SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
 
 [_bear runAction:moveActionWithDone withKey:@"bearMoving"];
 
 
 
 */
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
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"1"];
        bg.name = @"bg";
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



//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
/* Called when a touch begins */

/*for (UITouch *touch in touches) {
 CGPoint location = [touch locationInNode:self];
 
 SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
 
 sprite.position = location;
 
 SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
 
 [sprite runAction:[SKAction repeatActionForever:action]];
 
 [self addChild:sprite];
 }
 }
 */
/*
 -(void)runImages {
 
 
 CGFloat multiplierForDirection;
 
 float bearVelocity = 3.0;// screenSize.width / 3.0;
 
 
 
 //x and y distances for move
 
 CGPoint moveDifference = CGPointMake(0.0,0.0);//(location.x - _person.position.x, location.y - _person.position.y);
 
 float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
 
 
 
 float moveDuration = 3.0;//distanceToMove / bearVelocity;
 
 
 
 if (moveDifference.x < 0) {
 
 multiplierForDirection = 1;
 
 } else {
 
 multiplierForDirection = -1;
 
 }
 
 _person.xScale = fabs(_person.xScale) * multiplierForDirection;
 // _person.xScale = fabs(_person.xScale);
 
 
 
 if ([_person actionForKey:@"bearMoving"]) {
 
 //stop just the moving to a new location, but leave the walking legs movement running
 
 [_person removeActionForKey:@"bearMoving"];
 
 }
 
 
 
 if (![_person actionForKey:@"walkingInPlaceBear"]) {
 
 //if legs are not moving go ahead and start them
 
 [self walkingBear];  //start the bear walking
 
 }
 
 
 
 SKAction *moveAction = [SKAction moveTo:_person.position duration:moveDuration];
 
 SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
 
 NSLog(@"Animation Completed");
 
 [self bearMoveEnded];
 
 }];
 
 
 
 SKAction *moveActionWithDone = [SKAction sequence:@[moveAction, doneAction ]];
 
 
 
 [_person runAction:moveActionWithDone withKey:@"bearMoving"];
 
 }
 */

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
}

@end
