//
//  StorTabBarController.m
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorTabBarController.h"

/**
 Tab bar indicies
 */
typedef NS_ENUM(NSUInteger, StorTabBarIndex) {
    StorTabBarListIndex = 0,
    StorTabBarAboutIndex
};

@implementation StorTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // Initially selected tab bar icon needs to have selected images
    UITabBarItem *tabBarItem = self.tabBar.items[0];
    tabBarItem.image = [UIImage imageNamed:@"VaultTabBarIcon"];
    tabBarItem.selectedImage = [UIImage imageNamed:@"VaultSelectedTabBarIcon"];
}

// Selected tab bar item should have selected tab bar item icons
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    switch ([tabBarController selectedIndex]) {
        case StorTabBarListIndex:
            viewController.tabBarItem.image = [UIImage imageNamed:@"VaultTabBarIcon"];
            viewController.tabBarItem.selectedImage = [UIImage imageNamed:@"VaultSelectedTabBarIcon"];
            
            break;
        case StorTabBarAboutIndex:
            viewController.tabBarItem.image = [UIImage imageNamed:@"AboutTabBarIcon"];
            viewController.tabBarItem.selectedImage = [UIImage imageNamed:@"AboutSelectedTabBarIcon"];
            
            break;
        default:
            
            break;
    }
}

@end