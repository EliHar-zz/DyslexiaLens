//
//  ALBottleCapScanViewController.m
//  AnylineExamples
//
//  Created by Daniel Albertini on 04/02/16.
//  Copyright © 2016 9yards GmbH. All rights reserved.
//

#import "ALBottlecapScanViewController.h"
#import <Anyline/Anyline.h>
#import "ALResultOverlayView.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

// This is the license key for the examples project used to set up Aynline below
NSString * const kBottlecapLicenseKey = @"eyJzY29wZSI6WyJBTEwiXSwicGxhdGZvcm0iOlsiaU9TIiwiQW5kcm9pZCIsIldpbmRvd3MiXSwidmFsaWQiOiIyMDE3LTA5LTE3IiwibWFqb3JWZXJzaW9uIjoiMyIsImlzQ29tbWVyY2lhbCI6ZmFsc2UsInRvbGVyYW5jZURheXMiOjYwLCJpb3NJZGVudGlmaWVyIjpbImlvLmR5c2xleGlhbGVucyJdLCJhbmRyb2lkSWRlbnRpZmllciI6WyJpby5keXNsZXhpYWxlbnMiXSwid2luZG93c0lkZW50aWZpZXIiOlsiaW8uZHlzbGV4aWFsZW5zIl19CnhjVm05cTFhWkpiTnBqOTZ0SWtjRjVKaEdYVnI0MitWYnB1Z2RGQzQ4d1ZMNnRodnArVDZIR2JwVzlmd3hWRzB6RUtzd2pyVWI0bENnM0RtbW1ITGEwV1dKa1ppbXZqdzVDMkR5dEJicHROMGljSFZwQy9CVjVyVzQ5WlQxOSt0UWh2NEhXckk4eGM2SDlwYmNEQmhvNFoyOU5RTng1TEJyYWx5NlUzZVlTb0VYU2NvamtkSXpZZ0wrRk5PUndQS1pIQUVtb2FiUDJEMy9LMHBHZVI1Z3FYRlpDOXRPbVpGMmZXUzlHL09iWTUyY01OZkI3bERFNUduSy9qQU5DTURCaEVHKzJoNlRzd1E5OVIzS3V0ZlA4dGFDRGZVMFJoUkNveW9PRVgxUTkxem13Wm8zcHFRdTFiK3AzZGlzaTdLaW5lV1VNZmFnZmRzMkgrZlNkaXNXdz09";
// The controller has to conform to <AnylineOCRModuleDelegate> to be able to receive results
@interface ALBottlecapScanViewController ()<AnylineOCRModuleDelegate>
// The Anyline module used for OCR
@property (nonatomic, strong) AnylineOCRModuleView *ocrModuleView;
@property (nonatomic, strong) UILabel* label;
@property BOOL firstResult;
@end

@implementation ALBottlecapScanViewController
/*
 We will do our main setup in viewDidLoad. Its called once the view controller is getting ready to be displayed.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the background color to black to have a nicer transition
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = @"DyslexiLens";
    // Initializing the module. Its a UIView subclass. We set the frame to fill the whole screen
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame = CGRectMake(frame.origin.x, frame.origin.y + self.navigationController.navigationBar.frame.size.height, frame.size.width, frame.size.height - self.navigationController.navigationBar.frame.size.height);
    self.ocrModuleView = [[AnylineOCRModuleView alloc] initWithFrame:frame];

    ALOCRConfig *config = [[ALOCRConfig alloc] init];
    config.scanMode = ALLine;
    // 10, 150
    config.charHeight = ALRangeMake(5, 150);
    config.tesseractLanguages = @[@"eng_no_dict"];
    config.minConfidence = 60;
    config.minSharpness = 50;
    
    self.firstResult = true;
    
    
   //
    
    // add view to layout
    
    /*
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 300.0f, self.view.bounds.size.width, self.view.bounds.size.height/5.0f)];
    [self.label setTextColor: UIColorFromRGB(0x000000)];
    [self.label setBackgroundColor: UIColorFromRGB(0xffff00)];
    [self.view addSubview: self.label];
     */

    NSError *error = nil;
    // We tell the module to bootstrap itself with the license key and delegate. The delegate will later get called
    // by the module once we start receiving results.
    BOOL success = [self.ocrModuleView setupWithLicenseKey:kBottlecapLicenseKey
                                                  delegate:self
                                                 ocrConfig:config
                                                     error:&error];
    // setupWithLicenseKey:delegate:error returns true if everything went fine. In the case something wrong
    // we have to check the error object for the error message.
    if (!success) {
        // Something went wrong. The error object contains the error description
        NSAssert(success, @"Setup Error: %@", error.debugDescription);
    }
    
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"bottlecap_config" ofType:@"json"];
    ALUIConfiguration *ibanConf = [ALUIConfiguration cutoutConfigurationFromJsonFile:confPath];
    self.ocrModuleView.currentConfiguration = ibanConf;

    // After setup is complete we add the module to the view of this view controller
    [self.view addSubview:self.ocrModuleView];
}

