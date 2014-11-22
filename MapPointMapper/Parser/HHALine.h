//
//  HHALine.h
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHALine : NSObject
/// Array of HHACoordinate Points
@property (strong, nonatomic) NSMutableArray *points;

/**
 *  <#Description#>
 *
 *  @param inputString <#inputString description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)lineFromString:(NSString *)inputString;
@end
