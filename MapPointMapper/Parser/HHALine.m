//
//  HHALine.m
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "HHALine.h"
#import "HHACoordinate.h"

@implementation HHALine

+ (instancetype)lineFromString:(NSString *)inputString {
    HHALine *line = [[self alloc] init];
    
    NSMutableArray *components = [[inputString componentsSeparatedByString:@","] mutableCopy];
    if (components.count == 1) {
        // duplicate the point so it draws
        [components addObject:components.firstObject];
    }
    
    for (NSString *point in components) {
        [line.points addObject:[HHACoordinate coordinateFromString:point delimiter:nil longitudeFirst:YES]];
    }
    
    return line;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.points = [NSMutableArray array];
    }
    return self;
}

@end
