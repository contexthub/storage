//
//  StorVaultItem.m
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorVaultItem.h"
#import <ContextHub/ContextHub.h>

@interface StorVaultItem ()
@end

@implementation StorVaultItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _firstName = [dictionary valueForKeyPath:@"data.firstName"];
        _lastName = [dictionary valueForKeyPath:@"data.lastName"];
        _currentPosition = [dictionary valueForKeyPath:@"data.currentPosition"];
        
        // Values that represent integers and floats need to be converted
        _ageInYears = [[dictionary valueForKeyPath:@"data.ageInYears"] integerValue];
        _heightInFeet = [[dictionary valueForKeyPath:@"data.heightInFeet"] floatValue];
        
        // Values that represent arrays and dictionaries do *not* need to be converted
        _nicknames = [dictionary valueForKeyPath:@"data.nicknames"];
        
        
        // ContextHub properties
        _vaultID = [dictionary valueForKeyPath:@"vault_info.id"];
        _vaultTags = [dictionary valueForKeyPath:@"vault_info.tags"];
        
        // Create a date formatter that understands server UTC timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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

// We override this m
- (NSDictionary *)dataDictionaryForVaultItem {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // Set the values
    [dictionary setValue:self.firstName forKey:@"firstName"];
    [dictionary setValue:self.lastName forKey:@"lastName"];
    [dictionary setValue:self.currentPosition forKey:@"currentPosition"];
    
    // Integers and floats need to be converted into strings
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)self.ageInYears] forKey:@"ageInYears"];
    [dictionary setValue:[NSString stringWithFormat:@"%f", self.heightInFeet] forKey:@"heightInFeet"];
    
    // Arrays and dictionaries can be set directly
    [dictionary setValue:self.nicknames forKey:@"nicknames"];
    
    return dictionary;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)nicknamesString {
    NSMutableString *nicknamesString = [[NSMutableString alloc] init];
    [nicknamesString appendString:@""];
    
    if (self.nicknames.count > 0) {
        
        [self.nicknames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (idx == 0) {
                [nicknamesString appendString:obj];
            } else {
                [nicknamesString appendString:@", "];
                [nicknamesString appendString:obj];
            }
        }];
    }
    
    return nicknamesString;
}

@end