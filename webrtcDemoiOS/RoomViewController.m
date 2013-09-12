//
//  RoomViewController.m
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/14/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import "RoomViewController.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f

@interface RoomViewController (){
    NSString* userName;
    NSDictionary* roomInfo;
    NSMutableDictionary* roomUsers;
    NSMutableDictionary* allStreams;
    NSMutableArray* connections;
    OTSession* _session;
    OTPublisher* publisher;
    
    OTSubscriber* _subscriber;
    Firebase* presenceRef;
    Firebase* chatRef;
    Firebase* usersRef;
}

@end

@implementation RoomViewController

@synthesize rid, chatInput, chatTable, chatData, myPickerView, userSelectButton, usersPickerView, selectUserButton, videoContainerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad fired man!");
    // setup
    [self.navigationController setNavigationBarHidden:YES];
    [self registerForKeyboardNotifications];
    
    // initialize constants
    roomUsers = [[NSMutableDictionary alloc] init];
    allStreams = [[NSMutableDictionary alloc] init];
    connections= [[NSMutableArray alloc] init];
    chatData = [[NSMutableArray alloc] init];
    
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    [usersPickerView addSubview:myPickerView];
    [usersPickerView addSubview:selectUserButton];
    [usersPickerView setAlpha:0.0];
    
    // generate current user's name
    NSDate* date = [NSDate date];
    userName = [[NSString alloc] initWithFormat:@"iOS%d", (int)[date timeIntervalSince1970] % 1000000];
    [userSelectButton.titleLabel setText: userName];
    
    // Tap to resign first responder
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tgr.delegate = self;
    [self.view addGestureRecognizer:tgr];
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TBBlue.png"]];
    
}

- (void) setupVideo {

    CGFloat containerWidth = CGRectGetWidth( videoContainerView.bounds );
    CGFloat containerHeight = CGRectGetHeight( videoContainerView.bounds );
    
    publisher = [[OTPublisher alloc] initWithDelegate:self];
    [publisher.view setFrame:CGRectMake( containerWidth-90, containerHeight-60, 100, 75)];
    [videoContainerView addSubview:publisher.view];
    
    NSLog(@"setup video");
    NSLog(@"setup video");
    NSLog(@"setup video");
    NSLog(@"setup video");
    NSLog(@"-------------");
  
    // Connect to OpenTok session
    _session = [[OTSession alloc] initWithSessionId: [roomInfo objectForKey:@"sid"] delegate:self];
    [_session connectWithApiKey: [roomInfo objectForKey:@"apiKey"] token:[roomInfo objectForKey:@"token"]];
    
    // Define firebase refs
    NSString* roomUrl = [[NSString alloc] initWithFormat:@"https://rtcdemo.firebaseIO.com/room/%@/", rid];
    Firebase* roomRef = [[Firebase alloc] initWithUrl: roomUrl];
    NSString* chatUrl = [[NSString alloc] initWithFormat:@"https://rtcdemo.firebaseIO.com/room/%@/chat/", rid];
    chatRef = [[Firebase alloc] initWithUrl: chatUrl];
    NSString* usersUrl = [[NSString alloc] initWithFormat:@"https://rtcdemo.firebaseIO.com/room/%@/users/", rid];
    usersRef = [[Firebase alloc] initWithUrl: usersUrl];
    
    // make sure roomRef has session id
    [[roomRef childByAppendingPath:@"sid"] setValue: [roomInfo objectForKey:@"sid"]];
    
    // new chat messages
    [chatRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the chat message to the array.
        [chatData addObject:snapshot.value];
        
        // Reload the table view so the new message will show up.
        [chatTable reloadData];
        if (chatTable.contentSize.height > chatTable.frame.size.height){
            CGPoint offset = CGPointMake(0, chatTable.contentSize.height - chatTable.frame.size.height);
            [chatTable setContentOffset:offset animated:YES];
        }
    }];
    
    
    [usersRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot){
        NSString* name = [[snapshot childSnapshotForPath:@"name"] value];
        NSString* cid = [snapshot name];
        if(cid){
            [roomUsers setValue:name forKey:cid];
            NSLog(@"child added: %@", roomUsers);
        }
    }];
    [usersRef observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot){
        NSString* name = [snapshot name];
        [roomUsers removeObjectForKey: name];
        NSLog(@"child added: %@", roomUsers);
    }];
    [usersRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot){
        NSString* name = [[snapshot childSnapshotForPath:@"name"] value];
        NSString* cid = [snapshot name];
        if(cid){
            [roomUsers setValue:name forKey:cid];
            [myPickerView reloadAllComponents];
            NSLog(@"child changed: %@", roomUsers);
        }
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    // Send request to get room info (session id and token)
    NSString* roomInfoUrl = [[NSString alloc] initWithFormat:@"https://opentokrtc.com/%@.json", rid];
    NSURL *url = [NSURL URLWithString: roomInfoUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error){
            //NSLog(@"Error,%@", [error localizedDescription]);
        }
        else{
            roomInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            [self setupVideo];
        }
    }];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UITextField class]]) {
        NSLog(@"User tapped on UITextField");
    }else{
        [self.chatInput resignFirstResponder];
    }
    return YES; // do whatever u want here
}
- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"view tapped");
    // remove keyboard
}


