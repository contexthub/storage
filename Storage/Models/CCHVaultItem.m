//
//  CCHVaultItem.m
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "CCHVaultItem.h"

@interface CCHVaultItem ()
@property (nonatomic, strong) NSMutableDictionary *vaultDict;
@end

@implementation CCHVaultItem

static NSDateFormatter * __dateFormatter = nil;

+ (NSDateFormatter *)dateFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dateFormatter = [[NSDateFormatter alloc] init];
    });
    
    return __dateFormatter;
}

// Creates a vault item
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self) {
        _vaultID = [dictionary valueForKeyPath:@"vault_info.id"];
        _vaultTags = [dictionary valueForKeyPath:@"vault_info.tags"];
        
        // Create a date formatter that understands server UTC timestamp
        NSDateFormatter *dateFormatter = [CCHVaultItem dateFormatter];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Save created_at and updated_at dates
        NSString *createdDate = [self.vaultDict valueForKeyPath:@"vault_info.created_at"];
        _vaultCreatedAtDate = [dateFormatter dateFromString:createdDate];
        NSString *updatedDate = [self.vaultDict valueForKeyPath:@"vault_info.updated_at"];
        _vaultUpdatedAtDate = [dateFormatter dateFromString:updatedDate];
        
        _vaultDict = [dictionary mutableCopy];
    }
    
    return self;
}

// This method is meant to be overridden by a subclass which will provide a dictionary with data contained in the subclass
- (NSDictionary *)dataDictionaryForVaultItem {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    return dictionary;
}

// Creates a dictionary for this vault item when it needs to be updated or deleted
- (NSMutableDictionary *)dictionaryForVaultItem {
    self.vaultDict[@"data"] = [self dataDictionaryForVaultItem];
    [self.vaultDict setValue:self.vaultTags forKeyPath:@"vault_info.tags"];
    
    return [self.vaultDict mutableCopy];
}

@end