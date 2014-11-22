//
//  HHACoordinate.m
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "HHACoordinate.h"

@implementation HHACoordinate

#pragma mark - Class Methods
+ (instancetype)coordianteWithLatString:(NSString *)latitutde lngString:(NSString *)longitude {
    return [[self alloc] initWithLatString:latitutde lngString:longitude];
}

+ (instancetype)coordinateFromString:(NSString *)input delimiter:(NSString *)delimeter longitudeFirst:(BOOL)longitudeFirst {
    if (!delimeter) { delimeter = @" "; }
    NSString *strippedInput = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                               
    NSArray *components = [strippedInput componentsSeparatedByString:delimeter];
    
    NSString *lat, *lng;
    if (longitudeFirst) {
        lat = [components lastObject];
        lng = [components firstObject];
    } else {
        lat = [components firstObject];
        lng = [components lastObject];
    }
    
    return [self coordianteWithLatString:lat lngString:lng];
}

#pragma mark - Instance Methods
- (instancetype)initWithLatString:(NSString *)latitutde lngString:(NSString *)longitude {
    self = [super init];
    if (self) {
        double lat = [latitutde doubleValue];
        double lng = [longitude doubleValue];
        self.coordinate = CLLocationCoordinate2DMake(lat, lng);
    }
    return self;
}
@end
