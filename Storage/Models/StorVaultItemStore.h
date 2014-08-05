//
//  StorVaultItemStore.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString const *StorVaultItemSyncCompletedNotification;

@class StorVaultItem;

@interface StorVaultItemStore : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *vaultItems;
@property (nonatomic, strong, readonly) NSMutableArray *filteredVaultItems;

+ (StorVaultItemStore *)sharedInstance;

- (void)createVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(StorVaultItem *createdVaultItem, NSError *error))completionHandler;
- (void)syncVaultItems;
- (StorVaultItem *)findVaultItemInStoreWithID:(NSString *)vaultItemID;
- (void)getVaultItemsWithKeyPath:(NSString *)keyPath value:(NSString *)value completionHandler:(void (^)(NSError *error))completionHandler;
- (void)updateVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(NSError *error))completionHandler;
- (void)deleteVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(NSError *error))completionHandler;

@end