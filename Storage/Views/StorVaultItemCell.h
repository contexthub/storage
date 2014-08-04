//
//  StorVaultItemCell.h
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StorVaultItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentPositionLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UILabel *heightLabel;
@property (nonatomic, weak) IBOutlet UILabel *nicknamesLabel;

@end