//
//  HHAParser.h
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HHAGeometryType) {
    HHAGeometryTypePoint = 0,
    HHAGeometryTypeMultiPoint,
    HHAGeometryTypeLineString,
    HHAGeometryTypeMultiLineString,
    HHAGeometryTypePolygon,
    HHAGeometryTypeMultiPolygon,
    HHAGeometryTypeGeometryCollection,
    HHAGeometryTypeUnknown,
    HHAGeometryTypeInvalid
};

@interface HHAParser : NSObject

+ (NSArray *)linesFromString:(NSString *)input;
@end
