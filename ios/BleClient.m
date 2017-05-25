//
//  BleClient.m
//  BleClient
//
//  Created by Przemysław Lenart on 27/07/16.
//  Copyright © 2016 Polidea. All rights reserved.
//

#import "BleClient.h"
@import BleClientManager;

@interface BleModule () <BleClientManagerDelegate>
@property(nonatomic) BleClientManager* manager;
@end

@implementation BleModule

@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE(BleClientManager);

- (void)dispatchEvent:(NSString * _Nonnull)name value:(id _Nonnull)value {
    [self sendEventWithName:name body:value];
}

- (NSArray<NSString *> *)supportedEvents {
    return BleEvent.events;
}

- (NSDictionary<NSString *,id> *)constantsToExport {
    NSMutableDictionary* consts = [NSMutableDictionary new];
    for (NSString* event in BleEvent.events) {
        [consts setValue:event forKey:event];
    }
    return consts;
}

RCT_EXPORT_METHOD(createClient) {
    _manager = [[BleClientManager alloc] initWithQueue:self.methodQueue];
    _manager.delegate = self;
}

RCT_EXPORT_METHOD(destroyClient) {
    [_manager invalidate];
    _manager = nil;
}

- (void)invalidate {
    [self destroyClient];
}

// Mark: Monitoring state ----------------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(   state:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager state:resolve
             reject:reject];
}

// Mark: Scanning ------------------------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(startDeviceScan:(NSArray*)filteredUUIDs
                          options:(NSDictionary*)options) {
    [_manager startDeviceScan:filteredUUIDs options:options];
}

RCT_EXPORT_METHOD(stopDeviceScan) {
    [_manager stopDeviceScan];
}

// Mark: Connection management -----------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(connectToDevice:(NSString*)deviceIdentifier
                          options:(NSDictionary*)options
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager connectToDevice:deviceIdentifier
                      options:options
                      resolve:resolve
                       reject:reject];
}

RCT_EXPORT_METHOD(cancelDeviceConnection:(NSString*)deviceIdentifier
                                resolver:(RCTPromiseResolveBlock)resolve
                                rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager cancelDeviceConnection:deviceIdentifier
                             resolve:resolve
                              reject:reject];
}

RCT_EXPORT_METHOD(isDeviceConnected:(NSString*)deviceIdentifier
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager isDeviceConnected:deviceIdentifier
                        resolve:resolve
                         reject:reject];
}

// Mark: Discovery -----------------------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(discoverAllServicesAndCharacteristicsForDevice:(NSString*)deviceIdentifier
                                                        resolver:(RCTPromiseResolveBlock)resolve
                                                        rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager discoverAllServicesAndCharacteristicsForDevice:deviceIdentifier
                                                     resolve:resolve
                                                      reject:reject];
}

// Mark: Service and characteristic getters ----------------------------------------------------------------------------

RCT_EXPORT_METHOD(servicesForDevice:(NSString*)deviceIdentifier
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager servicesForDevice:deviceIdentifier
                        resolve:resolve
                         reject:reject];
}

RCT_EXPORT_METHOD(characteristicsForDevice:(NSString*)deviceIdentifier
                               serviceUUID:(NSString*)serviceUUID
                                  resolver:(RCTPromiseResolveBlock)resolve
                                  rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager characteristicsForDevice:deviceIdentifier
                           serviceUUID:serviceUUID
                               resolve:resolve
                                reject:reject];
}

RCT_EXPORT_METHOD(characteristicsForService:(NSNumber*)serviceIdentifier
                                   resolver:(RCTPromiseResolveBlock)resolve
                                   rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager characteristicsForService:serviceIdentifier
                                resolve:resolve
                                 reject:reject];
}

// Mark: Characteristics operations ------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(readCharacteristicForDevice:(NSString*)deviceIdentifier
                                  serviceUUID:(NSString*)serviceUUID
                           characteristicUUID:(NSString*)characteristicUUID
                                transactionId:(NSString*)transactionId
                                     resolver:(RCTPromiseResolveBlock)resolve
                                     rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager readCharacteristicForDevice:deviceIdentifier
                              serviceUUID:serviceUUID
                       characteristicUUID:characteristicUUID
                            transactionId:transactionId
                                  resolve:resolve
                                   reject:reject];
}

