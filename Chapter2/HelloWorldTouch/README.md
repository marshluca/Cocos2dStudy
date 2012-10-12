### HelloWorldLayer.m
```
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
        // your label needs a tag so we can find it later on
		// you can pick any arbitrary number
		label.tag = 13;
        
        // must be enabled if you want to receive touch events!
		self.isTouchEnabled = YES;				

	}
	return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCNode *node = [self getChildByTag:13];
    
    // defensive programming: verify the returned node is a CCLabel class object
	NSAssert([node isKindOfClass:[CCLabelTTF class]], @"node is not a CCLabel!");
    
    // only after asserting that node is of class CCLabel we should cast it to (CCLabel*)
    CCLabelTTF *label = (CCLabelTTF *)node;
    
    // change the label's scale randomly
	label.scale = CCRANDOM_0_1();
}

```

