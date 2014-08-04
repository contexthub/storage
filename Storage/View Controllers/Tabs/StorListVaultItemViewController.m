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

// Respond to synchronization finishing by removing and adding all beacons
- (void)syncCompleted:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editBeaconSegue"]) {
        StorEditVaultItemViewController *editVC = segue.destinationViewController;
        editVC.vaultItem = [StorVaultItemStore sharedInstance].vaultItems[[self.tableView indexPathForSelectedRow].row];
    }
}

- (IBAction)unwindToListVaultItemVC:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Table View Methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [StorVaultItemStore sharedInstance].vaultItems.count;
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StorVaultItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StorVaultItemCellIdentifier"];
    StorVaultItem *vaultItem = [StorVaultItemStore sharedInstance].vaultItems[indexPath.row];
    
    cell.nameLabel.text = vaultItem.fullName;
    cell.currentPositionLabel.text = vaultItem.currentPosition;
    cell.ageLabel.text = [NSString stringWithFormat:@"%d years old", (int)vaultItem.ageInYears];
    cell.heightLabel.text = [NSString stringWithFormat:@"%.1f feet", (float)vaultItem.heightInFeet];
    cell.nicknamesLabel.text = [NSString stringWithFormat:@"Nicknames: %@", vaultItem.nicknamesString];
    
    return cell;
}

// A row is being updated/deleted
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete a beacon
        StorVaultItem *vaultItemToDelete = [StorVaultItemStore sharedInstance].vaultItems[indexPath.row];
        [[StorVaultItemStore sharedInstance] deleteVaultItem:vaultItemToDelete completionHandler:^(NSError *error) {
            
            if (!error) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                // Synchronize beacons (this would not need to be done if push were enabled)
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