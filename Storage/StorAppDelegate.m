//
//  StorAppDelegate.m
//  Storage
//
//  Created by Jeff Kibuule on 8/4/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "StorAppDelegate.h"
#import "StorConstants.h"

@interface StorAppDelegate ()
@end

@implementation StorAppDelegate
            
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register with ContextHub
#ifdef DEBUG
    // This tells ContextHub that you are running a debug build.
    [[ContextHub sharedInstance] setDebug:TRUE];
#endif
    
    //Register the app id of the application you created on https://app.contexthub.com
    [ContextHub registerWithAppId:@"YOUR-VAULT-APP-ID-HERE"];
    
    return YES;
}

@end