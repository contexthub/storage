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
            
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    // The debug flag is automatically set by the compiler, indicating which push gateway server your device will use
    // Xcode deployed builds use the sandbox/development server
    // TestFlight/App Store builds use the production server
    // ContextHub records which environment a device is using so push works properly
    // This must be called BEFORE [ContextHub registerWithAppId:]
    [[ContextHub sharedInstance] setDebug:TRUE];
#endif
    
    // Register the app id of the application you created on https://app.contexthub.com
    [ContextHub registerWithAppId:@"YOUR-VAULT-APP-ID-HERE"];
    
    return YES;
}

@end