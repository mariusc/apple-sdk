#import "RLAWebService.h"       // Relayr.framework (Web)
@class RelayrApp;               // Relayr.framework (Public)
@class RelayrUser;              // Relayr.framework (Public)
@class RelayrPublisher;         // Relayr.framework (Public)
@class RelayrTransmitter;       // Relayr.framework (Public)
@class RelayrDevice;            // Relayr.framework (Public)
@class RelayrDeviceModel;       // Relayr.framework (Public)
@class RelayrFirmware;          // Relayr.framework (Public)
@class RelayrFirmwareModel;     // Relayr.framework (Public)

@interface RLAWebService (Parsing)

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
 *  @abstract Parse a JSON dictionary into a <code>RelayrApp</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrApp</code> object.
 *	@return Fully initialised <code>RelayrApp</code> or <code>nil</code>.
 *
 *  @see RelayrApp
 */
+ (RelayrApp*)parseAppFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrTransmitter</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrTransmitter</code> object.
 *	@return Fully initialised <code>RelayrTransmitter</code> or <code>nil</code>.
 *
 *  @see RelayrTransmitter
 */
+ (RelayrTransmitter*)parseTransmitterFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrDevice</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrDevice</code> object.
 *	@return Fully initialised <code>RelayrDevice</code> or <code>nil</code>.
 *
 *  @see RelayrDevice
 */
+ (RelayrDevice*)parseDeviceFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrDeviceModel</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrDeviceModel</code> object.
 *	@return Fully initialised <code>RelayrDeviceModel</code> or <code>nil</code>.
 *
 *  @see RelayrDeviceModel
 */
+ (RelayrDeviceModel*)parseDeviceModelFromJSONDictionary:(NSDictionary*)jsonDict inDeviceObject:(RelayrDevice*)device;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrFirmware</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrFirmware</code> object.
 *	@return Fully initialised <code>RelayrFirmware</code> or <code>nil</code>.
 *
 *  @see RelayrFirmware
 */
+ (RelayrFirmware*)parseFirmwareFromJSONDictionary:(NSDictionary*)jsonDict;

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrFirmwareModel</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrFirmwareModel</code> object.
 *	@return Fully initialised <code>RelayrFirmwareModel</code> or <code>nil</code>.
 *
 *  @see RelayrFirmwareModel
 */
+ (RelayrFirmwareModel*)parseFirmwareModelFromJSONDictionary:(NSDictionary*)jsonDict inFirmwareObject:(RelayrFirmware*)firmware;

@end
