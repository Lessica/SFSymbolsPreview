//
//  AppDelegate.m
//  SFSymbolsPreview
//
//  Created by YICAI YANG on 2020/5/27.
//  Copyright © 2020 YICAI YANG. All rights reserved.
//

#import "AppDelegate.h"
#import "SFSymbolDataSource.h"
#import <CoreText/CoreText.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    NSURL *fontURL = [[NSBundle mainBundle] URLForResource:@"SFSymbolsFallback" withExtension:@"ttf"];
    CTFontManagerRegisterFontURLs((__bridge CFArrayRef)@[fontURL], kCTFontManagerScopePersistent, true, ^bool(CFArrayRef  _Nonnull errors, bool done) {
#ifdef DEBUG
        if (done) {
            NSLog(@"font registered successfully");
        } else {
            NSLog(@"font registeration failed: %@", errors);
        }
#endif
        return true;
    });
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [UISceneConfiguration.alloc initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
