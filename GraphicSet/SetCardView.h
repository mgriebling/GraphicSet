//
//  SetCardView.h
//  GraphicSet
//
//  Created by Mike Griebling on 17.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetCard.h"

@interface SetCardView : UIView

@property (nonatomic) ShapeType shape;
@property (nonatomic) ColourType colour;
@property (nonatomic) FillType fill;
@property (nonatomic) NumberOfShapes number;

@property (nonatomic) BOOL faceUp;

@end
