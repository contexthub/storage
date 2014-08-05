//
//  CCHVaultItem.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The vault item class makes it easier to manage CRUDing vault items in ContextHub by dealing with static Objective-C data types instead of values inside an NSDictionary
 */
@interface CCHVaultItem : NSObject

/**
 The id of the item in vault (read-only)
 */
@property (nonatomic, copy, readonly) NSString *vaultID;

/**
 The tags of the item in vault (read-write)
 */
@property (nonatomic, strong) NSMutableArray *vaultTags;

/**
 The UTC datetime when the vault item was created (read-only)
 */
@property (nonatomic, strong, readonly) NSDate *vaultCreatedAtDate;

/**
 The UTC datetime when the vault item was last updated (read-only)
 @note Items which are write the exact same information as currently on ContextHub's servers will not update the "updated_at" timestamp
 */
@property (nonatomic, strong, readonly) NSDate *vaultUpdatedAtDate;

/**
 Initializes a vault item
 
 @param dictionary The dictionary returned from CCHVault createItem which initializes the vault item structure
 @note This method is meant to be overridden with your own custom method which will call [super initWithDictionary:dictionary] so that vault variables are assigned
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Returns the dictionary for the data key in a vault item

 @note This method is meant to be overridden with your own custom method which will return a dictionary with your data
 */
- (NSDictionary *)dataDictionaryForVaultItem;

/**
 Returns the dictionary for the vault item
 
 @note This method returns the entire dictionary for a vault item with two keys (data and vault_info). It will call [dataDictionaryForVaultItem] to get the updated data key state for this vault item based on your data.
 */
- (NSMutableDictionary *)dictionaryForVaultItem;

@end