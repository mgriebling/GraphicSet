//
//  SetCardGameViewController.m
//  GraphicSet
//
//  Created by Mike Griebling on 17.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "SetCardGameViewController.h"
#import "SetCardView.h"
#import "SetCardDeck.h"
#import "SetCardViewCell.h"
#import "SetCardSummaryViewCell.h"

@interface SetCardGameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet SetCardView *statusCard1;
@property (weak, nonatomic) IBOutlet SetCardView *statusCard2;
@property (weak, nonatomic) IBOutlet SetCardView *statusCard3;

@end

@implementation SetCardGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define CARDS_TO_START   12

- (Deck *)cardDeck {
    SetCardDeck *deck = [[SetCardDeck alloc] init];
    return deck;
}

- (NSUInteger)startingCardCount {
    return CARDS_TO_START;
}

- (BOOL)supportsSummary {
    return TRUE;
}

- (void)defineGame:(CardMatchingGame *)game {
    game.mismatchPenalty = 2;
    game.matchBonus = 2;
    game.flipCost = 1;
    game.numberOfMatches = 3;
    game.name = @"Set";
}

- (BOOL)shouldDeleteCardsFromGame:(CardMatchingGame *)game {
    return game.gameStatus == STATUS_MATCH2;
}

- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card {
    if ([cell isKindOfClass:[SetCardViewCell class]]) {
        SetCardView *setCardView = ((SetCardViewCell *)cell).cardView;
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard = (SetCard *)card;
            [self assignCard:setCard toCardView:setCardView];
            setCardView.faceUp = setCard.isFaceUp;
        }
    }
}

- (void)updateCell:(UICollectionViewCell *)cell usingCards:(NSArray *)cards {
    if ([cell isKindOfClass:[SetCardSummaryViewCell class]]) {
        SetCardSummaryViewCell *setCardSummyView = (SetCardSummaryViewCell *)cell;
        NSArray *viewCells = @[setCardSummyView.card1View, setCardSummyView.card2View, setCardSummyView.card3View];
        [cards enumerateObjectsUsingBlock:^(Card *card, NSUInteger idx, BOOL *stop) {
            if ([card isKindOfClass:[SetCard class]]) {
                SetCard *setCard = (SetCard *)card;
                SetCardView *setCardView = (SetCardView *)viewCells[idx];
                [self assignCard:setCard toCardView:setCardView];
                setCardView.faceUp = NO;    // don't want the highlight
            }
        }];
    }
}

- (void)assignCard:(SetCard *)setCard toCardView:(SetCardView *)setCardView {
    setCardView.shape = setCard.shape;
    setCardView.colour = setCard.colour;
    setCardView.number = setCard.number;
    setCardView.fill = setCard.fill;
}

- (void)updateUIForGame:(CardMatchingGame *)game {
    switch (game.gameStatus) {
        case STATUS_FLIPPED: self.statusLabel.text = @"Flipped up card"; break;
        case STATUS_MISMATCH: self.statusLabel.text = [NSString stringWithFormat:@"Mismatched cards!  %d point penalty!", game.mismatchPenalty]; break;
        case STATUS_MATCH2: 
        case STATUS_MATCH1: self.statusLabel.text = [NSString stringWithFormat:@"Matched card set for %d points!", 6 * game.matchBonus]; break;
        case STATUS_NONE: self.statusLabel.text = @"Welcome to Set! Three cards in a set score."; break;
        default: self.statusLabel.text = @"Illegal Status!!"; break;
    }
    
    NSArray *cardViews = @[self.statusCard1, self.statusCard2, self.statusCard3];
    for (SetCardView *cardView in cardViews) {
        cardView.faceUp = NO;
        cardView.shape = 0;     // illegal shape to blank the card
    }
    for (SetCard *card in game.statusCards) {
        [self assignCard:card toCardView:cardViews[[game.statusCards indexOfObject:card]]];
    }
    for (SetCardView *cardView in cardViews) [cardView setNeedsDisplay];
}


@end
