//
//  ViewController.m
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/14/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    UIFont* avantGarde;
}

@end

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation ViewController

@synthesize RoomName, appTitle, buttonName, hintLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"font family names: %@", [UIFont fontNamesForFamilyName:@"AvantGarde Bk BT"]);
    
    // Change fonts of all text on the screen
    [RoomName setFont: [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:22.0 ]];
    [appTitle setFont: [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:35.0 ]];
    [hintLabel setFont:[UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:13.0 ]];
    [buttonName.titleLabel setFont: avantGarde];
    
    // listen to return key
    [self registerForKeyboardNotifications];
    
    // listen to taps around the screen, and hide keyboard when necessary
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tgr.delegate = self;
    [self.view addGestureRecognizer:tgr];
    
    // set up the look of the page
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TBRed.png"]];
    [self.navigationController setNavigationBarHidden:YES];
    if (!SYSTEM_VERSION_LESS_THAN(@"7.0")) {
      [self setNeedsStatusBarAppearanceUpdate];
    }
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]]) {
        // user tapped on buttons or input fields
    }else{
        [self.RoomName resignFirstResponder];
    }
    return YES;
}

- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    // user tapped on the view
}

#pragma mark - User Interaction
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSString* inputRoomName = [[RoomName text] stringByReplacingOccurrencesOfString:@" " withString:@""];;
    return (inputRoomName.length >= 1) ? YES : NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // user clicks button, prepares to join room
    if ([[segue identifier] isEqualToString:@"startChat"])
    {
        [RoomName resignFirstResponder];
        
        RoomViewController *vc = [segue destinationViewController];
        vc.rid = [[RoomName text] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

#pragma mark - Chat textfield
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // called after the text field resigns its first responder status
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"enter is clicked");
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Keyboard Notifications
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
}
@end
