//
//  ChatCell.h
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/20/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *textString;
@property (nonatomic,retain) IBOutlet UILabel *timeLabel;

@end
