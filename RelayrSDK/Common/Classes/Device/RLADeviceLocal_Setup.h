#import "RLADeviceLocal.h"      // Base class
@class CBPeripheral;
@class RLABluetoothManager;

/*!
 *  @class RLADeviceLocal
 *
 *  @abstract <code>RLADevice</code> objects are only meant to be initialised privately by the framework.
 *
 *  @see RLADeviceLocal
 */
@interface RLADeviceLocal ()

/*!
 *  @enum RLADeviceLocalState
 *
 *  @abstract The state of the current local device.
 *
 *  @constant RLADeviceLocalStateUnknown State not yet fetched or unable to fetch.
 *  @constant RLADeviceLocalStateOnboarding Device may be configured via characteristics.
 *  @constant RLADeviceLocalStateBroadcasting Device is sending data.
 */
typedef NS_ENUM(NSUInteger, RLADeviceLocalState) {
    RLADeviceLocalStateUnknown,
    RLADeviceLocalStateOnboarding,
    RLADeviceLocalStateBroadcasting
};

/*!
 *  @enum RLADeviceLocalPairing
 *
 *  @abstract The paring state of the local device.
 *
 *  @constant RLADeviceLocalPairingUnknown State not yet fetched or unable to fetch.
 *  @constant RLADeviceLocalPairingNone Only connections to master module allowed.
 *  @constant RLADeviceLocalPairingAny Any client may connect.
 */
typedef NS_ENUM(NSUInteger, RLADeviceLocalPairing) {
    RLADeviceLocalPairingUnknown,
    RLADeviceLocalPairingNone,
    RLADeviceLocalPairingAny
};

/*!
 *  @method initWithPeripheral:andListenerManager:
 *
 *  @abstract Initializes a <code>RLADevice</code> object with the required dependencies.
 *  @discussion This initialiser method is used when accessing devices directly via bluetooth.
 *
 *  @param peripheral Core Bluetooth peripheral object
 *  @param service This object provides the local device with updates for its managed peripheral.
 *	@return Newly initialised <code>RLADevice</code>.
 */
- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral andListenerManager:(RLABluetoothManager*)service;

/*!
 *  @property peripheral
 *
 *  @abstract Underlying CBPeripheral object for the local device.
 */
@property (readwrite,nonatomic) CBPeripheral* peripheral;

/*!
 *  @property relayrState
 *
 *  @abstract It returns the current state of the receiver.
 *  @discussion The current state of the receiver is:
 *      - RLALocalDeviceStateUnknown: Device allows configuration.
 *      - RLALocalDeviceStateOnboarding: Device can receive value for configuration.
 *      - RLALocalDeviceStateBroadcasting: Device is broadcasting values to eiher the master module or any connected client. Allowed connection types depend on the state of RLALocalDevicePairing.
 */
@property (readonly,nonatomic) RLADeviceLocalState relayrState;

/*!
 *  @property relayrPairing
 *
 *  @abstract It returns the current pairing settings of the receiver.
 *  @discussion The possible states are:
 *      - RLALocalDevicePairingUnknown.
 *      - RLALocalDevicePairingAllowed: Every client may connect.
 *      - RLALocalDevicePairingForbidden: Only the master module may connect.
 */
@property (readonly,nonatomic) RLADeviceLocalPairing relayrPairing;

/*!
 *  @method setRelayrPairing:completion:
 *
 *  @abstract ...
 *
 *  @param pairing RLALocalDevicePairing mode the device should be configured to use
 *  @param completion When the attempt to update the pairing mode succeeded the NSError value will be <code>nil</code>.
 */
- (void)setRelayrPairing:(RLADeviceLocalPairing)pairing completion:(void(^)(NSError*))completion;

@end
