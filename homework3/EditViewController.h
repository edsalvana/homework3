//
//  EditViewController.h
//  homework4
//
//  Created by Ed Salvana on 3/9/14.
//  Copyright (c) 2014 Ed Salvana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController

- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)onCustomTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)onLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

@end
