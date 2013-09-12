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

@implementation ViewController

@synthesize RoomName, appTitle, buttonName, hintLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    NSLog(@"font family names: %@", [UIFont fontNamesForFamilyName:@"AvantGarde Bk BT"]);
    avantGarde = [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:22.0 ];
    [RoomName setFont: avantGarde];
    [appTitle setFont: [UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:35.0 ]];
    [buttonName.titleLabel setFont: avantGarde];
    [hintLabel setFont:[UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:13.0 ]];
    
    
    CALayer* layer = [RoomName layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor blackColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height+10, layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
    [layer addSublayer:bottomBorder];
    
    
    
    
    RoomName.delegate = self;
    
    [self registerForKeyboardNotifications];
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tgr.delegate = self;
    [self.view addGestureRecognizer:tgr];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TBRed.png"]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"gestures");
    if ([touch.view isKindOfClass:[UIControl class]]) {
        NSLog(@"User tapped on UITextField");
    }else{
        [self.RoomName resignFirstResponder];
    }
    return YES; // do whatever u want here
}
- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"view tapped");
    // remove keyboard
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SubmitButton:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"startChat"])
    {
        
        [RoomName resignFirstResponder];
        
        NSString* roomName = [RoomName text];
        
        //TODO: make sure room name is not empty
        RoomViewController *vc = [segue destinationViewController];
        vc.rid = roomName;
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
