//
//  PlayingCardViewCell.h
//  GraphicSet
//
//  Created by Mike Griebling on 15.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingCardView.h"

@interface PlayingCardViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PlayingCardView *cardView;

@end
