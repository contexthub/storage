//
//  StorVaultItem.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorVaultItem : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *currentPosition;
@property (nonatomic) NSUInteger ageInYears;
@property (nonatomic) CGFloat heightInFeet;
@property (nonatomic, strong) NSMutableArray *nicknames;


// ContextHub vault item fields
@property (nonatomic, copy, readonly) NSString *vaultID;
@property (nonatomic, strong) NSArray *vaultTags;
@property (nonatomic, strong, readonly) NSDate *vaultCreatedAtDate;
@property (nonatomic, strong, readonly) NSDate *vaultUpdatedAtDate;
@property (nonatomic, strong) NSMutableDictionary *vaultDict;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)fullName;
- (NSString *)nicknamesString;

@end