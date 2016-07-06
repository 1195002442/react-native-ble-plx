//
//  BleModuleBridge.m
//  EmptyProject
//
//  Created by Konrad Rodzik on 7/4/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(BleClientManager, NSObject)

RCT_EXTERN_METHOD(createClient)
RCT_EXTERN_METHOD(scanBleDevices:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(stopScanBleDevices)

RCT_EXTERN_METHOD(establishConnection:(NSString*)deviceIdentifier resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseResolveBlock)reject)


//RCT_REMAP_METHOD(establishConnection,
//                 identifier:(NSString*)deviceIdentifier
//                 resolver:(RCTPromiseResolveBlock)resolve
//                 rejecter:(RCTPromiseRejectBlock)reject)
//{
//  if(1) {
//    resolve(@(YES));
//  } else {
//    reject(@"1", @"2", nil);
//  }
//}

@end