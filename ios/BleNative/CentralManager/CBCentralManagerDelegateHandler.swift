import Foundation
import CoreBluetooth

class CBCentralManagerDelegateHandler: NSObject, CBCentralManagerDelegate {
    private let centralId: Int32
    private let bufferHandler: BufferHandler
    private let cacheHandler: CacheHandler
    private let requestHandler: RequestHandler
    private let peripheralDelegateHandler: CBPeripheralDelegateHandler
    
    init(
        centralId: Int32,
        bufferHandler: BufferHandler, 
        cacheHandler: CacheHandler, 
        requestHandler: RequestHandler, 
        notificationsHandler: NotificationsHandler) {
        self.centralId = centralId
        self.bufferHandler = bufferHandler
        self.cacheHandler = cacheHandler
        self.requestHandler = requestHandler
        self.peripheralDelegateHandler = CBPeripheralDelegateHandler(
            centralId: centralId,
            bufferHandler: bufferHandler, 
            requestHandler: requestHandler, 
            notificationsHandler: notificationsHandler)
        super.init()
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = BleState(rawValue: central.state.rawValue) ?? .unsupported
        let updatedBuffers = bufferHandler.appendBufferElement(
            state.asSuccessResult(), 
            forType: .state
        )
        updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
        
        if state != .poweredOn {
            let error = BleError.invalidManagerState(state)
            let invalidatedBuffers = bufferHandler.markBuffersInvalidated(reason: error, exceptTypes: [.state])
            invalidateBufferRequests(invalidatedBuffers, withError: error, requestHandler: requestHandler, bufferHandler: bufferHandler)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        fillDiscoveredDataFromRestoreStateDict(dict)
        
        var resultDict: [String: Any] = [:]
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            resultDict[RestoredStateKeys.connectedPeripherals.rawValue] = peripherals.map { $0.asDataObject(centralId: centralId) }
        }
        if let scanServices = dict[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID] {
            resultDict[RestoredStateKeys.scanServices.rawValue] = scanServices.map { $0.uuidString }
        }
        if dict.keys.contains(CBCentralManagerRestoredStateScanOptionsKey) {
            resultDict[RestoredStateKeys.scanOptions.rawValue] = dict[CBCentralManagerRestoredStateScanOptionsKey]
        }
        
        let updatedBuffers = bufferHandler.appendBufferElement(
            resultDict, 
            forType: .stateRestore
        )
        updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        cacheHandler.clearForPeripheral(peripheral)
        
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        if let request = requestHandler.removeRequest(relatedIdentifier: peripheralId, type: .disconnect) {
            request.callback(peripheral.asSuccessResult(centralId: centralId))
        }
        
        let updatedBuffers = bufferHandler.appendBufferElement(
            peripheral.asSuccessResult(centralId: centralId),
            forType: .disconnect
        )
        updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
        
        let error = BleError.peripheralNotConnected(peripheral.identifier.uuidString)
        let invalidatedBuffers = bufferHandler.markBuffersInvalidated(
            reason: error, 
            relatedIdentifier: peripheralId, 
            exceptTypes: [.disconnect]
        )
        invalidateBufferRequests(invalidatedBuffers, withError: error, requestHandler: requestHandler, bufferHandler: bufferHandler)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let device = ScannedPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        let updatedBuffers = bufferHandler.appendBufferElement(
            device.asDataObject(centralId: centralId),
            forType: .scan
        )
        updateBuffersRequests(updatedBuffers, requestHandler: requestHandler, bufferHandler: bufferHandler)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        cacheHandler.clearForPeripheral(peripheral)
        
        peripheral.delegate = peripheralDelegateHandler
        
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        if let request = requestHandler.removeRequest(relatedIdentifier: peripheralId, type: .connect) {
            request.callback(peripheral.asSuccessResult(centralId: centralId))
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let peripheralId = ObjectIdGenerators.peripherals.id(for: peripheral)
        guard let request = requestHandler.removeRequest(relatedIdentifier: peripheralId, type: .connect) else {
            return
        }
        request.callback(BleError.peripheralConnectionFailed(peripheral.identifier).asErrorResult())
    }
    
    private func fillDiscoveredDataFromRestoreStateDict(_ dict: [String: Any]) {
        guard let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] else { return }
        for peripheral in peripherals {
            peripheral.delegate = peripheralDelegateHandler
            peripheral.services?.forEach({ service in
                cacheHandler.addService(service)
                service.characteristics?.forEach { cacheHandler.addCharacteristic($0) }
            })
        }
    }
}
