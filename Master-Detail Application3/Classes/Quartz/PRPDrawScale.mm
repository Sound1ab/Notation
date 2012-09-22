//
//  PRPDrawScale.m
//  SplitView_AudioQueues_FFT_Graphs_Gate
//
//  Created by Phillip Parker on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//lengths to draw scale and images correctly
#define kNoteOffsetX 15
#define kNoteOffsetY 22
#define kNoteOffsetYHigher 5

#define kNoteStepY 7.75

#define kStepX 6.3


#define kScaleLeft 0
#define kScaleRight 685
#define kScaleOffsetY 15.5
#define kScale2OffsetY 108.5
#define kScaleStepY 15.5

#define kStepY 50
#define kOffsetY 10

#import "PRPDrawScale.h"

@implementation PRPDrawScale
@synthesize data;
@synthesize detailViewController = _detailViewController;
@synthesize fileToDraw;
@synthesize noteIncrease;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {

    }
    return self;
}

-(void)currentData:playDate{
    
    //Instantiate the array
    data = [NSMutableArray arrayWithCapacity:76];
    //Create the path of the data required
    NSString *noteIndex = [NSString stringWithFormat:@"note_%@",playDate];
    NSLog(@"string location: %@",noteIndex);
    //Find the documents directory
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    
    //Concatinate the documents directory URL with the storage plist
    NSString *plistFile = [documentFolder stringByAppendingPathComponent:@"Storage.plist"];
    
    NSString *bundleFile = [[NSBundle mainBundle]pathForResource:@"Storage" ofType:@"plist"];
    
    
    //Copy the file from the bundle to the doc directory 
    [[NSFileManager defaultManager]copyItemAtPath:bundleFile toPath:plistFile error:nil];
    //Copy the current contents of the plist to an 	NSDictionary
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    //Extract data from the NSDictionary at the index specifed
    NSMutableArray *noteDataFromPlist = [dict valueForKey:noteIndex];
    
    //Copy the extracted data from the Array into the data 	array
    for (int i = 0; i < 103; i++) {
        NSNumber *note = [NSNumber numberWithFloat:[[noteDataFromPlist objectAtIndex:i] floatValue]];
        
        [data insertObject:note atIndex:i];
                
    }
    
    //Update the view
    [self setNeedsDisplay];
    
}
-(void)increaseNotes:(NSNumber *) increase{
    //Set the public variable noteIncrease to the input parameter
    noteIncrease = increase;
    //Update the drawRect method
    [self setNeedsDisplay];

    
}
- (void)drawRect:(CGRect)rect
{
    //Get the graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Reverses the co-ordination system so that values increasing will represent moving up on the 
    //screen. This is why the image is made upside down. 
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    //Import Treble Clef image
    UIImage *trebleClef = [UIImage imageNamed:@"trebleclef.png"];
    //Set the location to draw
    CGPoint imagePointTreble = CGPointMake(0,kScale2OffsetY-20);
    //Draw the image
    [trebleClef drawAtPoint:imagePointTreble];
    
    //Import Bass Clef Image
    UIImage *bassClef = [UIImage imageNamed:@"bassclef.png"];
    //Set the location to draw
    CGPoint imagePointBass = CGPointMake(1,kScaleOffsetY+12.5);
    //Draw the imagine
    [bassClef drawAtPoint:imagePointBass];
    
    //Set a line width
    CGContextSetLineWidth(context, 2.0);
    //Set the colour of the line
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    //Create the lines at the positions specifed by the defines
    for (int i = 0; i < 5; i++)
    {
        //Specify to the start point
        CGContextMoveToPoint(context,kScaleLeft , kScaleOffsetY + i * kScaleStepY);
        //Specify the end point
        CGContextAddLineToPoint(context,kScaleRight , kScaleOffsetY + i * kScaleStepY);
    }
    
    //Draw the line
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    for (int i = 0; i < 5; i++)
    {
        //Specify to the start point
        CGContextMoveToPoint(context,kScaleLeft , kScale2OffsetY + i * (kScaleStepY));
        //Specify the end point
        CGContextAddLineToPoint(context,kScaleRight , kScale2OffsetY + i * (kScaleStepY));
    }
    
    CGContextStrokePath(context);

    for (int i = 4; i < 103; i++) {
        //Import note images
        UIImage *myImage = [UIImage imageNamed:@"notelower.png"];
        UIImage *myImageBar = [UIImage imageNamed:@"notelowerbar.png"];
        UIImage *myImageSharp = [UIImage imageNamed:@"notelowersharp.png"];
        UIImage *myImageBarSharp = [UIImage imageNamed:@"notelowerbarsharp.png"];
        UIImage *myImagehigher = [UIImage imageNamed:@"notehigher.png"];
        UIImage *myImagehigherBar = [UIImage imageNamed:@"notehigherbar.png"];
        UIImage *myImagehigherSharp = [UIImage imageNamed:@"notehighersharp.png"];
        UIImage *myImagehigherBarSharp = [UIImage imageNamed:@"notehigherbarsharp.png"];

        //Inspect each index and position images accordingly
        //First chromatic scale
        if ([[data objectAtIndex:i]intValue] > 0 && [[data objectAtIndex:i]intValue] <= 12  ) {
            
            //First note whole tone
            if ([[data objectAtIndex:i]intValue] == 1)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*[[data objectAtIndex:i]intValue]));
                    [myImage drawAtPoint:imagePoint];
                    printf("1");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 2)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-1)));
                [myImageSharp drawAtPoint:imagePoint];
                 printf("2");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 3)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-1)));
                [myImage drawAtPoint:imagePoint];
                printf("3");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 4)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-2)));
                [myImageSharp drawAtPoint:imagePoint];
                printf("4");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 5)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-2)));
                [myImage drawAtPoint:imagePoint];
                printf("5");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 6)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-2)));
                [myImage drawAtPoint:imagePoint];
                printf("6");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 7)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-3)));
                [myImageSharp drawAtPoint:imagePoint];
                printf("7");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 8)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-3)));
                [myImage drawAtPoint:imagePoint];
                printf("8");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 9)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-4)));
                [myImageSharp drawAtPoint:imagePoint];
                printf("9");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 10)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-4)));
                [myImage drawAtPoint:imagePoint];
                printf("10");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 11)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-5)));
                [myImageSharp drawAtPoint:imagePoint];
                printf("11");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 12)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-5)));
                [myImage drawAtPoint:imagePoint];
                printf("12");
            }
        }

        
        
        
        
        
        //Second chromatic scale
        if ([[data objectAtIndex:i]intValue] > 12 && [[data objectAtIndex:i]intValue] <= 24  ) {
            
            //First note whole tone
            if ([[data objectAtIndex:i]intValue] == 13)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*([[data objectAtIndex:i]intValue]-5)));
                [myImageBar drawAtPoint:imagePoint];
                printf("13");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 14)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-6))));
                [myImageBarSharp drawAtPoint:imagePoint];
                printf("14");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 15)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-6))));
                [myImage drawAtPoint:imagePoint];
                printf("15");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 16)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-7))));
                [myImageSharp drawAtPoint:imagePoint];
                printf("16");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 17)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-7))));
                [myImage drawAtPoint:imagePoint];
                printf("17");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 18)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-7))));
                [myImage drawAtPoint:imagePoint];
                printf("18");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 19)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-8))));
                [myImageSharp drawAtPoint:imagePoint];
                printf("19");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 20)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-8))));
                [myImage drawAtPoint:imagePoint];
                printf("20");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 21)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-9))));
                [myImageSharp drawAtPoint:imagePoint];
                printf("21");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 22)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-9))));
                [myImage drawAtPoint:imagePoint];
                printf("22");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 23)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-10))));
                [myImageSharp drawAtPoint:imagePoint];
                printf("23");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 24)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetY+(kNoteStepY*(([[data objectAtIndex:i]intValue]-10))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("24");
            }

        }
        
        //Third chromatic scale
        if ([[data objectAtIndex:i]intValue] > 24 && [[data objectAtIndex:i]intValue] <= 36  ) {
            
            //First note whole tone
            if ([[data objectAtIndex:i]intValue] == 25)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*([[data objectAtIndex:i]intValue]-10)));
                [myImagehigher drawAtPoint:imagePoint];
                printf("25");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 26)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-11))));
                [myImagehigherSharp drawAtPoint:imagePoint];
                printf("26");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 27)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-11))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("27");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 28)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-12))));
                [myImagehigherSharp drawAtPoint:imagePoint];
                printf("28");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 29)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-12))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("29");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 30)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-12))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("30");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 31)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-13))));
                [myImagehigherSharp drawAtPoint:imagePoint];
                printf("31");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 32)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-13))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("32");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 33)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-14))));
                [myImagehigherSharp drawAtPoint:imagePoint];
                printf("33");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 34)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-14))));
                [myImagehigherBar drawAtPoint:imagePoint];
                printf("34");
            }
            //Semi tone
            if ([[data objectAtIndex:i]intValue] == 35)
            {
                
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-15))));
                [myImagehigherBarSharp drawAtPoint:imagePoint];
                printf("35");
            }
            //Whole tone
            if ([[data objectAtIndex:i]intValue] == 36)
            {
                CGPoint imagePoint = CGPointMake(kNoteOffsetX+(kStepX*(i)),kNoteOffsetYHigher+(kNoteStepY*(([[data objectAtIndex:i]intValue]-15))));
                [myImagehigher drawAtPoint:imagePoint];
                printf("36");
            }
            

        }
        //Increase or decrease note frequency
        i = i+[noteIncrease intValue];

        
    }
}

@end
