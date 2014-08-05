//
//  StorEditVaultItemViewController.m
//  Storage
//
//  Created by Joefrey Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorEditVaultItemViewController.h"

#import "StorVaultItem.h"
#import "StorVaultItemStore.h"

#import "StorConstants.h"

@interface StorEditVaultItemViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *currentPositionTextField;
@property (nonatomic, weak) IBOutlet UISlider *ageSlider;
@property (nonatomic, weak) IBOutlet UISlider *heightSlider;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UILabel *heightLabel;
@property (nonatomic, weak) IBOutlet UITextField *nicknamesTextField;

@end

@implementation StorEditVaultItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.heightSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (self.vaultItem) {
        self.title = @"Edit Vault Item";
        self.firstNameTextField.text = self.vaultItem.firstName;
        self.lastNameTextField.text = self.vaultItem.lastName;
        self.currentPositionTextField.text = self.vaultItem.currentPosition;
        self.ageSlider.value = self.vaultItem.ageInYears;
        self.heightSlider.value = self.vaultItem.heightInFeet;
        self.nicknamesTextField.text = self.vaultItem.nicknamesString;
        
        self.ageLabel.text = [NSString stringWithFormat:@"%d", (int)self.ageSlider.value];
        self.heightLabel.text = [NSString stringWithFormat:@"%.1f", self.heightSlider.value];
    } else {
        self.title = @"New Vault Item";
        UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem = editButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Vault

- (void)createVaultItem {
    StorVaultItem *vaultItem = [[StorVaultItem alloc] init];
    vaultItem.firstName = self.firstNameTextField.text;
    vaultItem.lastName = self.lastNameTextField.text;
    vaultItem.currentPosition = self.currentPositionTextField.text;
    vaultItem.ageInYears = (int)self.ageSlider.value;
    vaultItem.heightInFeet = self.heightSlider.value;
    vaultItem.vaultTags = @[StorVaultItemTag];
    NSString *nicknamesWithoutWhiteSpace = [self.nicknamesTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    vaultItem.nicknames = [[nicknamesWithoutWhiteSpace componentsSeparatedByString:@","] mutableCopy];
    
    // Create a vault item in the StorVaultItemStore
    [[StorVaultItemStore sharedInstance] createVaultItem:vaultItem completionHandler:^(StorVaultItem *createdVaultItem, NSError *error) {
        
        if (!error) {
            // New vault item has already been saved in our store so we don't need to add it
            // Dismiss this view
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error creating your vault item in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }];
}

- (void)updateVaultItem {
    // Update the vault Item
    self.vaultItem.firstName = self.firstNameTextField.text;
    self.vaultItem.lastName = self.lastNameTextField.text;
    self.vaultItem.currentPosition = self.currentPositionTextField.text;
    self.vaultItem.ageInYears = (int)self.ageSlider.value;
    self.vaultItem.heightInFeet = self.heightSlider.value;
    NSString *nicknamesWithoutWhiteSpace = [self.nicknamesTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.vaultItem.nicknames = [[nicknamesWithoutWhiteSpace componentsSeparatedByString:@","] mutableCopy];
    
    [[StorVaultItemStore sharedInstance] updateVaultItem:self.vaultItem completionHandler:^(NSError *error) {
        
        if (!error) {
            // Updated vault item has already been saved in our store so we don't need to add it again
            // Dismiss this view
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error updating your vault item in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }];
}

#pragma mark - Actions

- (void)cancelButtonTapped:(id)sender {
    if (self.vaultItem) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    
    if (self.vaultItem) {
        [self updateVaultItem];
    } else {
        [self createVaultItem];
    }
}

- (void)valueChanged:(id)sender {
    
    if (sender == self.ageSlider) {
        self.ageLabel.text = [NSString stringWithFormat:@"%d", (int)self.ageSlider.value];
    } else if (sender == self.heightSlider) {
        self.heightLabel.text = [NSString stringWithFormat:@"%.1f", self.heightSlider.value];
    }
}

#pragma mark - Table View Methods

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    [footer.textLabel setTextColor:[UIColor whiteColor]];
}

#pragma mark - Text Field Delegate Methods

// Move from one text field to the next with the "Done" button, register with the last button
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            [self.lastNameTextField becomeFirstResponder];
            
            break;
        case 1:
            [self.currentPositionTextField becomeFirstResponder];
            
            break;
        case 2:
            [self.ageSlider becomeFirstResponder];
            
            break;
        case 3:
            [self.heightSlider becomeFirstResponder];
            
            break;
        case 4:
            [self.nicknamesTextField becomeFirstResponder];
            
            break;
        case 5:
            [self doneButtonTapped:nil];
            
            break;
        default:
            
            break;
    }
    
    return NO;
}

@end