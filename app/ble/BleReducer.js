'use strict';

import * as ble from './BleActions'
import { Map, OrderedMap } from 'immutable'

const defaultState = Map({
  devices: OrderedMap(),
  selectedDeviceId: null,
  selectedServiceId: null,
  selectedCharacteristicId: null,
  scanning: false,
  state: ble.DEVICE_STATE_DISCONNECTED
});

export default (state = defaultState, action) => {
  switch (action.type) {
    case ble.START_SCAN:
      return state.set('scanning', true);
    case ble.STOP_SCAN:
      return state.set('scanning', false);
    case ble.DEVICE_FOUND:
      return state.mergeDeepIn(['devices', action.device.uuid], action.device);
    case ble.CHANGE_DEVICE_STATE:
      return state.withMutations(state => {
        state.set('scanning', false)
             .set('state', action.state)
             .set('selectedDeviceId', action.deviceId)
      });
    case ble.UPDATE_SERVICES:
      return state.mergeDeepIn(['devices', action.deviceId, 'services'], action.services);
    case ble.SELECT_SERVICE:
      return state.set('selectedServiceId', action.serviceId);
    case ble.UPDATE_CHARACTERISTICS:
      return state
    case ble.WRITE_CHARACTERISTIC:
      return state
    case ble.READ_CHARACTERISTIC:
      return state
    default:
      return state;
  }
}
