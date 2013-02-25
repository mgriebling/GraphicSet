//
//  PlayingCardGameViewController.m
//  GraphicSet
//
//  Created by Mike Griebling on 15.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "PlayingCardGameViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCardViewCell.h"
#import "PlayingCard.h"

@interface PlayingCardGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet PlayingCardView *statusCard1;
@property (weak, nonatomic) IBOutlet PlayingCardView *statusCard2;
@end

@implementation PlayingCardGameViewController

#define CARDS_TO_START   22

- (Deck *)cardDeck {
    PlayingCardDeck *deck = [[PlayingCardDeck alloc] init];
    return deck;
}

- (NSUInteger)startingCardCount {
    return CARDS_TO_START;
}

- (void)defineGame:(CardMatchingGame *)game {
    game.mismatchPenalty = 2;
    game.matchBonus = 6;
    game.flipCost = 1;
    game.numberOfMatches = 2;
    game.name = @"Match";
}

- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card {
    if ([cell isKindOfClass:[PlayingCardViewCell class]]) {
        PlayingCardView *playingCardView = ((PlayingCardViewCell *)cell).cardView;
        if ([card isKindOfClass:[PlayingCard class]]) {
            PlayingCard *playingCard = (PlayingCard *)card;
            [self assignCard:playingCard toCardView:playingCardView];
            playingCardView.alpha = playingCard.isUnplayable ? 0.3 : 1.0;
        }
    }
}

- (void)assignCard:(PlayingCard *)playingCard toCardView:(PlayingCardView *)cardView {
    cardView.rank = playingCard.rank;
    cardView.suit = playingCard.suit;
    cardView.faceUp = playingCard.faceUp;
}

- (void)updateUIForGame:(CardMatchingGame *)game {
    switch (game.gameStatus) {
        case STATUS_FLIPPED: self.statusLabel.text = @"Flipped up card"; break;
        case STATUS_MISMATCH: self.statusLabel.text = [NSString stringWithFormat:@"Mismatched cards!  %d point penalty!", game.mismatchPenalty]; break;
        case STATUS_MATCH2: self.statusLabel.text = [NSString stringWithFormat:@"Matched ranks for %d points!", 4 * game.matchBonus]; break;
        case STATUS_MATCH1: self.statusLabel.text = [NSString stringWithFormat:@"Matched suits for %d points!", game.matchBonus]; break;
        case STATUS_NONE: self.statusLabel.text = @"Welcome to Match! Two matching suits or ranks score."; break;
        default: self.statusLabel.text = @"Illegal Status!!"; break;
    }

    NSArray *cardViews = @[self.statusCard1, self.statusCard2];
    for (PlayingCardView *cardView in cardViews) cardView.faceUp = NO;
    NSArray *statusCards = game.statusCards;
    for (PlayingCard *card in statusCards) {
        PlayingCardView *cardView = cardViews[[game.statusCards indexOfObject:card]];
        [self assignCard:card toCardView:cardView];
        cardView.faceUp = YES;
    }
    for (PlayingCardView *cardView in cardViews) [cardView setNeedsDisplay];
}

@end
