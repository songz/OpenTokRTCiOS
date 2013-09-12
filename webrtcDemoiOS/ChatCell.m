//
//  ChatCell.m
//  webrtcDemoiOS
//
//  Created by Song Zheng on 8/20/13.
//  Copyright (c) 2013 Song Zheng. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

@synthesize timeLabel, textString;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {     
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
