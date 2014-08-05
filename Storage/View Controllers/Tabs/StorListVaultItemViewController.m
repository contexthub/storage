//
//  StorListVaultItemViewController.m
//  Storage
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorListVaultItemViewController.h"
#import <ContextHub/ContextHub.h>

#import "StorVaultItem.h"
#import "StorVaultItemStore.h"

#import "StorVaultItemCell.h"
#import "StorEditVaultItemViewController.h"

@interface StorListVaultItemViewController ()
@property (nonatomic, weak) StorVaultItem *selectedVaultItem;
@end

@implementation StorListVaultItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchDisplayController.searchResultsTableView registerClass:[StorVaultItemCell class] forCellReuseIdentifier:@"StorVaultItemCellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do initial data sync
    [[StorVaultItemStore sharedInstance] syncVaultItems];
    
    // Register to listen to notifications about vault item sync being completed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:(NSString *)StorVaultItemSyncCompletedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

// Edit/Done button was tapped
- (IBAction)toggleEditing:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    // Update button UI
    [self updateEditButtonUI];
}

// Update button UI
- (void)updateEditButtonUI {
    UIBarButtonSystemItem editButtonType = self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:editButtonType target:self action:@selector(toggleEditing:)];
    self.navigationItem.leftBarButtonItem = editButtonItem;
}

// Respond to synchronization finishing by removing and adding all vault items
- (void)syncCompleted:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editVaultItemSegue"]) {
        StorEditVaultItemViewController *editVC = segue.destinationViewController;
        editVC.vaultItem = [StorVaultItemStore sharedInstance].vaultItems[[self.tableView indexPathForSelectedRow].row];
    }
}

- (IBAction)unwindToListVaultItemVC:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Search

// Searches our store based on scope string
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString *keyPath = @"";
    if ([scope isEqualToString:@"First name"]) {
        keyPath = @"firstName";
    } else if ([scope isEqualToString:@"Last name"]) {
        keyPath = @"lastName";
    }
    
    // Find vault items with match for value at key path (for strings, this is an exact case-sensitive match)
    [[StorVaultItemStore sharedInstance] getVaultItemsWithKeyPath:keyPath value:searchText completionHandler:^(NSError *error) {
        
        if (!error) {
            // Reload the table view if we get no errors
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            NSLog(@"Stor: Failed to get vault items with matching value at key path");
        }
    }];
}

// Called each time a character is entered or deleted from search bar
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return NO;
}

#pragma mark - Table View Methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [StorVaultItemStore sharedInstance].filteredVaultItems.count;
    } else {
        return [StorVaultItemStore sharedInstance].vaultItems.count;
    }
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StorVaultItemCell *cell = (StorVaultItemCell *)[self.tableView dequeueReusableCellWithIdentifier:@"StorVaultItemCellIdentifier"];
    StorVaultItem *vaultItem = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        vaultItem = [StorVaultItemStore sharedInstance].filteredVaultItems[indexPath.row];
        
        
        
    } else {
        vaultItem = [StorVaultItemStore sharedInstance].vaultItems[indexPath.row];
    }
    
    cell.nameLabel.text = vaultItem.fullName;
    cell.currentPositionLabel.text = vaultItem.currentPosition;
    cell.ageLabel.text = [NSString stringWithFormat:@"%d years old", (int)vaultItem.ageInYears];
    cell.heightLabel.text = [NSString stringWithFormat:@"%.1f feet", (float)vaultItem.heightInFeet];
    cell.nicknamesLabel.text = [NSString stringWithFormat:@"Nicknames: %@", vaultItem.nicknamesString];
    
    return cell;
}

// Height for row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

// A row is being updated/deleted
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete a vault item
        StorVaultItem *vaultItemToDelete = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            vaultItemToDelete = [StorVaultItemStore sharedInstance].filteredVaultItems[indexPath.row];
        } else {
            vaultItemToDelete = [StorVaultItemStore sharedInstance].vaultItems[indexPath.row];
        }
        
        [[StorVaultItemStore sharedInstance] deleteVaultItem:vaultItemToDelete completionHandler:^(NSError *error) {
            
            if (!error) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                // Synchronize vault items (this would not need to be done if push were enabled)
                [[StorVaultItemStore sharedInstance] syncVaultItems];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting vault item from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
            
            // Stop table editing
            [self.tableView setEditing:FALSE animated:YES];
            [self updateEditButtonUI];
        }];
    }
}

@end