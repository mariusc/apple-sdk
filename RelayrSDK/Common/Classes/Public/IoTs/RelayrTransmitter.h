@import Foundation;             // Apple
@protocol RelayrOnboarding;     // Relayr.framework (Public)
@protocol RelayrFirmwareUpdate; // Relayr.framework (Public)

/*!
 *  @abstract An instance of this class represents a relayr Transmitter. a basic entity on the relayr platform.
 *  @discussion A transmitter contrary to a device does not gather data but is only used to relay the data from the devices to the relayr platform. The transmitter is also used to authenticate the different devices that transmit data via it.
 */
@interface RelayrTransmitter : NSObject <NSCoding>

/*!
 *  @abstract A Unique idenfier for a <code>RelayrTransmitter</code> instance.
 *  @discussion This property is inmutable.
 */
@property (readonly,nonatomic) NSString* uid;

/*!
 *  @abstract Transmitter name.
 *  @discussion It can be updated or query from the server.
 */
@property (readonly,nonatomic) NSString* name;

/*!
 *  @abstract The owner ID of the specific transmitter, a relayr user.
 */
@property (readonly,nonatomic) NSString* owner;

/*!
 *  @abstract The secret for MQTT comminucation with the relayr <a href="https://developer.relayr.io/documents/Welcome/Platform">Cloud Platform</a>.
 *  @discussion It can be seen as the transmitter's password.
 */
@property (readonly,nonatomic) NSString* secret;

/*!
 *  @abstract Returns all devices related to the specific Transmitter.
 *  @discussion Links to <code>RelayrDevice</code>s owned by the <code>RelayrUser</code> which owns the Transmitter.
 *      If this property is <code>nil</code>, it indicates that the number of devices managed by this transmitter is unknown and you should query the server for more information. If this property is an empty set, the transmitter doesn't manage any device.
 */
@property (readonly,nonatomic) NSSet* devices;

/*!
 *  @abstract It sets the instance where this object is being called with the properties of the object passed as the argument.
 *  @discussion The object passed as the argument is considered new and thus the properties have more priority.
 *
 *  @param transmitter The server instance of this object.
 */
- (void)setWith:(RelayrTransmitter*)transmitter;

#pragma mark Processes

/*!
 *  @abstract Initialises a physical transmitter with the properties of this <code>RelayrTransmitter</code> entity.
 *  @discussion The onboarding process writes in physical memory of the targeted transmitter the properties needed for the device to be a full member of the Relayr Cloud.
 *
 *  @param onboardingClass Class in charge of the onboarding process. This class "knows" how to talk to the specific transmitter.
 *  @param completion Block indicating whether the onboarding process was successful or not.
 */
- (void)onboardWithClass:(Class <RelayrOnboarding>)onboardingClass completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Performs a firmware update to a specific transmitter.
 *
 *  @param updateClass Class in charge of the firmware update process. This class "knows" how to talk to the specific transmitter.
 *  @param completion Block indicating whether the update process was successful or not.
 */
- (void)updateFirmwareWithClass:(Class <RelayrFirmwareUpdate>)updateClass completion:(void (^)(NSError* error))completion;

@end
