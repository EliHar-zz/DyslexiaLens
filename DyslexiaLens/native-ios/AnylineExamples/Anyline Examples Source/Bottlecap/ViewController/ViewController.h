//
//  ViewController.h
//  AnylineExamples
//
//  Created by Elias Haroun on 2016-09-18.
//  Copyright © 2016 9yards GmbH. All rights reserved.
//

#import "PageContentViewController.h"

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;

@end
