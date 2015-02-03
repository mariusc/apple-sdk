#import "RLAAPIService.h"       // Relayr (Service/API)
@class RelayrApp;               // Relayr (Public)
@class RelayrUser;              // Relayr (Public)
@class RelayrPublisher;         // Relayr (Public)
@class RelayrTransmitter;       // Relayr (Public)
@class RelayrDevice;            // Relayr (Public)
@class RelayrDeviceModel;       // Relayr (Public)
@class RelayrFirmware;          // Relayr (Public)
@class RelayrFirmwareModel;     // Relayr (Public)

@interface RLAAPIService (Parsing)

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrApp</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrApp</code> object.
 *	@return Fully initialised <code>RelayrApp</code> or <code>nil</code>.
 *
 *  @see RelayrApp
 */
+ (RelayrApp*)parseAppFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrUser</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrUser</code> object.
 *  @return <code>RelayrUser</code> containing the bare minimum of user information.
 *
 *  @see RelayrUser
 */
+ (RelayrUser*)paraseUserFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrPublisher</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrPublisher</code> object.
 *	@return Fully initialised <code>RelayrPublisher</code> or <code>nil</code>.
 *
 *  @see RelayrPublisher
 */
+ (RelayrPublisher*)parsePublisherFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrTransmitter</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrTransmitter</code> object.
 *	@return Fully initialised <code>RelayrTransmitter</code> or <code>nil</code>.
 *
 *  @see RelayrTransmitter
 */
- (RelayrTransmitter*)parseTransmitterFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrDevice</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrDevice</code> object.
 *	@return Fully initialised <code>RelayrDevice</code> or <code>nil</code>.
 *
 *  @see RelayrDevice
 */
- (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrDeviceModel</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrDeviceModel</code> object.
 *	@return Fully initialised <code>RelayrDeviceModel</code> or <code>nil</code>.
 *
 *  @see RelayrDeviceModel
 */
- (RelayrDeviceModel*)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict
                                          inDeviceObject:(RelayrDevice*)device;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrFirmwareModel</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrFirmwareModel</code> object.
 *	@return Fully initialised <code>RelayrFirmwareModel</code> or <code>nil</code>.
 *
 *  @see RelayrFirmwareModel
 */
- (RelayrFirmwareModel*)parseFirmwareModelFromJSONDictionary:(NSDictionary*)jsonDict
                                            inFirmwareObject:(RelayrFirmware*)firmware
                                               ofDeviceModel:(RelayrDeviceModel*)deviceModel;

@end
