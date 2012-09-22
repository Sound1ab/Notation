//
//  PRPSimpleScatterPlot.h
//  CorePlot
//
//  Created by Phillip Parker on 30/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface PRPAmplitudePlot : NSObject{
    CPTGraphHostingView *_hostingView;
    CPTXYGraph *_graph;
    NSMutableArray *_graphData;
}

@property (nonatomic, retain) CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) NSMutableArray *graphData;

// Method to create this object and attach it to it's hosting view.
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;

// Specific code that creates the scatter plot.
-(void)initialisePlot;

@end
