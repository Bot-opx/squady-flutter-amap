//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<amap_flutter_map_plus/AMapFlutterMapPlugin.h>)
#import <amap_flutter_map_plus/AMapFlutterMapPlugin.h>
#else
@import amap_flutter_map_plus;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AMapFlutterMapPlugin registerWithRegistrar:[registry registrarForPlugin:@"AMapFlutterMapPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
}

@end
