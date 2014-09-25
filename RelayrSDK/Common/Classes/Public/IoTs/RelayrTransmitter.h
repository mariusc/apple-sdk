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

#pragma mark Processes

/*!
 *  @abstract Initialises a physical transmitter with the properties of this <code>RelayrTransmitter</code> entity.
 *  @discussion During the onboarding process the properties needed for the transmitter to be a member of the relayr cloud are written 
 *	to the physical memory of the targeted transmitter.
 *
 *  @param onboardingClass Class in charge of the onboarding process. This class "knows" how to talk to the specific transmitter.
 *  @param timeout The seconds that the onboarding process can span. If the onboarding process hasn't finished by the specified seconds, the completion block will be executed.
 *      If <code>nil</code> is passed, a timeout defined by the manufacturer is used. If a negative number is passed, then the block is returned with a proper error.
 *  @param options Specific options for the transmitter you are onboarding. The specific <code>RelayrOnboarding</code> class will list all the additional variables needed for a correct onboarding.
 *  @param completion Block indicating whether the onboarding process was successful or not.
 */
- (void)onboardWithClass:(Class <RelayrOnboarding>)onboardingClass
                 timeout:(NSNumber*)timeout
                 options:(NSDictionary*)options
              completion:(void (^)(NSError* error))completion;

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
- (void)updateFirmwareWithClass:(Class <RelayrFirmwareUpdate>)updateClass
                        timeout:(NSNumber*)timeout
                        options:(NSDictionary*)options
                     completion:(void (^)(NSError* error))completion;

@end
