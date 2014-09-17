#import "RLAWebService.h"       // Relayr.framework (Web)
@class RelayrApp;               // Relayr.framework (Public)
@class RelayrUser;              // Relayr.framework (Public)
@class RelayrPublisher;         // Relayr.framework (Public)
@class RelayrTransmitter;       // Relayr.framework (Public)
@class RelayrDevice;            // Relayr.framework (Public)

@interface RLAWebService (Parsing)

/*!
 *  @abstract Parse a JSON dictionary into a <code>RelayrUser</code> object.
 *
 *  @param jsonDict <code>NSDictionary</code> with the properties of a <code>RelayrUser</code> object.
 *	@return Fully initialised <code>RelayrUser</code> or <code>nil</code>.
 *
 *  @see RelayrUser
 */
+ (RelayrUser*)parseUserFromJSONDictionary:(NSDictionary*)jsonDict;

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

@end
