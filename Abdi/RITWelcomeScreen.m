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
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void) createSceneContents{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
    [self addChild:[self welcomeScreen]];
}

-(SKLabelNode *) welcomeScreen{
    SKLabelNode *welcome = [SKLabelNode labelNodeWithFontNamed:@"ChalkDuster"];
    
    welcome.text = @"Touch the screen to start the Game";
    welcome.name = @"welcome";
    welcome.fontSize = 10;
    welcome.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return welcome;
    
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
