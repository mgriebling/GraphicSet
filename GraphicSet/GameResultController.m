//
//  ScoreViewController.m
//  Matchismo
//
//  Created by Mike Griebling on 10.2.2013.
//  Copyright (c) 2013 Michael Griebling. All rights reserved.
//

#import "GameResultController.h"
#import "GameResult.h"

@interface GameResultController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *scoreTextView;
@property (nonatomic) SortType sortOrder;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearButton;

@end

@implementation GameResultController

- (NSString *)gameFilter {
    if (!_gameFilter) _gameFilter = @"";
    return _gameFilter;
}

- (void)updateUI {
    NSMutableAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:@""];
    
    for (GameResult *result in [GameResult gameResultsSortedBy:self.sortOrder withFilter:self.gameFilter]) {
        // Show Date, Duration, and Score
        // add the date and duration as normal fonts
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *string;
        if (result.duration > 999.0) {
            string = [NSString stringWithFormat:@"%@\t%.0f mins\t\t", [dateFormatter stringFromDate:result.end], round(result.duration/60)];
        } else {
            string = [NSString stringWithFormat:@"%@\t%.0f secs\t\t", [dateFormatter stringFromDate:result.end], round(result.duration)];
        }
        [displayText appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        
        // format the score as red, bold-faced font
        string = [NSString stringWithFormat:@"%6d\n", result.score];
        UIFont *font = [UIFont boldSystemFontOfSize:16];
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: font};
        [displayText appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributes]];
    }
    self.scoreTextView.attributedText = displayText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    [self updateUI];
}

- (void)setUp {
}

- (void)awakeFromNib {
    [self setUp];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setUp];
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [GameResult clearScores];
        [self updateUI];
    }
}

- (IBAction)clearScore:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Score" message:@"This will permanently delete ALL the scores!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Scores", nil];
    [alert show];
}

- (IBAction)sortOrderChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 2: self.sortOrder = SORT_BY_SCORE; break;
        case 1: self.sortOrder = SORT_BY_DURATION; break;
        default: self.sortOrder = SORT_BY_DATE; break;
    }
    [self updateUI];
}

@end
