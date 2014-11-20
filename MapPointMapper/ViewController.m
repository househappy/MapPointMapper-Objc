//
//  ViewController.m
//  MapPointMapper
//
//  Created by Daniel on 11/18/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

@import MapKit;
#import "ViewController.h"

@interface DMMMapPoint : NSObject
@property (nonatomic) CLLocationCoordinate2D coordinate;
- (instancetype)initWithLatString:(NSString *)latitutde lngString:(NSString *)longitude;
@end
@implementation DMMMapPoint
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

@interface ViewController() <MKMapViewDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet MKMapView *mapview;
@property (weak) IBOutlet NSButton *loadFileButton;
@property (weak) IBOutlet NSButton *removeLastLineButton;
@property (weak) IBOutlet NSButton *removeAllLinesButton;
@property (weak) IBOutlet NSButton *switchLatLngButton;
@property (weak) IBOutlet NSTextField *latlngLabel;

@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButton *textFieldButton;
@property (weak) IBOutlet NSColorWell *colorWell;

@property (nonatomic) BOOL parseLatitudeFirst;
@end

@implementation ViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapview.delegate = self;
    self.textField.delegate = self;
    self.parseLatitudeFirst = YES;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.title = @"Map Point Mapper";
}

#pragma mark - Drawing
- (void)drawPointsOnMap:(NSArray *)mapPoints {
    NSInteger count = 0;
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * mapPoints.count);
    
    for (DMMMapPoint *mapPoint in mapPoints) {
        coordinates[count] = mapPoint.coordinate;
        ++count;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
    
    [self.mapview addOverlay:polyline level:MKOverlayLevelAboveRoads];
    
    [self.mapview setNeedsDisplay:YES];
    [self.mapview setVisibleMapRect:polyline.boundingMapRect animated:YES];
    
    free(coordinates);
}

#pragma mark - Actions
- (IBAction)removeLastLinePressed:(NSButton *)sender {
    if (self.mapview.overlays && self.mapview.overlays.count > 0) {
        [self.mapview removeOverlay:self.mapview.overlays.lastObject];
    }
}

- (IBAction)clearLinesButtonPressed:(NSButton *)sender {
    [self.mapview removeOverlays:self.mapview.overlays];
}

- (IBAction)loadFilePressed:(NSButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = NO;
    
    [openPanel beginSheetModalForWindow:nil completionHandler:^(NSInteger result) {
        NSLog(@"result: %li", result);
        NSLog(@"%@", [openPanel URLs]);
        [self readFileAtURL:openPanel.URL];
    }];
}
- (IBAction)addLineFromTextPressed:(NSButton *)sender {
    if (self.textField.stringValue) {
        [self parseInput:self.textField.stringValue];
    }
}
- (IBAction)switchLatLngPressed:(NSButton *)sender {
    self.parseLatitudeFirst = !self.parseLatitudeFirst;
    if (self.parseLatitudeFirst) {
        self.latlngLabel.stringValue = @"Lat/Lng";
    } else {
        self.latlngLabel.stringValue = @"Lng/Lat";
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *mapOverlayRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    mapOverlayRenderer.alpha = 1.0;
    mapOverlayRenderer.lineWidth = 4.0;
    mapOverlayRenderer.strokeColor = self.colorWell.color;
    return  mapOverlayRenderer;
}
#pragma mark - Implementation
- (void)readFileAtURL:(NSURL *)fileURL {
    if (!fileURL) { return; }
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:fileURL.absoluteString]) {
        NSLog(@"ERROR: Unreadable file at %@", fileURL);
    }
    
    NSError *error;
    NSString *fileContentsString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    
    [self parseInput:fileContentsString];
}

- (void)parseInput:(NSString *)input {
    NSString *strippedSpaces = [[input stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
    NSArray *components = [strippedSpaces componentsSeparatedByString:@","];
    
    if (components.count % 2 != 0) {
        NSError *invalidCountError = [NSError errorWithDomain:@"com.dmiedema.MapPointMapper" code:-42 userInfo:@{NSLocalizedDescriptionKey: @"Invalid number of map points given"}];
        [[NSAlert alertWithError:invalidCountError] runModal];
        return;
    }
    if (components.count == 2) {
        NSMutableArray *mutableComponents = [components mutableCopy];
        [mutableComponents addObjectsFromArray:components];
        components = mutableComponents;
    }
    
    NSMutableArray *mapPoints = [@[] mutableCopy];
    for (NSInteger i = 0; i < components.count - 1; i += 2) {
        NSString *lat, *lng;
        if (self.parseLatitudeFirst) {
            lat = [components objectAtIndex:i];
            lng = [components objectAtIndex:i + 1];
        } else {
            lng = [components objectAtIndex:i];
            lat = [components objectAtIndex:i + 1];
        }
        
        [mapPoints addObject:[[DMMMapPoint alloc] initWithLatString:lat lngString:lng]];
    }
    
    [self drawPointsOnMap:mapPoints];
}

#pragma mark - NSTextFieldDelegate
- (void)keyUp:(NSEvent *)theEvent {
    if (theEvent.keyCode == 36) {
        [self addLineFromTextPressed:self.textFieldButton];
    }
}

@end
