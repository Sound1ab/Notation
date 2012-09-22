//
//  UIView+Animation.m
//  SplitView_AudioQueues_FFT_Graphs_Gate
//
//  Created by Phillip Parker on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)
- (void) moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option
{
    //Use the animateWithduration API to move an object from its current position to a new position
    //All intermediary steps will be calculated by this function
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

@end