RCT_EXPORT_METHOD(readCharacteristicForService:(NSNumber*)serviceIdentifier
                            characteristicUUID:(NSString*)characteristicUUID
                                 transactionId:(NSString*)transactionId
                                      resolver:(RCTPromiseResolveBlock)resolve
                                      rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager readCharacteristicForService:serviceIdentifier
                        characteristicUUID:characteristicUUID
                             transactionId:transactionId
                                   resolve:resolve
                                    reject:reject];
}

RCT_EXPORT_METHOD(readCharacteristic:(NSNumber*)characteristicIdentifier
                       transactionId:(NSString*)transactionId
                            resolver:(RCTPromiseResolveBlock)resolve
                            rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager readCharacteristic:characteristicIdentifier
              characteristicUUID:characteristicUUID
                   transactionId:transactionId
                         resolve:resolve
                          reject:reject];
}

RCT_EXPORT_METHOD(writeCharacteristicForDevice:(NSString*)deviceIdentifier
                                   serviceUUID:(NSString*)serviceUUID
                            characteristicUUID:(NSString*)characteristicUUID
                                   valueBase64:(NSString*)valueBase64
                                  withResponse:(BOOL)response
                                 transactionId:(NSString*)transactionId
                                      resolver:(RCTPromiseResolveBlock)resolve
                                      rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager writeCharacteristicForDevice:deviceIdentifier
                               serviceUUID:serviceUUID
                        characteristicUUID:characteristicUUID
                               valueBase64:valueBase64
                                  response:response
                             transactionId:transactionId
                                   resolve:resolve
                                    reject:reject];
}

RCT_EXPORT_METHOD(writeCharacteristicForService:(NSNumber*)serviceIdentifier
                             characteristicUUID:(NSString*)characteristicUUID
                                    valueBase64:(NSString*)valueBase64
                                   withResponse:(BOOL)response
                                  transactionId:(NSString*)transactionId
                                       resolver:(RCTPromiseResolveBlock)resolve
                                       rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager writeCharacteristicForService:serviceIdentifier
                         characteristicUUID:characteristicUUID
                                valueBase64:valueBase64
                                   response:response
                              transactionId:transactionId
                                    resolve:resolve
                                     reject:reject];
}

RCT_EXPORT_METHOD(writeCharacteristic:(NSNumber*)characteristicIdentifier
                          valueBase64:(NSString*)valueBase64
                         withResponse:(BOOL)response
                        transactionId:(NSString*)transactionId
                             resolver:(RCTPromiseResolveBlock)resolve
                             rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager writeCharacteristic:characteristicIdentifier
                      valueBase64:valueBase64
                         response:response
                    transactionId:transactionId
                          resolve:resolve
                           reject:reject];
}

RCT_EXPORT_METHOD(monitorCharacteristicForDevice:(NSString*)deviceIdentifier
                                     serviceUUID:(NSString*)serviceUUID
                              characteristicUUID:(NSString*)characteristicUUID
                                   transactionID:(NSString*)transactionId
                                        resolver:(RCTPromiseResolveBlock)resolve
                                        rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager monitorCharacteristicForDevice:deviceIdentifier
                                 serviceUUID:serviceUUID
                          characteristicUUID:characteristicUUID
                               transactionId:transactionId
                                     resolve:resolve
                                      reject:reject];
}

RCT_EXPORT_METHOD(monitorCharacteristicForService:(NSNumber*)serviceIdentifier
                               characteristicUUID:(NSString*)characteristicUUID
                                    transactionID:(NSString*)transactionId
                                         resolver:(RCTPromiseResolveBlock)resolve
                                         rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager monitorCharacteristicForService:serviceIdentifier
                           characteristicUUID:characteristicUUID
                                transactionId:transactionId
                                      resolve:resolve
                                       reject:reject];
}

RCT_EXPORT_METHOD(monitorCharacteristic:(NSNumber*)characteristicIdentifier
                          transactionID:(NSString*)transactionId
                               resolver:(RCTPromiseResolveBlock)resolve
                               rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager monitorCharacteristic:characteristicIdentifier
                      transactionId:transactionId
                            resolve:resolve
                             reject:reject];
}

// Mark: Other operations ----------------------------------------------------------------------------------------------

RCT_EXPORT_METHOD(cancelTransaction:(NSString*)transactionId) {
    [_manager cancelTransaction:transactionId];
}

RCT_EXPORT_METHOD(setLogLevel:(NSString*)logLevel) {
    [_manager setLogLevel:logLevel]
}

RCT_EXPORT_METHOD(logLevel:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [_manager logLevel:resolve
                reject:reject];
}

@end
