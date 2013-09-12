//
//  ViewController.h
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/14/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomViewController.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *RoomName;
@property (strong, nonatomic) IBOutlet UILabel *appTitle;
- (IBAction)SubmitButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *buttonName;

@end
