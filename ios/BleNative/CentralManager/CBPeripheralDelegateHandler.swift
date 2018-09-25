import Foundation
import CoreBluetooth

class CBPeripheralDelegateHandler: NSObject, CBPeripheralDelegate {
    private let centralId: Int32
    private let bufferHandler: BufferHandler
    private let requestHandler: RequestHandler
    private let notificationsHandler: NotificationsHandler
    
    init(
        centralId: Int32,
        bufferHandler: BufferHandler, 
        requestHandler: RequestHandler, 
        notificationsHandler: NotificationsHandler) {
        self.centralId = centralId
        self.bufferHandler = bufferHandler
        self.requestHandler = requestHandler
        self.notificationsHandler = notificationsHandler
        super.init()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        guard let request = requestHandler.removeRequest(relatedIdentifier: peripheralId, type: .readRssi) else {
            return
        }
        request.callback(createSuccessResult(data: RSSI.intValue))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        guard let request = requestHandler.removeRequest(relatedIdentifier: peripheralId, type: .discoverServices) else {
            return
        }
        if error != nil {
            request.callback(BleError.servicesDiscoveryFailed(peripheral.identifier).asErrorResult())
        } else {
            request.callback(peripheral.asSuccessResult(centralId: centralId))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let serviceId = ObjectIdGenerators.services.id(for: service)
        guard let request = requestHandler.removeRequest(relatedIdentifier: serviceId, type: .discoverCharacteristics) else {
            return
        }
        if error != nil {
            request.callback(BleError.characteristicsDiscoveryFailed(service.uuid).asErrorResult())
        } else {
            request.callback(peripheral.asSuccessResult(centralId: centralId))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let characteristicId = ObjectIdGenerators.characteristics.id(for: characteristic)
        if let request = requestHandler.removeRequest(relatedIdentifier: characteristicId, type: .read) {
            if error != nil {
                request.callback(BleError.characteristicReadFailed(characteristic).asErrorResult())
            } else {
                request.callback(createSuccessResult(data: characteristic.valueBase64 ?? NSNull()))
            }
        } else if error == nil {
            let updatedBuffers = bufferHandler.appendBufferElement(
                characteristic.valueBase64 ?? NSNull(),
                forType: .valueChange,
                relatedIdentifier: characteristicId
            )
            updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let characteristicId = ObjectIdGenerators.characteristics.id(for: characteristic)
        if let request = requestHandler.removeRequest(relatedIdentifier: characteristicId, type: .write) {
            if error != nil {
                request.callback(BleError.characteristicWriteFailed(characteristic).asErrorResult())
            } else {
                request.callback(createSuccessResult(data: NSNull()))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let characteristicId = ObjectIdGenerators.characteristics.id(for: characteristic)
        if let callbacks = notificationsHandler.enabledCallbacks(forId: characteristicId) {
            let data = (error == nil && characteristic.isNotifying)
                ? characteristic.asSuccessResult(centralId: centralId)
                : BleError.characteristicNotifyChangeFailed(characteristic).asErrorResult()
            callbacks.forEach { $0(data) }
            notificationsHandler.removeEnabledCallbacks(forId: characteristicId)
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        let updatedBuffers = bufferHandler.appendBufferElement(
            peripheral.name ?? NSNull(),
            forType: .name,
            relatedIdentifier: peripheralId
        )
        updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
    }
}
