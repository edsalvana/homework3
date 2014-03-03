//
//  MainViewController.h
//  homework3
//
//  Created by Ed Salvana on 3/2/14.
//  Copyright (c) 2014 Ed Salvana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)onCustomTap:(UITapGestureRecognizer *)tapGestureRecognizer;

@end
