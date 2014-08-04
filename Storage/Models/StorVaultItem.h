//
//  StorVaultItem.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCHVaultItem.h"

@interface StorVaultItem : CCHVaultItem

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *currentPosition;

@property (nonatomic) NSUInteger ageInYears;
@property (nonatomic) CGFloat heightInFeet;
@property (nonatomic, strong) NSMutableArray *nicknames;

- (NSDictionary *)dataDictionaryForVaultItem;

- (NSString *)fullName;
- (NSString *)nicknamesString;


@end