/*
 This method will be called once the view controller and its subviews have appeared on screen
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // We use this subroutine to start Anyline. The reason it has its own subroutine is
    // so that we can later use it to restart the scanning process.
    [self startAnyline];
}

/*
 Cancel scanning to allow the module to clean up
 */
- (void)viewWillDisappear:(BOOL)animated {
    [self.ocrModuleView cancelScanningAndReturnError:nil];
}

/*
 This method is used to tell Anyline to start scanning. It gets called in
 viewDidAppear to start scanning the moment the view appears. Once a result
 is found scanning will stop automatically (you can change this behaviour
 with cancelOnResult:). When the user dismisses self.identificationView this
 method will get called again.
 */
- (void)startAnyline {
    NSError *error;
    BOOL success = [self.ocrModuleView startScanningAndReturnError:&error];
    if( !success ) {
        // Something went wrong. The error object contains the error description
        NSAssert(success, @"Start Scanning Error: %@", error.debugDescription);
    }
}

#pragma mark -- AnylineOCRModuleDelegate

/*
 This is the main delegate method Anyline uses to report its results
 */
- (void)anylineOCRModuleView:(AnylineOCRModuleView *)anylineOCRModuleView
               didFindResult:(ALOCRResult *)result {
    self.label.alpha = 1;
    if(self.firstResult){
        self.firstResult = false;
        
        // get the cutout rect from the scan view
        CGRect cutOutRect = [self.ocrModuleView cutoutRect];
        
        NSLog(@"%f,  %f,   %f,    %f",cutOutRect.origin.x,cutOutRect.origin.y,cutOutRect.size.width,cutOutRect.size.height);
        
        // create a view
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(cutOutRect.origin.x,
                                                               cutOutRect.origin.y + 64,
                                                               cutOutRect.size.width,
                                                               cutOutRect.size.height)];
        
        self.label.font = [UIFont fontWithName:@"OpenDyslexicAlta" size:18];

        
        [self.view addSubview:self.label];
    }
    
    [self.label setTextColor: UIColorFromRGB(0x000000)];
    [self.label setBackgroundColor: UIColorFromRGB(0xffff00)];
    
    // Display an overlay showing the result
    [self.label setTag:1];
    NSMutableAttributedString *s =
    [[NSMutableAttributedString alloc] initWithString:result.text];

    [s addAttribute:NSBackgroundColorAttributeName
              value:UIColorFromRGB(0xffff00)
              range:NSMakeRange(0, s.length)];
    
    self.label.attributedText = s;

    [self.label setBackgroundColor:[UIColor clearColor]];
    [self.label setTextAlignment: NSTextAlignmentCenter];
    NSLog(@"%@", result.text);
}

- (void)anylineOCRModuleView:(AnylineOCRModuleView *)anylineOCRModuleView
             reportsVariable:(NSString *)variableName
                       value:(id)value {
    
}

- (void)anylineOCRModuleView:(AnylineOCRModuleView *)anylineOCRModuleView
           reportsRunFailure:(ALOCRError)error {
    switch (error) {
        case ALOCRErrorResultNotValid:
            break;
        case ALOCRErrorConfidenceNotReached:
            self.label.alpha = 0;
            break;
        case ALOCRErrorNoLinesFound:
            self.label.alpha = 0;
            break;
        case ALOCRErrorNoTextFound:
            self.label.alpha = 0;
            break;
        case ALOCRErrorUnkown:
            break;
        default:
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSError *error = nil;
    BOOL success = [self.ocrModuleView startScanningAndReturnError:&error];
    
    NSAssert(success, @"We failed starting: %@",error.debugDescription);
}

@end
