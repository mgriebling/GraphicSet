//
//  StatusView.m
//  GraphicSet
//
//  Created by Mike Griebling on 16.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "StatusView.h"
#import "PlayingCardView.h"

@interface StatusView ()

@property (strong, nonatomic) IBOutletCollection(PlayingCardView) NSArray *cardViews;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation StatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