#pragma mark - OpenTok Session
- (void)sessionDidConnect:(OTSession*)session
{
    // set user's presence in the room
    NSString* presenceUrl = [[NSString alloc] initWithFormat:@"https://rtcdemo.firebaseIO.com/room/%@/users/%@", rid, session.connection.connectionId];
    presenceRef = [[Firebase alloc] initWithUrl: presenceUrl];
    [[presenceRef childByAppendingPath:@"name"] setValue: userName];
    [presenceRef onDisconnectRemoveValue];
    
    [_session publish:publisher];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    // go back to join room, remove user's presence from room
    
    [usersRef removeAllObservers];
    [chatRef removeAllObservers];
    [presenceRef removeValue];
    _subscriber = NULL;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    if (![stream.connection.connectionId isEqualToString: _session.connection.connectionId] && !_subscriber){
        _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        
        NSString* streamName = [roomUsers objectForKey: stream.connection.connectionId];
        if (!streamName) {
            streamName = stream.connection.connectionId;
        }
        [userSelectButton setTitle: streamName forState:UIControlStateNormal];
        
        CGFloat containerWidth = CGRectGetWidth( videoContainerView.bounds );
        CGFloat containerHeight = CGRectGetHeight( videoContainerView.bounds );
        [_subscriber.view setFrame:CGRectMake( 0, 0, containerWidth, containerHeight)];
        [videoContainerView insertSubview:_subscriber.view belowSubview:publisher.view];
    }
    [allStreams setObject:stream forKey:stream.connection.connectionId];
    
    [connections addObject:stream.connection.connectionId];
    NSLog(@"streams created, connections: %@", connections);
    [myPickerView reloadAllComponents];
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    
    [allStreams removeObjectForKey:stream.connection.connectionId];
    [connections removeObject:stream.connection.connectionId];
    NSLog(@"streams destroyed, connections: %@", connections);
    [myPickerView reloadAllComponents];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"sessionDidFail");
    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@", session.sessionId]];
}

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {
    NSLog(@"publisher didFailWithError %@", error);
    [self showAlert:[NSString stringWithFormat:@"There was an error publishing."]];
}

#pragma mark - Helper Methods
- (void)showAlert:(NSString*)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from video session"
                                                    message:string
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Chat textfield

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // called after the text field resigns its first responder status
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (chatInput.text.length>0) {
        // Generate a reference to a new location with childByAutoId, add chat
        Firebase* newPushRef = [chatRef childByAutoId];
        [newPushRef setValue:@{@"name":userName ,@"text": textField.text}];
        chatInput.text = @"";
    }
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

