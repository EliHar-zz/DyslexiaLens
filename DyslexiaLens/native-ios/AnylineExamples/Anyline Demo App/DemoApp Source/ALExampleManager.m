//
//  ALExampleManager.m
//  AnylineExamples
//
//  Created by Daniel Albertini on 06.02.15.
//  Copyright (c) 2015 9yards GmbH. All rights reserved.
//

#import "ALExampleManager.h"

#import "ALBottlecapScanViewController.h"

@interface ALExampleManager ()

@property (nonatomic, strong) NSDictionary *examples;

@property (nonatomic, strong) NSArray *sectionNames;

@end

@implementation ALExampleManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initExampleData];
    }
    return self;
}

- (void)initExampleData {
    
   
    ALExample *stieglScanning = [[ALExample alloc] initWithName:NSLocalizedString(@"Bottlecap Code Scanner", nil)
                                                 viewController:[ALBottlecapScanViewController class]];
}

- (NSInteger)numberOfSections {
    return self.sectionNames.count + 1;
}

- (NSString *)titleForSectionIndex:(NSInteger)index {
    if (index == self.numberOfSections - 1) {
        NSString * bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        NSString * SDKVersion   = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        return [NSString stringWithFormat:@"B%@ %@", bundleVersion, SDKVersion];
    }
    return self.sectionNames[index];
}

- (NSInteger)numberOfExamplesInSectionIndex:(NSInteger)index {
    if (index == self.numberOfSections - 1) {
        return 0;
    }
    return [self.examples[self.sectionNames[index]] count];
}

- (ALExample *)exampleForIndexPath:(NSIndexPath *)indexPath {
    return self.examples[self.sectionNames[indexPath.section]][indexPath.row];
}

@end
