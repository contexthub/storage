# Storage (Vault) Sample app
--

The Storage sample app that introduces you to the vault features of the ContextHub iOS SDK.

## Purpose
This sample application will show you how to create, retrieve, update, delete (CRUD) and perform key path vault search on vault items  in ContextHub.

## ContextHub

In this sample application, we use ContextHub to CRUD vault items on the server then list them in a simple UITableView. ContextHub allows you to store small amounts of data on the server which can be accessed by all devices without starting up your own database server.

## Background

The "vault" in ContextHub allows developers to store JSON-compliant data structures on a server to be accessed by all devices with your app and most importantly context rules. Data stored in the vault can be simple key-values as well as nested structures of arrays and dictionaries. It is important to note that "vault" is not a relational database and is not meant to store millions of records that need relational queries performed on them, a proper database is still necessary for those kinds of scenarios.

## Sample Code

In this sample, most of the important code that deals with CRUDing vault items occurs in `StorVaultItemStore.m` similar to above. Each method goes though a single operation you'll need to use `CCHVault`. `StorVaultItemStore` provides a thin wrapper around `CCHVault` which allows us to maintain state when UI elements like UITableView need to know how many vault items we currently have. 

`StorVaultItem` is a subclass of `CCHVaultItem` which stores general information about all vault items like vault id, tags, created_at and updated_at dates. The subclass stores custom properties which we want saved as data in ContextHub. This makes dealing with `CCHVault`a bit easier which expects NSDictionary for all methods. `StorListVaultItemViewController` and `StorEditVaultItemViewController` show how to write UI code based around `StorVaultItemStore` to CRUD and search for vault items.

## Getting Started

1. Get started by either forking or cloning the Storage repo. Visit [GitHub Help](https://help.github.com/articles/fork-a-repo) if you need help.
2. Go to [ContextHub](http://app.contexthub.com) and create a new DetectMe application.
3. Find the app id associated with the application you just created. Its format looks something like this: `13e7e6b4-9f33-4e97-b11c-79ed1470fc1d`.
4. Open up your Xcode project and put the app id into the `[ContextHub registerWithAppId:]` method call.
5. Build and run the project on your device.
6. You should see a blank table view (as no vault items have been entered yet!)

## Xcode Console

1. This sample app will log responses from the CCHVault class of the ContextHub iOS SDK as you create, retrieve, update, delete and search for vault items in the app. Use shortcut `Shift-⌘-Y` if your console is not already visible. 
2. You should see the message "CCH: Device has successfully registered your application ID with ContextHub".
3. Use the logged statements to get an idea of the structures returned from each of these API calls to become more familiar with them.

## Usage

Below shows the basics of how the CCHVault class is used
```objc
// Creating a vault item with a firstName of "Jeff" and tag "vault-tag"
// (StorVaultItem is a custom class with custom properties that wraps around CCHVaultItem base class)
StorVaultItem *item = [[StorVaultItem alloc] init];
item.firstName = @"Jeff";   // Our custom property
item.vaultTags = @[@"vault-tag"];
[[CCHVault sharedInstance] createItem:[vaultItem dataDictionaryForVaultItem] tags:vaultItem.vaultTags completionHandler:^(NSDictionary *response, NSError *error) {

    if (!error) {
        StorVaultItem *createdVaultItem = [[StorVaultItem alloc] initWithDictionary:response];
        [self.vaultItems addObject:createdVaultItem];

        NSLog(@"Stor: Successfully created vault item %@ on ContextHub", createdVaultItem.firstName);
        completionHandler (createdVaultItem, nil);
    } else {
        NSLog(@"Stor: Could not create vault item %@ on ContextHub", vaultItem.fullName);
        completionHandler (nil, error);
    }
}];

// Getting all vault items with the tag "vault-tag" and adding them to a NSMutableArray vaultItems
[[CCHVault sharedInstance] getItemsWithTags:@[@"vault-tag"] completionHandler:^(NSArray *responses, NSError *error) {

    if (!error) {

        for (NSDictionary *vaultDict in responses) {
            StorVaultItem *vaultItem = [[StorVaultItem alloc] initWithDictionary:vaultDict];
            [self.vaultItems addObject:vaultItem];
        }

        completionHandler (nil);
    } else {
        NSLog(@"Stor: Could not filter vault items using ContextHub");
        completionHandler (error);
    }
}];

// Getting all vault items with the tag "vault-tag" and match "firstName = Jeff" and adding them to a NSMutableArray filteredVaultItems
NSString *keyPath = @"firstName";
NSString *value = @"Jeff";
[[CCHVault sharedInstance] getItemsWithTags:@[@"vault-tag"] keyPath:keyPath value:value completionHandler:^(NSArray *responses, NSError *error) {

    if (!error) {

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

// Updating a vault item with the name "Michael" and adding the tag "employee"
vaultItem.firstName = @"Michael";
vaultItem.vaultTags = @[@"vault-tag", @"employee"];
[[CCHVault sharedInstance] updateItem:[vaultItem dictionaryForVaultItem] completionHandler:^(NSDictionary *response, NSError *error) {

    if (!error) {
        NSLog(@"Stor: Successfully updated vault item %@ on ContextHub", vaultItem.fullName);
        completionHandler (nil);
    } else {
        NSLog(@"Stor: Could not update vault item %@ on ContextHub", vaultItem.fullName);
        completionHandler (error);
    }
}];

// Deleting a vault item
[[CCHVault sharedInstance] deleteItem:[vaultItem dictionaryForVaultItem] completionHandler:^(NSError *error) {

    if (!error) {
        NSLog(@"Stor: Successfully updated vault item %@ on ContextHub", vaultItem.fullName);
        completionHandler (nil);
    } else {
        NSLog(@"Stor: Could not update vault item %@ on ContextHub", vaultItem.fullName);
        completionHandler (error);
    }
}];
```

That's it! Hopefully this sample application showed you how easy it is to work with vault items in ContextHub to easily store information accessible from all devices and context rules.