#pragma mark - ChatList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatData count];
}
- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index
{
    
    
    
    //WTF WTF I HATE IOS FML
    // I GIVE UP
    
    
    
    static NSString *CellIdentifier = @"chatCellIdentifier";
    ChatCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary* chatMessage = [chatData objectAtIndex:index.row];
    
    // TODO: 260 comes from the width inside the storyboard
    CGSize maximumLabelSize = CGSizeMake(260, FLT_MAX);
    CGSize textSize = [chatMessage[@"text"] sizeWithFont:cell.textString.font constrainedToSize:maximumLabelSize lineBreakMode:cell.textString.lineBreakMode];
    
//    cell.userLabel.text = chatMessage[@"name"];
    
    
    
    // iOS6 and above : Use NSAttributedStrings
    const CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    // Create the attributes
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           boldFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              regularFont, NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(0,[chatMessage[@"name"] length]+1); // range of " 2012/10/14 ". Ideally this should not be hardcoded
    

    NSMutableString* cellText = [[NSMutableString alloc] initWithFormat:@"%@: %@", chatMessage[@"name"],chatMessage[@"text"]];
    
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:cellText
                                           attributes:subAttrs];
    [attributedText setAttributes:attrs range:range];
    
    
    
    
    cell.textString.attributedText = attributedText;
    
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    
    // adjust the label the the new height.
    CGRect newFrame = cell.textString.frame;
    newFrame.size.height = textSize.height;
    //NSLog(@"new height is: %f", newFrame.size.height);
    cell.textString.frame = newFrame;
    
    cell.textString.numberOfLines = 0;
    
    cell.backgroundColor = [UIColor colorWithRed:0x83/255.0f
                                           green:0xBC/255.0f
                                            blue:0xD0/255.0f alpha:1];
    
    
    [cell.textString setBackgroundColor: [UIColor colorWithRed:0x83/255.0f
                                                         green:0xBC/255.0f
                                                          blue:0xD0/255.0f alpha:1]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary* chatMessage = [chatData objectAtIndex:indexPath.row];
    
    NSString* myString = chatMessage[@"text"];
    
    
    
    // Without creating a cell, just calculate what its height would be
    static int pointsAboveText = 12;
    static int pointsBelowText = 12;
    
    // TODO: there is some code duplication here. In particular, instead of asking the cell, the cell's settings from
    //       the storyboard are manually duplicated here (font, wrapping).
    CGSize maximumLabelSize = CGSizeMake(260, FLT_MAX);
    CGFloat expectedLabelHeight = [myString sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping].height;
    
    return pointsAboveText + expectedLabelHeight + pointsBelowText;
}
- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    return nil;
}

#pragma mark - Other Interactions
- (IBAction)ExitButton:(id)sender {
    NSLog(@"exit button");
    [_session disconnect];
}

#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [connections count];
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [roomUsers objectForKey: [connections objectAtIndex:row] ];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    //NSLog(@"Chosen item: %@", [connections objectAtIndex:row]);

}

#pragma mark - User Buttons
- (IBAction)startSelection:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [usersPickerView setAlpha:1.0];
    [UIView commitAnimations];
}

- (IBAction)userSelected:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [usersPickerView setAlpha:0.0];
    [UIView commitAnimations];
    
    int row = [myPickerView selectedRowInComponent:0];
    NSLog(@"user picked row %d", row);
    
    NSString* streamName = [roomUsers objectForKey: [connections objectAtIndex:row]];
    [userSelectButton setTitle: streamName forState:UIControlStateNormal];
    
    OTStream* stream = [allStreams objectForKey: [connections objectAtIndex:row]];
    [_subscriber close];
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    CGFloat containerWidth = CGRectGetWidth( videoContainerView.bounds );
    CGFloat containerHeight = CGRectGetHeight( videoContainerView.bounds );
    [_subscriber.view setFrame:CGRectMake( 0, 0, containerWidth, containerHeight)];
    [videoContainerView insertSubview:_subscriber.view belowSubview:publisher.view];
    
}
- (IBAction)backgroundTap:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [usersPickerView setAlpha:0.0];
    [UIView commitAnimations];
}
@end
