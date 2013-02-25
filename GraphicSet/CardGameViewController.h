//
//  CardGameViewController.h
//  Matchismo
//
//  Created by Michael Griebling on 30Jan2013.
//  Copyright (c) 2013 Michael Griebling. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Deck.h"
#import "CardMatchingGame.h"

@interface CardGameViewController : UIViewController

- (Deck *)cardDeck;
- (NSUInteger)startingCardCount;
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card;
- (void)defineGame:(CardMatchingGame *)game;
- (void)updateUIForGame:(CardMatchingGame *)game;
- (BOOL)shouldDeleteCardsFromGame:(CardMatchingGame *)game;

@end
