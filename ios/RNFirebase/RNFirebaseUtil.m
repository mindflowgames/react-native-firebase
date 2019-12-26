#import "RNFirebaseUtil.h"

@implementation RNFirebaseUtil

static NSString *const DEFAULT_APP_DISPLAY_NAME = @"[DEFAULT]";
static NSString *const DEFAULT_APP_NAME = @"__FIRAPP_DEFAULT";

+ (NSString *)getISO8601String:(NSDate *)date {
  static NSDateFormatter *formatter = nil;

  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
  }

  NSString *iso8601String = [formatter stringFromDate:date];

  return [iso8601String stringByAppendingString:@"Z"];
}

+ (FIRApp *)getApp:(NSString *)appDisplayName {
  NSString *appName = [RNFirebaseUtil getAppName:appDisplayName];
  return [FIRApp appNamed:appName];
}

+ (NSString *)getAppName:(NSString *)appDisplayName {
  if ([appDisplayName isEqualToString:DEFAULT_APP_DISPLAY_NAME]) {
    return DEFAULT_APP_NAME;
  }
  return appDisplayName;
}

+ (NSString *)getAppDisplayName:(NSString *)appName {
  if ([appName isEqualToString:DEFAULT_APP_NAME]) {
    return DEFAULT_APP_DISPLAY_NAME;
  }
  return appName;
}

+ (void)sendJSEvent:(RCTEventEmitter *)emitter name:(NSString *)name body:(id)body {
  @try {
    // TODO: Temporary fix for https://github.com/invertase/react-native-firebase/issues/233
    // until a better solution comes around
    if (emitter.bridge) {
      [emitter sendEventWithName:name body:body];
    }
  } @catch (NSException *error) {
    DLog(@"An error occurred in sendJSEvent: %@", [error debugDescription]);
  }
}

+ (void)sendJSEventWithAppName:(RCTEventEmitter *)emitter app:(FIRApp *)app name:(NSString *)name body:(id)body {
  // Add the appName to the body
  NSMutableDictionary *newBody = [body mutableCopy];
  newBody[@"appName"] = [RNFirebaseUtil getAppDisplayName:app.name];

  [RNFirebaseUtil sendJSEvent:emitter name:name body:newBody];
}

+ (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navContObj = (UINavigationController*)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController* presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        return viewController;
    }
}

@end
