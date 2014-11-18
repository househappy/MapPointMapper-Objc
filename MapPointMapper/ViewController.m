//
//  ViewController.m
//  MapPointMapper
//
//  Created by Daniel on 11/18/14.
//  Copyright (c) 2014 Househappy. All rights reserved.
//

#import "ViewController.h"
@import MapKit;

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

@interface ViewController() <NSOpenSavePanelDelegate, MKMapViewDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet MKMapView *mapview;
@property (weak) IBOutlet NSButton *loadFileButton;
@property (weak) IBOutlet NSButton *mapPointsButton;
@property (weak) IBOutlet NSButton *clearLinesButton;

@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButton *textFieldButton;

@property (weak) IBOutlet NSTextField *outputLabel;

@property (strong, nonatomic) NSArray *mapPoints;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapview.delegate = self;
    self.textField.delegate = self;
    self.mapPointsButton.enabled = NO;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.title = @"Map Point Mapper";
    self.outputLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.outputLabel.stringValue = @"Map Point Mapper\nv0.0.1";
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
- (IBAction)enterAsTextPressed:(NSButton *)sender {
    if (self.textField.stringValue) {
        [self parseInput:self.textField.stringValue];
    }
}

- (IBAction)mapPointsButtonPresssed:(NSButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // map points
    
    NSInteger count = 0;
    CLLocationCoordinate2D *mappoints = malloc(sizeof(CLLocationCoordinate2D) * self.mapPoints.count);
    for (DMMMapPoint *mapPoint in self.mapPoints) {
        mappoints[count] = mapPoint.coordinate;
        ++count;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:mappoints count:count];
    
    [self.mapview addOverlay:polyline level:MKOverlayLevelAboveRoads];
    
    [self.mapview setNeedsDisplay:YES];
    [self.mapview setVisibleMapRect:polyline.boundingMapRect animated:YES];
    
    free(mappoints);
}
- (IBAction)clearLinesButtonPressed:(NSButton *)sender {
    [self.mapview removeOverlays:self.mapview.overlays];
}


#pragma mark - MapView

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *mapOverlayRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    mapOverlayRenderer.alpha = 1.0;
    mapOverlayRenderer.lineWidth = 4.0;
    mapOverlayRenderer.strokeColor = [NSColor colorWithRed:59.0f/255.0f green:173.0f/255.0f blue:253.0f/255.0f alpha:1];
    return  mapOverlayRenderer;
}
#pragma mark - Implementation
- (void)readFileAtURL:(NSURL *)fileURL {
    if (!fileURL) { return; }
    
    self.mapPointsButton.enabled = NO;
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:fileURL.absoluteString]) {
        NSLog(@"ERROR: Unreadable file at %@", fileURL);
        self.outputLabel.stringValue = [NSString stringWithFormat:@"ERROR: Unreadable file at %@", fileURL];
    }
    
    NSError *error;
    NSString *fileContentsString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        self.outputLabel.stringValue = [NSString stringWithFormat:@"ERROR: reaing file: %@", fileURL];
        [[NSAlert alertWithError:error] runModal];
        return;
    }
    
    [self parseFileString:fileContentsString];
}

- (void)parseFileString:(NSString *)fileContentsString {
    NSString *newLinesRemoved = [fileContentsString stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
    [self parseInput:newLinesRemoved];
}

- (void)parseInput:(NSString *)input {
    NSString *strippedSpaces = [input stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *components = [strippedSpaces componentsSeparatedByString:@","];
    
    if (components.count % 2 != 0) {
        NSError *invalidCountError = [NSError errorWithDomain:@"com.dmiedema.MapPointMapper" code:-42 userInfo:@{NSLocalizedDescriptionKey: @"Invalid number of map points given"}];
        [[NSAlert alertWithError:invalidCountError] runModal];
        return;
    }
    
    NSMutableArray *arr = [@[] mutableCopy];
    for (NSInteger i = 0; i < components.count - 1; i += 2) {
        NSString *lat = [components objectAtIndex:i];
        NSString *lng = [components objectAtIndex:i + 1];
        
        [arr addObject:[[DMMMapPoint alloc] initWithLatString:lat lngString:lng]];
    }
    
    self.mapPoints = arr;
}

- (void)setMapPoints:(NSArray *)mapPoints {
    _mapPoints = mapPoints;
    if (!_mapPoints) { return; }
    
    self.mapPointsButton.enabled = YES;
    
    [self mapPointsButtonPresssed:self.mapPointsButton];
}

#pragma mark - NSTextFieldDelegate
- (void)keyUp:(NSEvent *)theEvent {
    if (theEvent.keyCode == 36) {
        [self enterAsTextPressed:self.textFieldButton];
    }
}

@end
