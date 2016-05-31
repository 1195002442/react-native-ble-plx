/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
    Component,
} from 'react';
import {
    AppRegistry,
    Image,
    ListView,
    StyleSheet,
    Text,
    View,
    NativeModules,
    DeviceEventEmitter,
    Subscribable,
    TouchableNativeFeedback
} from 'react-native';
const ToastModule = NativeModules.TestBLEModule;
const RxBleClient = NativeModules.RxBleClient;

var array = [];

var arrayCount = 0;
var REQUEST_URL = 'https://raw.githubusercontent.com/facebook/react-native/master/docs/MoviesExample.json';
class ReactNativeTest extends Component {
    constructor(props) {
        super(props);
        this.renderTest = this.renderTest.bind(this);
        this._onPressButton = this._onPressButton.bind(this);
        this.state = {
            dataSource: new ListView.DataSource({
                rowHasChanged: (row1, row2) => row1 !== row2,
            }),
            loaded: false,
        };
    }

    componentWillMount() {
        DeviceEventEmitter.addListener('BLE_SCAN_RESULT', (e) => {
            array[arrayCount] = e.BLE_DEVICE.MAC_ADDRESS;
            arrayCount = arrayCount + 1;
            this.setState({
                dataSource: this.state.dataSource.cloneWithRows(array),
                loaded: true,
            });
        });
    }


    componentDidMount() {
        ToastModule.pingEvent("costam");
        RxBleClient.createContext((b) => {
            RxBleClient.scanBleDevices();
        });
        // this.ping();
        // this.fetchData();
    }

    fetchData() {
        fetch(REQUEST_URL)
            .then((response) => response.json())
            .then((responseData) => {
                this.setState({
                    dataSource: this.state.dataSource.cloneWithRows(responseData.movies),
                    loaded: true,
                });
            })
            // .then(() => ToastModule.ping("Myk", (msg) => ToastModule.show(msg, ToastModule.SHORT)))
            .done();
    }



    render() {
        // if (!this.state.loaded) {
        //     return this.renderLoadingView();
        // }

        return ( < ListView dataSource = {
                this.state.dataSource
            }
            renderRow = {this.renderTest}
            style = {
                styles.listView
            }
            />
        );
    }
    renderTest(text) {
        return (
          <TouchableNativeFeedback
          onPress = {
              () => this._onPressButton(text)
          }
          background = {
              TouchableNativeFeedback.SelectableBackground()
          }>
            <View><Text>{text}</Text></View>
          </TouchableNativeFeedback>
      )
    }
    renderLoadingView() {
        return ( < View style = {
                styles.container
            } >
            < Text >
            Loading movies... < /Text> < /View >
        );
    }
    _onPressButton(text){
        ToastModule.justLogE(text);
        this.asyncConnect(text);
    }

    async asyncConnect(text) {
        try {
            var response = await  RxBleClient.establishConnection(text, false);
            ToastModule.show(JSON.stringify(response), ToastModule.SHORT);
        } catch (e) {
            ToastModule.show(e.code, ToastModule.SHORT);
        }
    }
    renderMovie(movie) {
        return ( < View style = {
                    styles.container
                } >
                < Image source = {
                    {
                        uri: movie.posters.thumbnail
                    }
                }
                style = {
                    styles.thumbnail
                }
                /> < View style = {
                styles.rightContainer
            } >
            < Text style = {
                styles.title
            } > {
                movie.title
            } < /Text> < Text style = {
        styles.year
    } > {
        movie.year
    } < /Text> < /View > < /View>
);
}
}
var styles = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    rightContainer: {
        flex: 1,
    },
    title: {
        fontSize: 20,
        marginBottom: 8,
        textAlign: 'center',
    },
    year: {
        textAlign: 'center',
    },
    thumbnail: {
        width: 53,
        height: 81,
    },
    listView: {
        paddingTop: 20,
        backgroundColor: '#F5FCFF',
    },
});

AppRegistry.registerComponent('EmptyProject', () => ReactNativeTest);
