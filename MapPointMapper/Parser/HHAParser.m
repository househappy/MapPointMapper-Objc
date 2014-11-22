//
//  HHAParser.m
//  MapPointMapper
//
//  Created by Daniel on 11/21/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "HHAParser.h"
#import "HHALine.h"
#import "HHACoordinate.h"

BOOL HHARangeIsEmptyRange(NSRange range) {
    return range.location == NSNotFound && range.length == 0;
}

@interface HHAParser()
@property (strong, nonatomic) NSMutableArray *geometries;
@property (nonatomic) HHAGeometryType geometryType;
@property (strong, nonatomic) NSString *tailStringContents;
@end

HHAGeometryType HHAGeometryTypeForInput(NSString *input) {
    if (!input) { return HHAGeometryTypeInvalid; }
    HHAGeometryType type = HHAGeometryTypeUnknown;
    
    if ([input containsString:@"MULTIPOINT"]) {
        type = HHAGeometryTypeMultiPoint;
    } else if ([input containsString:@"MULTILINESTRING"]) {
        type = HHAGeometryTypeMultiLineString;
    } else if ([input containsString:@"MULTIPOLYGON"]) {
        type = HHAGeometryTypeMultiPolygon;
    } else if ([input containsString:@"POINT"]) {
        type = HHAGeometryTypePoint;
    } else if ([input containsString:@"LINE"]) {
        type = HHAGeometryTypeLineString;
    } else if ([input containsString:@"POLYGON"]) {
        type = HHAGeometryTypePolygon;
    } else if ([input containsString:@"GEOMETRYCOLLECTION"]){
        type = HHAGeometryTypeGeometryCollection;
    }
    
    return type;
}

HHALine * HHAParseLineString(NSString *lineString) {
    return nil;
}

NSString * HHAExtractPointsFromString(NSString *lineString) {
    NSRange firstParen = [lineString rangeOfString:@"("];
    NSRange secondParen = [lineString rangeOfString:@")" options:NSBackwardsSearch];
    
    if (HHARangeIsEmptyRange(firstParen) && HHARangeIsEmptyRange(secondParen)) {
        return lineString;
    } else if (HHARangeIsEmptyRange(firstParen) || HHARangeIsEmptyRange(secondParen)) {
        // Something went terribly wrong and we have unbalanced parens in our input
        // returning @c nil is our way of returning an error/invalid data
        // ie: you dun fucked up
        return nil;
    }
    
    NSUInteger rangeLocation = firstParen.location + 1;
    NSUInteger rangeLength = (secondParen.location - firstParen.location) - 1;
    
    return [lineString substringWithRange:NSMakeRange(rangeLocation, rangeLength)];
}

NSRange HHARangeOfParenPairInString(NSString *input) {
    NSInteger openParenCount = 0;
    NSInteger closeParenCount = 0;
    
    NSRange range = NSMakeRange(0, 0);
    
    NSInteger firstParenLocation = [input rangeOfString:@"("].location;
    
    if (firstParenLocation == NSNotFound) { return NSMakeRange(NSNotFound, 0); }
    
    for (NSInteger i = firstParenLocation; i < input.length; i++) {
        unichar c = [input characterAtIndex:i];
        NSString *s = [NSString stringWithCharacters:&c length:1];
        
        if ([s isEqualToString:@"("]) { ++openParenCount; }
        else if ([s isEqualToString:@")"]) { ++closeParenCount; }
        
        if (openParenCount == closeParenCount) {
            range = NSMakeRange(firstParenLocation, i);
            break;
        }
    }
    return range;
}

@implementation HHAParser
#pragma mark - Class Methods
+ (NSArray *)linesFromString:(NSString *)input {
    HHAParser *parser = [[self alloc] init];
    parser.geometryType = HHAGeometryTypeForInput(input);
    
    NSString *firstStrip = HHAExtractPointsFromString(input);

    return [parser beginParsing:firstStrip];;
}

#pragma mark - Instance Methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.geometries = [NSMutableArray array];
    }
    return self;
}


- (NSArray *)beginParsing:(NSString *)initial {
    if (self.geometryType == HHAGeometryTypeLineString || self.geometryType == HHAGeometryTypeMultiPoint) {
        return @[initial];
    }
    
    NSRange firstSetRange = HHARangeOfParenPairInString(initial);
    if (firstSetRange.length == initial.length) {
        NSString *strip = [self parseInput:initial];
        
    }
    
    return self.geometries;
}

- (NSString *)parseInput:(NSString *)input {
    NSString *initaillyStrippedInput = HHAExtractPointsFromString(input);
    
    NSInteger openParenCount = 0;
    NSInteger closeParenCount = 0;
    NSString *parseString;
    
    NSInteger firstParenLocation = [initaillyStrippedInput rangeOfString:@"("].location;
    
    if (firstParenLocation == NSNotFound) { return initaillyStrippedInput; }
    
    for (NSInteger i = firstParenLocation; i < initaillyStrippedInput.length; i++) {
        unichar c = [initaillyStrippedInput characterAtIndex:i];
        NSString *s = [NSString stringWithCharacters:&c length:1];
        
        if ([s isEqualToString:@"("]) { ++openParenCount; }
        else if ([s isEqualToString:@")"]) { ++closeParenCount; }
        
        if (openParenCount == closeParenCount) {
            parseString = [initaillyStrippedInput substringWithRange:NSMakeRange(firstParenLocation, i)];
            break;
        }
    }
    return parseString;
}

@end
