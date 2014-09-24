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
 *  If this property is <code>nil</code>, it indicates that the number of devices managed by this transmitter 
 *	is unknown and that the server should be queried for more information. 
 *	If this property is an empty set, the transmitter doesn't manage any devices.
 */
@property (readonly,nonatomic) NSSet* devices;

/*!
 *  @abstract Sets the instance where this object is being called for, with the properties of the object being passed as arguments.
 *  @discussion The properties being passed as the arguments are considered new and thus have a higher priority.
 *
 *  @param transmitter The server instance of this object.
 */
- (void)setWith:(RelayrTransmitter*)transmitter;

#pragma mark Processes

/*!
 *  @abstract Initialises a physical transmitter with the properties of this <code>RelayrTransmitter</code> entity.
 *  @discussion During the onboarding process the properties needed for the transmitter to be a member of the relayr cloud are written 
 *	to the physical memory of the targeted transmitter.
 *
 *  @param onboardingClass In charge of the onboarding process. This class "knows" how to communicate with the specific transmitter.
 *  @param timeout The period that the onboarding process can take in seconds. 
 *	If the onboarding process doesn't finish within the specified timeout, the completion block is executed.
 *      If <code>nil</code> is passed, a timeout defined by the manufacturer is used. 
 *	If a negative number is passed, the block is returned with a respective error.
 *  @param options Specific options for the device onboarded. The specific <code>RelayrOnboarding</code> class will list all additional variables required for a successful onboarding.
 *  @param completion A Block indicating whether the onboarding process was successful or not.
 */
- (void)onboardWithClass:(Class <RelayrOnboarding>)onboardingClass timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract Performs a firmware update on the specific transmitter.
 *
 *  @param updateClass In charge of the firmware update process. This class "knows" how to communicate with the specific transmitter.
 *  @param timeout The period that the onboarding process can take in seconds. 
 *	If the onboarding process doesn't finish within the specified timeout, the completion block is executed.
 *      If <code>nil</code> is passed, a timeout defined by the manufacturer is used. 
 *	If a negative number is passed, the block is returned with a respective error.
 *  @param options Specific options for the device you are updating. The specific <code>RelayrFirmwareUpdate</code> class will list all additional variables required for a successful firmware update.
 *  @param completion A Block indicating whether the update process was successful or not.
 */
- (void)updateFirmwareWithClass:(Class <RelayrFirmwareUpdate>)updateClass timeout:(NSNumber*)timeout options:(NSDictionary*)options completion:(void (^)(NSError* error))completion;

@end
