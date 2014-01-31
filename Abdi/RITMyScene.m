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
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@implementation RITMyScene{
    SKSpriteNode *_person;
    NSArray *_walkingFrames;
    NSArray *_newArray;
    UISwipeGestureRecognizer *swipeRightGesture;
    
    
    SKSpriteNode *_person2;
    NSArray *_walkingFrames2;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.dynamic = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);

        [self initalizingScrollingBackground];
        
        [self initializingCharacterImages];
        
        [self createFloor];
        
        // [self handleSwipeRight:(swipeRightGesture)];
        
        
        
    }
    return self;
}


-(void) didMoveToView:(SKView *)view{
    swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(handleSwipeRight)];
    [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer: swipeRightGesture];
}

-(void) handleSwipeRight{
    NSLog(@"In swipe");
    //[self bearMoveEnded];
    
    //SKTexture *temp = _newArray[0];
    
    //_person = [SKSpriteNode spriteNodeWithTexture:temp];
    
    
    
    [_person runAction:[SKAction animateWithTextures:_newArray timePerFrame:0.1f]];
    
    SKAction *moveAction = [SKAction moveToY:500 duration:2.0];
    [_person runAction:moveAction];
    
    [_person runAction:[SKAction moveToY:80 duration:4.0]];
    
    
    NSLog(@"In swipe Ended");
  // [self walkingBear];
   //[_person runAction:[SKAction animateWithTextures:_newArray timePerFrame:1.0f]];
    
}




-(void) createFloor{
    SKSpriteNode *floor = [self newFloor];
    floor.position = CGPointMake(0, 0);
    [self addChild:floor];
}

-(SKSpriteNode*) newFloor{
    SKSpriteNode *completeFloor = [[SKSpriteNode alloc] initWithColor:[SKColor darkGrayColor] size:CGSizeMake((CGRectGetWidth(self.frame)*2), 40)];
    
    return completeFloor;
}

-(void) initializingCharacterImages{
    //Adding the images to the array
    NSMutableArray *personArray = [NSMutableArray array];
    
    SKTextureAtlas *frames = [SKTextureAtlas atlasNamed:@"prisoner"];
    
    int numImages = frames.textureNames.count;
    
    for (int i=1; i <= numImages-6; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        
        SKTexture *temp = [frames textureNamed:textureName];
        
        [personArray addObject:temp];
        
    }
    
    _walkingFrames = personArray;
    
    //temp purpose
    
    
    NSMutableArray *newPersonArray = [NSMutableArray array];
    SKTextureAtlas *frames1 = [SKTextureAtlas atlasNamed:@"prisoner"];
    int i=1;
    while(i<7){
    NSString *textureName = [NSString stringWithFormat:@"jump%d",i];
    SKTexture *temp1 = [frames1 textureNamed:textureName];
    [newPersonArray addObject:temp1];
    i++;
    }
    
    _newArray = newPersonArray;
    
    // SKTexture *temp = _walkingFrames[0];
    
    
    
    
    //Create bear sprite, setup position in middle of the screen, and add to Scene
    
    SKTexture *temp = _walkingFrames[0];
    
    _person = [SKSpriteNode spriteNodeWithTexture:temp];
    
    _person.position = CGPointMake(60, 80);
    
    _person.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_person.size];
    //_person.physicsBody.dynamic = NO;
    //_person.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:_person];
    [self walkingBear];
   // [self handleSwipeRight:swipeRightGesture];
    
    
    //Person 2 moving left
    
    NSMutableArray *personArray1 = [NSMutableArray array];
    
    SKTextureAtlas *frames2 = [SKTextureAtlas atlasNamed:@"prisoner"];
    
    int numOfImages = frames2.textureNames.count;
    
    for (int i=1; i <= numOfImages-6; i++) {
        
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        
        SKTexture *temp = [frames2 textureNamed:textureName];
        
        [personArray1 addObject:temp];
        
    }
    
    _walkingFrames2 = personArray1;
    
    SKTexture *temp2 = _walkingFrames2[0];
    _person2 = [SKSpriteNode spriteNodeWithTexture:temp2];
    
    _person2.xScale = fabs(_person.xScale) * -1;
    _person2.position = CGPointMake(CGRectGetWidth(self.frame), 80);
    
    _person2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_person2.size];
    //_person2.physicsBody.dynamic = NO;
    //_person2.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:_person2];
    
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


-(void) moveSecondPerson{
    
    CGPoint location = CGPointMake(-80, 80);
    //CGFloat multiplierForDirection;
    
    CGSize screenSize = self.frame.size;
    
    float bearVelocity =  screenSize.width / 3.0;
    
    //x and y distances for move
    CGPoint moveDifference = CGPointMake(location.x - _person2.position.x, location.y - _person2.position.y);
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    float moveDuration = distanceToMove / bearVelocity;
    
    _person2.xScale = fabs(_person2.xScale) * -1;
    
    [_person2 runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_walkingFrames2 timePerFrame:0.1f resize:NO restore:YES]]];
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        //[_person2 removeAllActions];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction ]];
    
    [_person2 runAction:moveActionWithDone withKey:@"bearMoving"];
    
    //[_person2 removeFromParent];
    if(_person2.position.x<0){
    [_person2 removeFromParent];
    
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
    [_person runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_walkingFrames timePerFrame:0.1f resize:NO restore:YES]]];
    return;
}


-(void)bearMoveEnded

{
    
    [_person removeAllActions];
    
}

-(void)initalizingScrollingBackground
{
    for(int i =0 ; i < 2 ; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"1"];
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
