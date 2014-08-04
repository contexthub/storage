//
//  CCHVaultItem.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCHVaultItem : NSObject

@property (nonatomic, copy, readonly) NSString *vaultID;
@property (nonatomic, strong) NSMutableArray *vaultTags;
@property (nonatomic, strong, readonly) NSDate *vaultCreatedAtDate;
@property (nonatomic, strong, readonly) NSDate *vaultUpdatedAtDate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)dictionaryForVaultItem;

@end