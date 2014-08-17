# Storage (Vault) Sample app

The Storage sample app that introduces you to the vault features of the ContextHub iOS SDK.

### Table of Contents

1. **[Purpose](#purpose)**
2. **[ContextHub Use Case](#contexthub-use-case)**
3. **[Background](#background)**
4. **[Getting Started](#getting-started)**
5. **[Running the Sample App](#running-the-sample-app)**
6. **[Developer Portal](#developer-portal)**
7. **[Xcode Console](#xcode-console)**
8. **[Sample Code](#sample-code)**
9. **[Usage](#usage)**
  - **[Creating a Vault Item](#creating-a-beacon)**
  - **[Retrieving Vault Items by Tag](#retrieving-vault-items-by-tag)**
  - **[Retrieving Vault Items by KeyPath](#retrieving-vault-items-by-keypath)**
  - **[Retrieving a Vault Item by ID](#retrieving-vault-items-by-id)**
  - **[Updating a Vault Item](#updating-a-vault-item)**
  - **[Deleting a Vault Item](#deleting-a-vault-item)**
  - **[Response](#response)**
10. **[Final Words](#final-words)**

## Purpose

This sample application will show you how to create, retrieve, update, delete (CRUD) and perform key path vault search on vault items  in ContextHub.

## ContextHub Use Case

In this sample application, we use ContextHub to CRUD vault items on the server then list them in a simple UITableView. ContextHub allows you to store small amounts of data on the server which can be accessed by all devices without starting up your own database server.

## Background

The "vault" in ContextHub allows developers to store JSON-compliant data structures on a server to be accessed by all devices with your app and most importantly context rules. Data stored in the vault can be simple key-values as well as nested structures of arrays and dictionaries. It is important to note that "vault" is not a relational database and is not meant to store millions of records that need relational queries performed on them, a proper database is still necessary for those kinds of scenarios.

## Getting Started

1. Get started by either forking or cloning the Storage repo. Visit [GitHub Help](https://help.github.com/articles/fork-a-repo) if you need help.
2. Go to [ContextHub](http://app.contexthub.com) and create a new DetectMe application.
3. Find the app id associated with the application you just created. Its format looks something like this: `13e7e6b4-9f33-4e97-b11c-79ed1470fc1d`.
4. Open up your Xcode project and put the app id into the `[ContextHub registerWithAppId:]` method call.
5. Build and run the project on your device.
6. You should see a blank table view (as no vault items have been entered yet!)

## Running the Sample App

1. In the app, tap the "+" button, to create a new vault item. Enter values for each item then tap "Done". 
2. Your vault item should now appear in the table showing that it's now present on the server as well.
3. Enter either the first or last name in the search bar to find a record with that value (needs to be entered exactly).

## Developer Portal

1. In the [developer portal](http://app.contexthub.com), go to "Vault" and click on the item you just created.
2. You should now see the JSON-representation of your data present on the server. Go ahead and change a value now (changes that are not JSON-compliant will not be saved).
3. Stop and restart the app to see the change reflected!


## Xcode Console

1. This sample app will log responses from the CCHVault class of the ContextHub iOS SDK as you create, retrieve, update, delete and search for vault items in the app. Use shortcut `Shift-⌘-Y` if your console is not already visible. 
2. You should see the message "CCH: Device has successfully registered your application ID with ContextHub".
3. Use the logged statements to get an idea of the structures returned from each of these API calls to become more familiar with them.

## Sample Code

In this sample, most of the important code that deals with CRUDing vault items occurs in `StorListVaultItemController.m` and `StorEditVaultItemController.m` similar to above. Each method goes though a single operation you'll need to use `CCHVault`. `CCHVault` expects JSON-compliant dictionaries so they can be serialized when stored in vault on ContextHub. `StorVaultItem` contains the properties we want to store.

## Usage

##### Creating a Vault Item
```objc
// Creating a vault item with a firstName of "Jeffrey", a few nicknames, and cities lived in with years associated with them
// Data must be JSON-serializable in order to be saved (or otherwise converted into strings then have the response coded back)
// Our custom properties (int, float, string, array, dictionary)
NSDictionary *item = @{@"firstName": @"Jeffrey", @"ageInYears":[NSString stringWithFormat:@"%ld", (long)25], @"heightInFeet":[NSString stringWithFormat:@"%.2f", 6.25f], @"nicknames":@[@"Jeff", @"Michaelangelo"], @"cities": @{@"New York City":@"1995", @"Austin":@"2004", @"Houston":@"2010"}}; 
[[CCHVault sharedInstance] createItem:item tags:@"vault-tag" completionHandler:^(NSDictionary *response, NSError *error) {

    if (!error) {
        // Log the response
        NSLog(@"[CCHVault createItem: tags: completionHandler:] response: %@", response);
        
        // Accessing our saved data in the response
        NSString *firstName = [response valueForKeyPath:@"data.firstName"];
        NSArray *nicknames = [response valueForKeyPath:@"data.nicknames"];
        NSDictionary *cities = [response valueForKeyPath:@"data.cities"];

        // Since raw numbers are not JSON-serializable, they must be converted from strings
        NSString *ageInYearsString = [response valueForKeyPath:@"data.ageInYears"];
        NSInteger ageInYears = [ageString intValue];
        NSString *heightString = [response valueForKeyPath:@"data.heightInFeet"];
        CGFloat heightInFeet = [heightString floatValue];

        // Accessing vault_info in the response
        NSString *vaultID = [response valueForKeyPath:@"vault_info.id"];
        NSArray *tags = [response valueForKeyPath:@"vault_info.tags"];
        
        // Create a date formatter that will interpret ISO 8601 timestamps
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
```

##### Retrieving Vault Items by Tag
```objc
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
```

##### Retrieving Vault Items by KeyPath
```objc
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
```

##### Retrieving Vault Items by ID
```objc
// Getting a vault item with a specific ID
NSString *vaultID = @"41D8C25F-0464-41C5-A2E3-AAC234F240E4";
[[CCHVault sharedInstance] getVaultItemWithId:vaultID competionHandler:^(NSDictionary *response, NSError *error) {
    
    if (!error) {
        NSLog(@"Name: %@", [response valueForKeyPath:@"data.firstName"]);
    } else {
        NSLog(@"Could not get vault item from ContextHub");
    }
}];
```

##### Updating a Vault Item
```objc
// Updating a vault item with the first name "Michael" and adding the tag "employee"
// Update *replaces* a vault record with new contents so you must have a copy of the previous record if you want to make a change to a single value
// Response is the same dictionary item from either the create or get method
NSMutableDictionary *data = [response mutableCopy];
data[@"firstName"] = @"Michael";
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
```

##### Deleting a Vault Item
```objc
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

##### Response
And here is what a response from create, get, and update calls looks like:
```
{
    data =     {
        firstName = Jeffrey;
        ageInYears = 25;
        heightInFeet = "6.25";
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

##### Final Words
That's it! Hopefully this sample application showed you how easy it is to work with vault items in ContextHub to easily store information accessible from all devices and context rules.