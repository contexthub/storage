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
@property (nonatomic, strong, readwrite) NSMutableArray *vaultItems;
@property (nonatomic, strong, readwrite) NSMutableArray *filteredVaultItems;

@property (nonatomic) BOOL verboseContextHubLogging;
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
        _filteredVaultItems = [NSMutableArray array];
        
        _verboseContextHubLogging = YES; // Verbose logging shows all responses from ContextHub
    }
    
    return self;
}

// Creates a vault item in ContextHub and keeps a copy in our store
- (void)createVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(StorVaultItem *createdVaultItem, NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHVault sharedInstance] createItem:[vaultItem dataDictionaryForVaultItem] tags:vaultItem.vaultTags completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                
                if (self.verboseContextHubLogging) {
                     NSLog(@"Stor: [CCHVault createItem: completionHandler:] response: %@", response);
                }
                
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
            NSLog(@"Stor: Succesfully synced %d new vault items from ContextHub", (int)(responses.count - self.vaultItems.count));
            
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

// Get all vault items in ContextHub with a specific value for a given key path
- (void)getVaultItemsWithKeyPath:(NSString *)keyPath value:(NSString *)value completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHVault sharedInstance] getItemsWithTags:@[StorVaultItemTag] keyPath:keyPath value:value completionHandler:^(NSArray *responses, NSError *error) {
            
            if (!error) {
                
                if (self.verboseContextHubLogging) {
                    NSLog(@"Stor: [CCHVault getItemsWithTags: keyPath: value: completionHandler:] response: %@", responses);
                }
                
                [self.filteredVaultItems removeAllObjects];
                
                for (NSDictionary *vaultDict in responses) {
                    StorVaultItem *vaultItem = [[StorVaultItem alloc] initWithDictionary:vaultDict];
                    [self.filteredVaultItems addObject:vaultItem];
                }
                
                completionHandler (nil);
            } else {
                NSLog(@"Stor: Could not filter vault items using ContextHub");
                completionHandler (error);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Updates a vault item in ContextHub and in our store
- (void)updateVaultItem:(StorVaultItem *)vaultItem completionHandler:(void (^)(NSError *error))completionHandler {
    
    if (completionHandler) {
        [[CCHVault sharedInstance] updateItem:[vaultItem dictionaryForVaultItem] completionHandler:^(NSDictionary *response, NSError *error) {
            
            if (!error) {
                
                if (self.verboseContextHubLogging) {
                    NSLog(@"Stor: [CCHVault updateItem: completionHandler:] response: %@", response);
                }
                
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
                if (self.verboseContextHubLogging) {
                    NSLog(@"Stor: [CCHVault deleteItem: completionHandler:] response: %@", response);
                }
                
                NSLog(@"Stor: Successfully deleted vault item %@ on ContextHub", vaultItem.fullName);
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