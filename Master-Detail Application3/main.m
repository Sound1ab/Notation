//
//  main.m
//  Master-Detail Application3
//
//  Created by Phillip Parker on 19/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PRPAppDelegate.h"

#import "PRPIosAudioController.h"


int main(int argc, char *argv[])
{
    @autoreleasepool {
        iosAudio = [[PRPIosAudioController alloc] init];

        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PRPAppDelegate class]));
    }
}
