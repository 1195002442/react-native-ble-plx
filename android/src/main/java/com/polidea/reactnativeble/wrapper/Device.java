package com.polidea.reactnativeble.wrapper;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.polidea.rxandroidble.RxBleConnection;
import com.polidea.rxandroidble.RxBleDevice;

import java.util.List;
import java.util.UUID;

public class Device extends JSObject {

    private interface Metadata {
        String ID = "id";
        String NAME = "name";
        String RSSI = "rssi";

        String MANUFACTURER_DATA = "manufacturerData";
        String SERVICE_DATA = "serviceData";
        String SERVICE_UUIDS = "serviceUUIDs";
        String TX_POWER_LEVEL = "txPowerLevel";
        String SOLICITED_SERVICE_UUIDS = "solicitedServiceUUIDs";
        String IS_CONNECTABLE = "isConnectable";
        String OVERFLOW_SERVICE_UUIDS = "overflowServiceUUIDs";
    }

    private RxBleDevice device;
    private RxBleConnection connection;
    private List<Service> services;
    private Integer lastRSSI;

    public Device(RxBleDevice device, RxBleConnection connection) {
        this.device = device;
        this.connection = connection;
    }

    public void setRSSI(Integer rssi) {
        this.lastRSSI = rssi;
    }

    public void setServices(List<Service> services) {
        this.services = services;
    }

    public List<Service> getServices() {
        return services;
    }

    public RxBleDevice getNativeDevice() {
        return device;
    }

    public RxBleConnection getConnection() {
        return connection;
    }

    public Service getServiceByUUID(UUID uuid) {
        for(Service service : services) {
            if (uuid.equals(service.getNativeService().getUuid()))
                return service;
        }
        return null;
    }

    @Override
    public WritableMap toJSObject() {
        WritableMap result = Arguments.createMap();
        result.putString(Metadata.ID, device.getMacAddress());
        result.putString(Metadata.NAME, device.getName());
        if (lastRSSI != null) {
            result.putInt(Metadata.RSSI, lastRSSI);
        } else {
            result.putNull(Metadata.RSSI);
        }

        // Advertisement data is not set
        result.putNull(Metadata.MANUFACTURER_DATA);
        result.putNull(Metadata.SERVICE_DATA);
        result.putNull(Metadata.SERVICE_UUIDS);
        result.putNull(Metadata.TX_POWER_LEVEL);
        result.putNull(Metadata.SOLICITED_SERVICE_UUIDS);
        result.putNull(Metadata.IS_CONNECTABLE);
        result.putNull(Metadata.OVERFLOW_SERVICE_UUIDS);

        return result;
    }
}
