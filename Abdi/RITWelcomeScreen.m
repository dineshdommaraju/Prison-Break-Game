//
//  RITWelcomeScreen.m
//  Abdi
//
//  Created by Abhilash Srinivasaraju Padmavathi on 2/2/14.
//  Copyright (c) 2014 Dinesh Dommaraju. All rights reserved.
//

#import "RITWelcomeScreen.h"
#import "RITMyScene.h"


@interface RITWelcomeScreen()

@property BOOL contentCreated;

@end


@implementation RITWelcomeScreen

-(void) didMoveToView:(SKView *)view{
    if(!self.contentCreated){
        NSLog(@"here");
        [self options];
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void) createSceneContents{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild:[self welcomeScreen]];
    [self addChild:[self options]];
}

-(SKLabelNode *) welcomeScreen{
    SKLabelNode *welcome = [SKLabelNode labelNodeWithFontNamed:@"welcome"];
    
    welcome.text = @"Tap to start the Game";
    welcome.name = @"welcome";
    welcome.fontSize = 20;
    welcome.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    [self options];
   return welcome;
    
}

-(SKLabelNode *) options{
    SKLabelNode *controls = [SKLabelNode labelNodeWithFontNamed:@"controls"];
    NSString *controlOne = @"1. Swipe right to kick";
    NSString *controlTwo = @"2. Swipe Left to punch";
    NSString *controlThree = @"3. Swipe up to jump";
    controls.text = [NSString stringWithFormat: @"%@ \n %@ \n %@",controlOne,controlTwo,controlThree];
    controls.name = @"controls";
    controls.fontSize = 10;
    controls.position = CGPointMake(CGRectGetMidX(self.frame) , CGRectGetMidY(self.frame)-40);
    return controls;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SKNode *welcome = [self childNodeWithName:@"welcome"];
    if(welcome !=nil){
        welcome.name = nil;
        
        //Create actions
        SKAction *moveUp = [SKAction moveByX:0 y:100.0 duration:0.5];
        SKAction *zoom = [SKAction scaleTo:1.0 duration:0.25];
        SKAction *pause = [SKAction waitForDuration:0.25];
        SKAction *fadeAway = [SKAction fadeOutWithDuration:0.25];
        SKAction *remove = [SKAction removeFromParent];
        
        //Put in a sequence
        SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
        
        //Run the action and transition to spaceshipscene
        [welcome runAction:moveSequence completion:^{
            SKScene *gameScene = [[RITMyScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:gameScene transition:doors];
        }];
    }
}

@end
