//
//  EditViewController.m
//  homework4
//
//  Created by Ed Salvana on 3/9/14.
//  Copyright (c) 2014 Ed Salvana. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()
@property (strong, atomic) UIView *editFrame;
@property (strong, atomic) UIImageView *background;
@property (strong, atomic) UIImageView *cardFacebook;
@property (strong, atomic) UIImageView *cardHeadLines;
@property (strong, atomic) UIImageView *cardDropArea;
@property (atomic, assign) CGRect dropAreaRect;
@property (atomic, assign) CGRect defaultPositionRect;
@property (atomic, assign) CGRect activePositionRect;
@property (atomic, assign) CGPoint pointOffset;
@property (atomic, assign) BOOL isDragging;
@property  (atomic, assign) CGAffineTransform zoom;
@property  (atomic, assign) CGAffineTransform unZoom;

@end

@implementation EditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load image
    UIImage *backgroundImage    = [UIImage imageNamed:@"windowEdit"];
    UIImage *cardFacebookImage  = [UIImage imageNamed:@"cardFacebook"];
    UIImage *cardHeadlinesImage  = [UIImage imageNamed:@"cardHeadlines"];
    UIImage *cardDropAreaImage  = [UIImage imageNamed:@"cardDropBox"];
    
    //setup image views
    self.background     = [[UIImageView alloc] initWithImage:backgroundImage];
    self.cardFacebook   = [[UIImageView alloc] initWithImage:cardFacebookImage];
    self.cardHeadLines  = [[UIImageView alloc] initWithImage:cardHeadlinesImage];
    self.cardDropArea   = [[UIImageView alloc] initWithImage:cardDropAreaImage];
    
    self.editFrame = [[UIView alloc] init ];
    
    //add image views
    [self.view addSubview:self.background];
    [self.view addSubview:self.cardDropArea];
   
    [self.view addSubview:self.cardFacebook];
     [self.view addSubview:self.cardHeadLines ];
    
    //position for drop area
    self.dropAreaRect = self.cardDropArea.frame;
    self.dropAreaRect = CGRectMake( 320/2 -  self.dropAreaRect.size.width/2, 70, self.dropAreaRect.size.width, self.dropAreaRect.size.height );
    
    //initial position for headlines card
    self.defaultPositionRect  = self.dropAreaRect;
    self.defaultPositionRect  =  CGRectMake( 320/2 -  self.dropAreaRect.size.width/2, self.defaultPositionRect.origin.y + 400, self.dropAreaRect.size.width, self.dropAreaRect.size.height );
    
    //active position facebook card
    self.activePositionRect = self.dropAreaRect;
    self.activePositionRect = CGRectMake( 320/2 -  self.dropAreaRect.size.width/2 - self.dropAreaRect.size.width - 10, self.activePositionRect.origin.y, self.dropAreaRect.size.width, self.dropAreaRect.size.height );
    
    //position card drop
    self.cardDropArea.frame = self.dropAreaRect;
    
    //position headlines card
    self.cardHeadLines.frame = self.defaultPositionRect;
  
    //position facebook card
    self.cardFacebook.frame = self.dropAreaRect;
    
    //add gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    self.cardHeadLines.userInteractionEnabled = YES;
    [self.cardHeadLines addGestureRecognizer:tapGestureRecognizer];
    
    //add long press
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGesture:)];
    longPressGestureRecognizer.minimumPressDuration = .15;
    longPressGestureRecognizer.allowableMovement = 50;
    [self.cardHeadLines addGestureRecognizer:longPressGestureRecognizer];
    
    //add pan recognizer
    //UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    //[self.cardHeadLines addGestureRecognizer:panGestureRecognizer];
    
    //dismiss modal button
    UIButton *doneButton = [[UIButton alloc] init];
    doneButton.frame = CGRectMake( 240, 0, 80, 50);
    [doneButton addTarget:self action:@selector(onDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
}

- (void)onDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onCustomTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    NSLog(@"tap");
    [self onDoubleTap];
}

- (void)onLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    UIView *view  = longPressGestureRecognizer.view;
    CGPoint point = [longPressGestureRecognizer locationInView:self.view];
    
    CGRect frameTarget      = self.cardHeadLines.frame;
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
      
        NSLog(@"Start Drag");
        
        self.isDragging = YES;

        [self toggleSlide];
        
        //get the offset from the top of the frame and where the touch began
        self.pointOffset = CGPointMake( point.x - frameTarget.origin.x , point.y - frameTarget.origin.y );
        
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    
        //NSLog(@"Dragging...");
  
        frameTarget.origin.x = point.x - self.pointOffset.x;
        frameTarget.origin.y = point.y - self.pointOffset.y;

        //set the y position
        self.cardHeadLines.frame = frameTarget;
        
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"End Drag");
        
        self.isDragging = NO;
       
        //check if inside bounds
        if( [self hitTest] ){
            
            NSLog(@"Hit");
            
            //then slide to drop area and reset the scale to 1
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                
                    self.cardHeadLines.frame = self.dropAreaRect;
                
                
            } completion:^(BOOL finished){}];
           
        } else {
             NSLog(@"Miss");
            [self toggleSlide];
            //reset
        }
        
    }

    

}

//pass a param at some point
- (BOOL)hitTest {
    
    CGRect card = self.cardHeadLines.frame;
    CGRect drop = self.dropAreaRect;
    
    if( (( card.origin.x > drop.origin.x && card.origin.x  < drop.origin.x + drop.size.width ) |
         ( card.origin.x + card.size.width > drop.origin.x  && card.origin.x + card.size.width < drop.origin.x + drop.size.width ) ) &
        (( card.origin.y > drop.origin.y && card.origin.y  < drop.origin.y + drop.size.height ) |
         ( card.origin.y + card.size.height > drop.origin.y  && card.origin.y + card.size.height < drop.origin.y + drop.size.height ) )
       ){
        return YES;
    } else {
        return NO;
    }
    
    

}

- (void)toggleSlide {
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:3 initialSpringVelocity:2 options:0 animations:^{
        
        //there's something screwy going on here when transforming, sometimes it obeys the hit area, other times it doesn't
        if( self.isDragging == YES ){
            self.cardHeadLines.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            self.cardFacebook.frame = self.activePositionRect;                          //slide facebook card to the left
        } else {
            self.cardHeadLines.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.cardFacebook.frame = self.dropAreaRect;                                //slide facebook card back over drop area
            self.cardHeadLines.frame = self.defaultPositionRect;                        //slide headline card back down to its initial defult position
        }
        
    } completion:^(BOOL finished){
    }
     ];
}


- (void)onDoubleTap{
    NSLog(@"double");
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:3 initialSpringVelocity:2 options:0 animations:^{

            self.cardHeadLines.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.cardFacebook.frame = self.activePositionRect;
            self.cardHeadLines.frame = self.dropAreaRect;
   
        
    } completion:^(BOOL finished){
    }
     ];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
   
}



@end
