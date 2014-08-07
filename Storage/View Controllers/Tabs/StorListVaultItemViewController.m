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
#import "StorConstants.h"

#import "StorVaultItemCell.h"
#import "StorEditVaultItemViewController.h"

@interface StorListVaultItemViewController ()
@property (nonatomic, strong) NSMutableArray *vaultItems;
@property (nonatomic, strong) NSMutableArray *filteredVaultItems;

@property (nonatomic, weak) StorVaultItem *selectedVaultItem;
@property (nonatomic) BOOL verboseContextHubLogging;
@end

@implementation StorListVaultItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.searchDisplayController.searchResultsTableView registerClass:[StorVaultItemCell class] forCellReuseIdentifier:@"StorVaultItemCellIdentifier"];
    
    self.verboseContextHubLogging = YES; // Verbose logging shows all responses from ContextHub
    self.vaultItems = [NSMutableArray array];
    self.filteredVaultItems = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadVaultItems];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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

- (void)loadVaultItems {
    // Grab vault items from ContextHub
    [[CCHVault sharedInstance] getItemsWithTags:@[StorVaultItemTag] completionHandler:^(NSArray *responses, NSError *error) {
        
        if (!error) {
            
            if (self.verboseContextHubLogging) {
                NSLog(@"Stor: [CCHVault getItemsWithTags: completionHandler:] response: %@", responses);
            }
            
            [self.vaultItems removeAllObjects];
            
            for (NSDictionary *vaultDict in responses) {
                StorVaultItem *vaultItem = [[StorVaultItem alloc] initWithDictionary:vaultDict];
                [self.vaultItems addObject:vaultItem];
            }
            
            [self.tableView reloadData];
        } else {
            NSLog(@"Stor: Could not sync vault items with ContextHub");
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editVaultItemSegue"]) {
        StorEditVaultItemViewController *editVC = segue.destinationViewController;
        editVC.vaultItem = self.vaultItems[[self.tableView indexPathForSelectedRow].row];
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
    
    [[CCHVault sharedInstance] getItemsWithTags:@[StorVaultItemTag] keyPath:keyPath value:searchText completionHandler:^(NSArray *responses, NSError *error) {
        
        if (!error) {
            
            if (self.verboseContextHubLogging) {
                NSLog(@"Stor: [CCHVault getItemsWithTags: keyPath: value: completionHandler:] response: %@", responses);
            }
            
            [self.filteredVaultItems removeAllObjects];
            
            for (NSDictionary *vaultDict in responses) {
                StorVaultItem *vaultItem = [[StorVaultItem alloc] initWithDictionary:vaultDict];
                [self.filteredVaultItems addObject:vaultItem];
            }
            
            // Reload the table view if we get no errors
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            NSLog(@"Stor: Could not filter vault items using ContextHub");
        }
    }];
}

// Called each time a character is entered or deleted from search bar
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Grab vault items from ContextHub again since some might have been deleted
    [self loadVaultItems];
}

#pragma mark - Table View Methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return self.filteredVaultItems.count;
    } else {
        return self.vaultItems.count;
    }
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StorVaultItemCell *cell = (StorVaultItemCell *)[self.tableView dequeueReusableCellWithIdentifier:@"StorVaultItemCellIdentifier"];
    StorVaultItem *vaultItem = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        vaultItem = self.filteredVaultItems[indexPath.row];
    } else {
        vaultItem = self.vaultItems[indexPath.row];
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
            vaultItemToDelete = self.filteredVaultItems[indexPath.row];
            
            // Remove vault item from our filtered array
            if ([self.filteredVaultItems containsObject:vaultItemToDelete]) {
                [self.filteredVaultItems removeObject:vaultItemToDelete];
            }
            
            // Remove vault item from our regular array also
            if ([self.vaultItems containsObject:vaultItemToDelete]) {
                [self.vaultItems removeObject:vaultItemToDelete];
            }
        } else {
            vaultItemToDelete = self.vaultItems[indexPath.row];
            
            // Remove vault item from our array
            if ([self.vaultItems containsObject:vaultItemToDelete]) {
                [self.vaultItems removeObject:vaultItemToDelete];
            }
        }
        
        // Create the dictionary that's need to make the dictionary to delete the item in ContextHub (updating an item uses the same structure)
        NSDictionary *data = @{@"firstName":vaultItemToDelete.firstName, @"lastName":vaultItemToDelete.lastName, @"currentPosition":vaultItemToDelete.currentPosition, @"ageInYears":[NSString stringWithFormat:@"%ld", (long)vaultItemToDelete.ageInYears], @"heightInFeet": [NSString stringWithFormat:@"%f", vaultItemToDelete.heightInFeet], @"nicknames":vaultItemToDelete.nicknames};
        NSDictionary *vault_info = @{@"id":vaultItemToDelete.vaultID, @"created_at":[vaultItemToDelete.vaultDict valueForKeyPath:@"vault_info.created_at"], @"updated_at":[vaultItemToDelete.vaultDict valueForKeyPath:@"vault_info.updated_at"], @"tags":vaultItemToDelete.vaultTags};
        NSDictionary *vaultItem = @{@"data":data, @"vault_info":vault_info};
        
        // Delete vault item from ContextHub
        [[CCHVault sharedInstance] deleteItem:vaultItem completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                if (self.verboseContextHubLogging) {
                    NSLog(@"Stor: [CCHVault deleteItem: completionHandler:] response: %@", response);
                }
                
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                NSLog(@"Stor: Successfully deleted vault item %@ on ContextHub", vaultItemToDelete.fullName);
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting vault item from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                NSLog(@"Stor: Could not delete vault item %@ on ContextHub", vaultItemToDelete.fullName);
            }
            
            // Stop table editing
            [self.tableView setEditing:FALSE animated:YES];
            [self updateEditButtonUI];
        }];
    }
}

@end