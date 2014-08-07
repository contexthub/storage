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

In this sample, most of the important code that deals with CRUDing vault items occurs in `StorListVaultItemController.m` and `StorEditVaultItemController.m` similar to above. Each method goes though a single operation you'll need to use `CCHVault`. `CCHVault` expects JSON-compliant dictionaries so they can be serialized when stored in vault on ContextHub. `StorVaultItem` contains the properties we want to store.

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

Below shows the basics of how the CCHVault class is used to do basic CRUD functions
```objc
// Creating a vault item with a firstName of "Jeffrey", a few nicknames, and cities lived in with years associated with them
// Our custom properties (string, array, dictionary)
NSDictionary *item = @{@"firstName": @"Jeffrey", @"nicknames":@[@"Jeff", @"Michaelangelo"], @"cities": @{@"New York City":@"1995", @"Austin":@"2004", @"Houston":@"2010"}}; 
[[CCHVault sharedInstance] createItem:item tags:@"vault-tag" completionHandler:^(NSDictionary *response, NSError *error) {

    if (!error) {
        // Log the response
        NSLog(@"[CCHVault createItem: tags: completionHandler:] response: %@", response);
        
        // Accessing our saved data in the response
        NSString *firstName = [response valueForKeyPath:@"data.firstName"];
        NSArray *nicknames = [response valueForKeyPath:@"data.nicknames"];
        NSDictionary *cities = [response valueForKeyPath:@"data.cities"];

        // Accessing vault_info in the response
        NSString *vaultID = [response valueForKeyPath:@"vault_info.id"];
        NSArray *tags = [response valueForKeyPath:@"vault_info.tags"];
        
        // Create a date formatter that will interpret ISO 8661 timestamps
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

        // Accessing created_at and updated_at dates
        NSString *createdDate = [response valueForKeyPath:@"vault_info.created_at"];
        NSString *updatedDate = [response valueForKeyPath:@"vault_info.updated_at"];
        NSDate *vaultCreatedAtDate = [dateFormatter dateFromString:createdDate];
        NSDate *vaultUpdatedAtDate = [dateFormatter dateFromString:updatedDate];
    } else {
        NSLog(@"Could not create vault item %@ in ContextHub", item.firstName);
        NSLog(@"Error: %@", error);
    }
}];

// Getting all vault items with the tag "vault-tag" and log out the names
[[CCHVault sharedInstance] getItemsWithTags:@[@"vault-tag"] completionHandler:^(NSArray *responses, NSError *error) {

    if (!error) {

        for (NSDictionary *vaultDict in responses) {
            NSLog(@"Name: %@", [vaultDict valueForKeyPath:@"data.firstName"]);
        }
    } else {
        NSLog(@"Could not get vault items in ContextHub");
        NSLog(@"Error: %@", error);
    }
}];

// Getting all vault items with the tag "vault-tag" and match "firstName = Jeff"
NSString *keyPath = @"firstName";
NSString *value = @"Jeff";
[[CCHVault sharedInstance] getItemsWithTags:@[@"vault-tag"] keyPath:keyPath value:value completionHandler:^(NSArray *responses, NSError *error) {

    if (!error) {

        for (NSDictionary *vaultDict in responses) {
            // Should only be printing first names that are "Jeff" since that's what we asked for
            NSLog(@"Name: %@", [vaultDict valueForKeyPath:@"data.firstName"]);
        }
    } else {
        NSLog(@"Could not filter vault items in ContextHub");
        NSLog(@"Error: %@", error);
    }
}];

// Updating a vault item with the first name "Michael" and adding the tag "employee"
// Response is the same dictionary item from either the create or get method
NSDictionary *data = @{@"firstName":@"Michael"};
NSDictionary *vault_info = @{@"id":[response valueForKeyPath:@"vault_info.id"], @"created_at":[response valueForKeyPath:@"vault_info.created_at"], @"updated_at":[response valueForKeyPath:@"vault_info.updated_at"], @"tags":[response valueForKeyPath:@"vault_info.tags"]};
NSDictionary *updatedItem = @{@"data":data, @"vault_info":vault_info};
[[CCHVault sharedInstance] updateItem:updatedItem completionHandler:^(NSDictionary *response, NSError *error) {

    if (!error) {
        NSLog(@"Successfully updated vault item %@ on ContextHub", response[@"firstName"]);
    } else {
        NSLog(@"Could not update vault item %@ on ContextHub", data[@"firstName"]);
        NSLog(@"Error: %@", error);
    }
}];

// Deleting a vault item
// Response is the same dictionary item from either the create, get or update method
[[CCHVault sharedInstance] deleteItem:response completionHandler:^(NSError *error) {

    if (!error) {
        NSLog(@"Successfully deleted vault item %@ on ContextHub", data[@"firstName"]);
    } else {
        NSLog(@"Could not delete vault item %@ on ContextHub", data[@"firstName"]);
        NSLog(@"Error: %@", error);
    }
}];
```

And here is what a response from create, get, and update calls looks like:
```
{
    data =     {
        firstName = Jeffrey;
        nicknames =         (
            Jeff,
            Michaelangelo
        );
        cities = {
            "New York City" = 1995;
            Austin = 2004;
            Houston = 2010;
        };
    };
    "vault_info" =     {
        "created_at" = "2014-08-07T15:55:12.747Z";
        id = "8b253f80-449c-4588-a963-7c296a7243cd";
        "tag_string" = "vault-tag, employee";
        tags =         (
            "vault-tag",
            "employee"
        );
        "updated_at" = "2014-08-07T15:55:12.747Z";
    };
}
```

That's it! Hopefully this sample application showed you how easy it is to work with vault items in ContextHub to easily store information accessible from all devices and context rules.