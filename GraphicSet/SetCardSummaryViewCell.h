//
//  SetCardSummaryViewCell.h
//  GraphicSet
//
//  Created by Michael Griebling on 25Feb2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SetCardView.h"

@interface SetCardSummaryViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet SetCardView *card1View;
@property (weak, nonatomic) IBOutlet SetCardView *card2View;
@property (weak, nonatomic) IBOutlet SetCardView *card3View;

@end
