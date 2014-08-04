//
//  StorVaultItemStore.m
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorVaultItemStore.h"
#import <ContextHub/ContextHub.h>
#import "StorConstants.h"

#import "StorVaultItem.h"

NSString const *StorVaultItemSyncCompletedNotification = @"StorVaultItemSyncCompletedNotification";

@interface StorVaultItemStore ()
@property (nonatomic, readwrite, strong) NSMutableArray *vaultItems;
@end

@implementation StorVaultItemStore

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static StorVaultItemStore *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[StorVaultItemStore alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _vaultItems = [NSMutableArray array];
    }
    
    return self;
}

// Creates a vault item in ContextHub and keeps a copy in our store
- (void)createVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(StorVaultItem *createdVaultItem, NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHVault sharedInstance] createItem:[vaultItem dataDictionaryForVaultItem] tags:@[StorVaultTag] completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                StorVaultItem *createdVaultItem = [[StorVaultItem alloc] initWithDictionary:response];
                [self.vaultItems addObject:createdVaultItem];
                
                NSLog(@"Stor: Successfully created vault item %@ on ContextHub", createdVaultItem.fullName);
                completionHandler (createdVaultItem, nil);
            } else {
                NSLog(@"Stor: Could not create vault item %@ on ContextHub", vaultItem.fullName);
                completionHandler (nil, error);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Synchronizes vault items from ContextHub
- (void)syncVaultItems {
    [[CCHVault sharedInstance] getItemsWithTags:@[StorVaultTag] completionHandler:^(NSArray *responses, NSError *error) {
       
        if (!error) {
            NSLog(@"Stor: Succesfully synced %d new vault items from ContextHub", (int)(responses.count - self.vaultItems.count));
            [self.vaultItems removeAllObjects];
            
            for (NSDictionary *vaultDict in responses) {
                StorVaultItem *vaultItem = [[StorVaultItem alloc] initWithDictionary:vaultDict];
                [self.vaultItems addObject:vaultItem];
            }
            
            // Post notification that sync is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)StorVaultItemSyncCompletedNotification object:nil];
        } else {
            NSLog(@"Stor: Could not sync vault items with ContextHub");
        }
    }];
}

// Find a vault item with a specific ID in our vault store if it exists
- (StorVaultItem *)findVaultItemInStoreWithID:(NSString *)vaultID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.vaultID like %@", vaultID];
    NSArray *filteredVaultItems = [self.vaultItems filteredArrayUsingPredicate:predicate];
    
    if ([filteredVaultItems count] > 0) {
        StorVaultItem *foundVaultItem = filteredVaultItems[0];
        
        return foundVaultItem;
    }
    
    return nil;
}

// Updates a vault item in ContextHub and in our store
- (void)updateVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHVault sharedInstance] updateItem:[vaultItem dictionaryForVaultItem] completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                NSLog(@"Stor: Successfully updated vault item %@ on ContextHub", vaultItem.fullName);
                completionHandler (nil);
            } else {
                NSLog(@"Stor: Could not update vault item %@ on ContextHub", vaultItem.fullName);
                completionHandler (error);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Delete a vault item in ContextHub and remove it from our store
- (void)deleteVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        
        // Remove vault item from our array
        if ([self.vaultItems containsObject:vaultItem]) {
            [self.vaultItems removeObject:vaultItem];
        }
        
        // Remove vault item from ContextHub
        [[CCHVault sharedInstance] deleteItem:[vaultItem dictionaryForVaultItem] completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                NSLog(@"Stor: Successfully deleted beacon %@ on ContextHub", vaultItem.fullName);
                completionHandler(nil);
            } else {
                NSLog(@"Stor: Could not delete vault item %@ on ContextHub", vaultItem.fullName);
                completionHandler(error);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

@end