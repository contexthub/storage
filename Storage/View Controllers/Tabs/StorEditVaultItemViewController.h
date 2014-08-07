//
//  StorEditVaultItemViewController.h
//  Storage
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StorVaultItem;

@interface StorEditVaultItemViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) StorVaultItem *vaultItem;
@property (nonatomic, weak) NSMutableArray *vaultItems;

@end