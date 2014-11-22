//
//  HHACoordinate.h
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface HHACoordinate : NSObject

///
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  <#Description#>
 *
 *  @param latitutde <#latitutde description#>
 *  @param longitude <#longitude description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)coordianteWithLatString:(NSString *)latitutde lngString:(NSString *)longitude;

/**
 *  <#Description#>
 *
 *  @param input          <#input description#>
 *  @param delimeter      <#delimeter description#>
 *  @param longitudeFirst <#longitudeFirst description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)coordinateFromString:(NSString *)input delimiter:(NSString *)delimeter longitudeFirst:(BOOL)longitudeFirst;

/**
 *  <#Description#>
 *
 *  @param latitutde <#latitutde description#>
 *  @param longitude <#longitude description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithLatString:(NSString *)latitutde lngString:(NSString *)longitude;

@end
