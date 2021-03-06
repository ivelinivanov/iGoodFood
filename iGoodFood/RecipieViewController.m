//
//  RecipieViewController.m
//  iGoodFood
//
//  Created by Ivelin Ivanov on 9/13/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "RecipieViewController.h"
#import "AddRecipieViewController.h"
#import "Recipie.h"
#import "RecipieCategory.h"
#import "RecipieCell.h"
#import "DetailRecipieViewController.h"

@interface RecipieViewController ()
{
    NSMutableArray *recipies;
}

@property (strong, nonatomic) Recipie *selectedRecipie;

-(IBAction)addRecipieButtonPressed;

@end

@implementation RecipieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.currentCategory.name;
    
    self.view.tintColor = [UIColor colorWithRed:0.322 green:0.749 blue:0.627 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadRecipies];
}

-(IBAction)addRecipieButtonPressed
{
    [self performSegueWithIdentifier:@"toAddRecipieView" sender:self];
}

- (void)cellLongPressed:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"What do you want?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        [sheet showInView:recognizer.view];
        
        RecipieCell *cell = (RecipieCell *)recognizer.view;
        
        [[DataModel sharedModel] getRecipieForName:cell.recipieLabel.text completion:^(Recipie *requestedRecipe, NSError *error) {
            self.selectedRecipie = requestedRecipe;
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DetailRecipieViewController class]])
    {
        DetailRecipieViewController *destination = (DetailRecipieViewController *)segue.destinationViewController;
        destination.currentRecipie = self.selectedRecipie;
    }
    else if ([segue.destinationViewController isKindOfClass:[AddRecipieViewController class]])
    {
        AddRecipieViewController *destination = (AddRecipieViewController *)segue.destinationViewController;
        destination.currentCategory = self.currentCategory;
        destination.currentUser = self.currentUser;
    }

}

- (void)loadRecipies
{
    [[DataModel sharedModel] getRecipiesForCategory:self.currentCategory completion:^(NSArray *recipes, NSError *error) {
        recipies = [NSMutableArray arrayWithArray:recipes];
        [self.collectionView reloadData];
    }];
}

#pragma mark - Collection View Delegate & DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [recipies count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"recipieCell";
    
    RecipieCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Recipie *recipe = (Recipie *)recipies[indexPath.row];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPressed:)];
    [cell addGestureRecognizer:longPressRecognizer];
    
    [cell configureCellwithRecipe:recipe];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRecipie = recipies[indexPath.row];
    [self performSegueWithIdentifier:@"toDetailRecipie" sender:self];
}

#pragma mark - Action Sheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[DataModel sharedModel] deleteRecipie:self.selectedRecipie completion:^{
            [self loadRecipies];
        }];
    }
}

@end
