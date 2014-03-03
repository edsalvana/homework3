//
//  MainViewController.m
//  homework3
//
//  Created by Ed Salvana on 3/2/14.
//  Copyright (c) 2014 Ed Salvana. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (strong, atomic) UIImageView *settingsScreen;
@property (strong, atomic) UIImageView *feedScreen;
@property (strong, atomic) UIImageView *scrollContainer;
@property (strong, atomic) UIScrollView *scrollView;
@property (atomic, assign) CGFloat yOffset;
@property (atomic, assign) BOOL isModeSetting;
@property (atomic, assign) CGFloat const scrollContainerMin;
@property (atomic, assign) CGFloat const scrollContainerMax;

@end

@implementation MainViewController

//ask tim if theres any downside to doing thins varuable setting like this
int hidden;
CGRect  screenRect;
CGFloat screenWidth;
CGFloat screenHeight;

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
    
    hidden = 0;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.scrollContainerMin = 0;
    self.scrollContainerMax = 47;
    self.isModeSetting = NO;
    
    //Get screen bounds
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
	//set up image views
    UIImage *settingsImage = [UIImage imageNamed:@"settings.png"];
    UIImage *coverImage = [UIImage imageNamed:@"cover.png"];
    UIImage *feedImage = [UIImage imageNamed:@"feed.png"];
    
    //set up containers for image assets
    self.settingsScreen  = [[UIImageView alloc] initWithImage:settingsImage];
    self.feedScreen      = [[UIImageView alloc] initWithImage:coverImage   ];
    self.scrollContainer = [[UIImageView alloc] initWithImage:feedImage    ];
    self.scrollContainer.layer.shadowColor     = [UIColor blackColor].CGColor;
    self.scrollContainer.layer.shadowOffset    = CGSizeMake(8, 8);
    self.scrollContainer.layer.shadowOpacity   = 1;
    self.scrollContainer.layer.shadowRadius    = 12;
    
    //setup scrollable view that will contain feed image
    CGRect frameTarget = CGRectMake( 0, screenHeight - self.scrollContainer.frame.size.height, screenWidth, self.scrollContainer.frame.size.height);
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = frameTarget;
    self.scrollView.contentSize = CGSizeMake( self.scrollContainer.frame.size.width, self.scrollContainer.frame.size.height);
    self.scrollView.clipsToBounds = NO;
    
    //add views
    [self.view addSubview:self.settingsScreen ];
    [self.view addSubview:self.feedScreen ];
    [self.scrollView addSubview:self.scrollContainer];
    [self.feedScreen addSubview:self.scrollView];
    
    //add pan recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
    self.feedScreen.userInteractionEnabled = YES;
    [self.feedScreen addGestureRecognizer:panGestureRecognizer];
    
    //add gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.feedScreen addGestureRecognizer:tapGestureRecognizer];
    
}


- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint point           = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity        = [panGestureRecognizer velocityInView:self.view];
    CGRect frameTarget      = self.feedScreen.frame;
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //get the offset from the top of the frame and where the touch began
        self.yOffset = point.y - frameTarget.origin.y;
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        //target y position
        frameTarget.origin.y = point.y - self.yOffset;
        
        //check if within bounds of scrollable area
        if( frameTarget.origin.y < self.scrollContainerMin ){
            
            //introduce some fricton when pulling beyond the min y
            CGFloat positionWithFriction = (point.y - self.yOffset ) * .1;
            
            frameTarget.origin.y = positionWithFriction;
            
        } else if( frameTarget.origin.y > screenHeight - self.scrollContainerMax ){
        
            frameTarget.origin.y = (screenHeight - self.scrollContainerMax );
        }
        
        //set the y position
        self.feedScreen.frame = frameTarget;
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if(velocity.y <= 0){
            
            NSLog(@"Direction Up");
            [self animateUp];
        
        } else {
            
            NSLog(@"Direction Down");
            [self animateDown];
            
        }
    }
    
}


- (void)onCustomTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if( self.isModeSetting == YES ){
        [self animateUp];
    }
}

- (void)animateUp {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        CGRect endFrame = self.feedScreen.frame;
        endFrame.origin.y = self.scrollContainerMin;
        self.feedScreen.frame = endFrame;
    } completion:^(BOOL finished){
         self.isModeSetting = NO;
     }
    ];
}

-(void)animateDown {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        
        CGRect endFrame = self.feedScreen.frame;
        endFrame.origin.y = screenHeight - self.scrollContainerMax;
        self.feedScreen.frame = endFrame;
        
    } completion:^(BOOL finished){
        self.isModeSetting = YES;
    }
     ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
