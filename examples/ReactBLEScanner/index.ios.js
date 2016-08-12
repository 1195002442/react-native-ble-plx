'use strict';

import React, { Component } from 'react';
import { View, AppRegistry } from 'react-native';
import { applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import createLogger from 'redux-logger';

import RootComponent from './app/root/RootComponent';
import ErrorComponent from './app/root/ErrorComponent';
import BleComponent from './app/ble/BleComponent';
import reducer from './app/root/Reducer';

import { Iterable } from 'immutable';

const stateTransformer = (state) => {
  if (Iterable.isIterable(state)) {
    return state.toJS()
  } else {
    return state;
  }
};

const logger = createLogger({ stateTransformer });
const store = createStore(reducer)

class ReactBLEScanner extends Component {
  render() {
    return (
      <Provider store={store}>
        <View style={{flex:1}}>
          <ErrorComponent/>
          <RootComponent/>
          <BleComponent/>
        </View>
      </Provider>
    );
  }
}

AppRegistry.registerComponent('ReactBLEScanner', () => ReactBLEScanner);
