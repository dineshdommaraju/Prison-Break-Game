
#import "EndScreen.h"
#import "RITMyScene.h"
 
@implementation GameOverScene
 
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
 
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        NSString * message = @"Game Over";
        SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"Game Over"];
        gameOver.text = message;
        gameOver.fontSize = 40;
        gameOver.fontColor = [SKColor blackColor];
        gameOver.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:gameOver];
 
        [gameOver runAction:[SKAction sequence:@[[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:2.0]]]];
        
     /*  [self runAction:
            [SKAction sequence:@[
                [SKAction waitForDuration:3.0],
                [SKAction runBlock:^{
                    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                    SKScene * myScene = [[RITMyScene alloc] initWithSize:self.size];
                    [self.view presentScene:myScene transition: reveal];
                }]
            ]]
        ];*/
 
    }
    return self;
}
 
@end
