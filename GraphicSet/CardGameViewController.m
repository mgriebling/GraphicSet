
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

#import "HeaderCollectionView.h"

@interface CardGameViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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

- (void)updateCell:(UICollectionViewCell *)cell usingCards:(NSArray *)cards {
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

- (BOOL)supportsSummary {
    // overridden by subclasses if a summary view is shown
    return NO;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return CGSizeMake(98, 65);
    return CGSizeMake(280, 81);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.game.activeCards.count;
    } else {
        return [self supportsSummary] ? self.game.historyItems.count : 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (indexPath.section == 0) {
        cell = [self.cardCollectionView dequeueReusableCellWithReuseIdentifier:@"Card" forIndexPath:indexPath];
        Card *card = [self.game cardAtIndex:indexPath.item];
        [self updateCell:cell usingCard:card];
    } else {
        cell = [self.cardCollectionView dequeueReusableCellWithReuseIdentifier:@"Card3" forIndexPath:indexPath];
        NSArray *cards = [self.game historyItems][indexPath.row];
        [self updateCell:cell usingCards:cards];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self supportsSummary] ? 2 : 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [self.cardCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
    if ([header isKindOfClass:[HeaderCollectionView class]]) {
        HeaderCollectionView *headerView = (HeaderCollectionView *)header;
        if (indexPath.section == 0) {
            headerView.headerLabel.text = @"Current Game";
        } else {
            headerView.headerLabel.text = @"Previous Matches";            
        }
    }
    return header;
}

#pragma mark - GUI Controls

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.addButton) self.navigationItem.leftBarButtonItems = @[self.dealButton, self.addButton];
    [self localUpdateUI];
}

- (void)localUpdateUI {
    for (UICollectionViewCell *cell in [self.cardCollectionView visibleCells]) {
        NSIndexPath *path = [self.cardCollectionView indexPathForCell:cell];
        Card *card = [self.game cardAtIndex:path.item];
        [self updateCell:cell usingCard:card];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Score: %d", self.game.name, self.game.score];
    [self updateUIForGame:self.game];
}

- (void)deleteUnplayableCards {
    if (![self shouldDeleteCardsFromGame:self.game]) {
        [self localUpdateUI];
        return;
    }
    [self.cardCollectionView performBatchUpdates:^{
        NSArray *visibleCells = [self.cardCollectionView visibleCells];
        [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UICollectionViewCell class]]) {
                UICollectionViewCell *cell = (UICollectionViewCell*)obj;
                NSIndexPath *path = [self.cardCollectionView indexPathForCell:cell];
                Card *card = [self.game cardAtIndex:path.item];
                if (card.isUnplayable) {
                    [self.game deleteCards:@[card]];
                    [self.cardCollectionView deleteItemsAtIndexPaths:@[path]];
                }
            }
        }];
    } completion:^(BOOL finished) {
        [self localUpdateUI];    
    }];
}

- (IBAction)flipCard:(UITapGestureRecognizer *)gesture {
    CGPoint tapLocation = [gesture locationInView:self.cardCollectionView];
    NSIndexPath *path = [self.cardCollectionView indexPathForItemAtPoint:tapLocation];
    if (path && path.section == 0) {
        [self.game flipCardAtIndex:path.item];
        [self.gameResult setScore:self.game.score withGame:self.game.name];
        [self deleteUnplayableCards];
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
