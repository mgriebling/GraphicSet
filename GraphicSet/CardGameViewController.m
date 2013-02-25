
//
//  CardGameViewController.m
//  Matchismo
//
//  Created by Michael Griebling on 30Jan2013.
//  Copyright (c) 2013 Michael Griebling. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CardGameViewController.h"
#import "GameResult.h"
#import "GameResultController.h"

@interface CardGameViewController () <UICollectionViewDataSource>
@property (strong, nonatomic) CardMatchingGame *game;
@property (strong, nonatomic) GameResult *gameResult;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dealButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UICollectionView *cardCollectionView;
@end

@implementation CardGameViewController

#pragma mark - Getters

- (GameResult *)gameResult {
    if (!_gameResult) _gameResult = [[GameResult alloc] init];
    return _gameResult;
}

- (CardMatchingGame *)game {
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self startingCardCount] usingDeck:self.cardDeck];
        [self defineGame:_game];
    }
    return _game;
}

#pragma mark - Abstract methods

- (Deck *)cardDeck {
    return nil;     // abstract method
}

- (NSUInteger)startingCardCount {
    return 0;       // abstract method
}

- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card {
    // abstract to fill in the cell contents
}

- (void)defineGame:(CardMatchingGame *)game {
    // abstract to set up game parameters
}

- (void)updateUIForGame:(CardMatchingGame *)game {
    // abstract to display game status with cards
}

- (BOOL)shouldDeleteCardsFromGame:(CardMatchingGame *)game {
    // abstract to delete active cards from game
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.game.activeCards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.cardCollectionView dequeueReusableCellWithReuseIdentifier:@"Card" forIndexPath:indexPath];
    Card *card = [self.game cardAtIndex:indexPath.item];
    [self updateCell:cell usingCard:card];
    return cell;
}

#pragma mark - GUI Controls

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.addButton) self.navigationItem.leftBarButtonItems = @[self.dealButton, self.addButton];
    [self localUpdateUI];
}

- (void)localUpdateUI {
    NSIndexPath *last;
    for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) {
        NSIndexPath *path = [self.cardCollectionView indexPathForCell:cell];
        last = path;
        Card *card = [self.game cardAtIndex:path.item];
        if (card.isUnplayable && [self shouldDeleteCardsFromGame:self.game]) {
            [self.game deleteCards:@[card]];
            [self.cardCollectionView deleteItemsAtIndexPaths:@[path]];
        } else {
            [self updateCell:cell usingCard:card];
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"Match Score: %d", self.game.score];
    [self updateUIForGame:self.game];
}

- (IBAction)flipCard:(UITapGestureRecognizer *)gesture {
    CGPoint tapLocation = [gesture locationInView:self.cardCollectionView];
    NSIndexPath *path = [self.cardCollectionView indexPathForItemAtPoint:tapLocation];
    if (path) {
        [self.game flipCardAtIndex:path.item];
        [self.gameResult setScore:self.game.score withGame:self.game.name];
        [self localUpdateUI];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        self.game = nil;            // start a new game
        self.gameResult = nil;
        [self.cardCollectionView scrollToItemAtIndexPath:nil atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        [self localUpdateUI];
    }
}

- (IBAction)deal {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Game" message:@"The current game won't be saved if you deal new cards!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"New Game", nil];
    [alert show];
}

- (IBAction)addCards:(id)sender {
    if (![self.game drawCountCards:3]) {
        self.addButton.enabled = NO;  // disable button if no more cards exist
    } else {
        NSArray *indexPaths = [self.cardCollectionView indexPathsForVisibleItems];
        [self.cardCollectionView insertItemsAtIndexPaths:@[indexPaths[0], indexPaths[1], indexPaths[2]]];
    }
    [self localUpdateUI];
}

- (IBAction)exitSettings:(UIStoryboardSegue *)segue {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"ShowScores"]) {
        GameResultController *controller = (GameResultController *)segue.destinationViewController;
        controller.gameFilter = self.game.name;
    }
}

@end
