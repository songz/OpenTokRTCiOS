//
//  RoomViewController.h
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/14/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <Opentok/Opentok.h>
#import "ChatCell.h"
#import <QuartzCore/QuartzCore.h>

@interface RoomViewController : UIViewController <OTSessionDelegate, OTSubscriberDelegate, OTPublisherDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *userSelectButton;
@property (nonatomic, retain) NSString* rid;
@property (strong, nonatomic) IBOutlet UITextField *chatInput;
@property (strong, nonatomic) IBOutlet UIView *usersPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (strong, nonatomic) IBOutlet UIButton *selectUserButton;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) NSMutableArray* chatData;
@property (strong, nonatomic) IBOutlet UIView *videoContainerView;

- (IBAction)ExitButton:(id)sender;
-(IBAction) backgroundTap:(id) sender;
- (IBAction)startSelection:(id)sender;
- (IBAction)userSelected:(id)sender;

@end
