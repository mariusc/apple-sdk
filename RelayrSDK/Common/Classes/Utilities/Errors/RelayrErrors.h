@import Foundation; // Apple

/*!
 *  @abstract It specifies the error domain of relayr.
 */
FOUNDATION_EXPORT NSString* const kRelayrErrorDomain;

/*!
 *  @abstract The string that contains the translation of all Relayr.framework error messages.
 */
FOUNDATION_EXPORT NSString* const kRelayrErrorStringFile;

#pragma mark Error codes

/*!
 *  @abstract Enumeration of all the error codes inside the relayr error domain.
 *
 *  @constant kRelayrErrorCodeUnknown Error Unknown.
 *  @constant kRelayrErrorCodeMissingArgument Method missing an argument.
 *  @constant kRelayrErrorCodeMissingExpectedValue Missing an expected value.
 *  @constant kRelayrErrorCodeWebRequestFailure The HTTP web request failed.
 */
typedef NS_ENUM(NSInteger, RelayrErrorCode) {
    kRelayrErrorCodeUnknown                 = 1,
    kRelayrErrorCodeMissingArgument         = 2,
    kRelayrErrorCodeMissingExpectedValue    = 3,
    kRelayrErrorCodeWebRequestFailure       = 4,
    kRelayrErrorCodeRequestParsingFailure   = 5,
    kRelayrErrorCodeSigningFailure          = 6,
    kRelayrErrorCodeSystemNotSupported      = 7,
    kRelayrErrorCodeUserStoppedProcess      = 8,
    kRelayrErrorCodeWrongRelayrUser         = 9,
    kRelayrErrorCodeTimeoutExpired          = 10,
    kRelayrErrorCodeBLEModulePoweredOff     = 20,
    kRelayrErrorCodeBLEModuleUnauthorized   = 21,
    kRelayrErrorCodeBLEUnsupported          = 22,
    kRelayrErrorCodeBLEModuleResetting      = 23,
    kRelayrErrorCodeBLEProblemUnknown       = 24
};

#define RelayrErrorUserInfoLocal   @{ \
    @"file"     : [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding], \
    @"function" : [NSString stringWithFormat:@"%i", __LINE__], \
    @"line"     : [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] }

#pragma mark Error messages

#define dRelayrErrorMessageUnknown                  NSLocalizedStringFromTable(@"An unknown error occurred.", kRelayrErrorStringFile, @"An error occurred and the procedence is unknown.")
#define dRelayrErrorMessageMissingArgument          NSLocalizedStringFromTable(@"Missing one or more arguments.", kRelayrErrorStringFile, @"It happens when a method is expecting an argument which is not there.")
#define dRelayrErrorMessageMissingExpectedValue     NSLocalizedStringFromTable(@"The value is not the expected (probably nil).", kRelayrErrorStringFile, @"It happens when a value is received and it wasn't the expected.")
#define dRelayrErrorMessageWebRequestFailure        NSLocalizedStringFromTable(@"The web request could not be satisfied.", kRelayrErrorStringFile, @"It happens when a web request could not be routed or the answer was not the expected.")
#define dRelayrErrorMessageRequestParsingFailure    NSLocalizedStringFromTable(@"The web request could not be successfully parsed.", kRelayrErrorStringFile, @"It happens when the message from the server could not be parsed.")
#define dRelayrErrorMessageSigningFailure           NSLocalizedStringFromTable(@"The OAuth user signing process failed.", kRelayrErrorStringFile, @"It happens when an OAuth signing process failed.")
#define dRelayrErrorMessageSystemNotSupported       NSLocalizedStringFromTable(@"The system your are running on doesn't support the Relayr framework.", kRelayrErrorStringFile, @"It happens when your system is not supported.")
#define dRelayrErrorMessageUserStoppedProcess       NSLocalizedStringFromTable(@"The user has stopped the current process.", kRelayrErrorStringFile, @"It happens when an user has canceled somehow the current process.")
#define dRelayrErrorMessageWrongRelayrUser          NSLocalizedStringFromTable(@"The user passed or selected is not a valid Relayr user.", kRelayrErrorStringFile, @"It occurs when trying to perform operations on an invalid Relayr user.")
#define dRelayrErrorMessageTimeoutExpired           NSLocalizedStringFromTable(@"The timeout to perform a certain task has expired.", kRelayrErrorStringFile, @"It happens when the the time ellapsed given to a specific task has been completed without the task been able to be completelly performed.")
#define dRelayrErrorMessageBLEModulePowerOff        NSLocalizedStringFromTable(@"The BLE module is powered off.", kRelayrErrorStringFile, @"It appears when trying to use the BLE module and the user has it powered off.")
#define dRelayrErrorMessageBLEModuleUnauthorized    NSLocalizedStringFromTable(@"The application is not authorised to use the BLE module.", kRelayrErrorStringFile, @"It happens when the application tries to use the Bluetooth module and the user has actively unathorise the application.")
#define dRelayrErrorMessageBLEUnupported            NSLocalizedStringFromTable(@"The current system doesn't support Bluetooth Low Energy.", kRelayrErrorStringFile, @"It happens when the system running the SDK doesn't have a BLE transceiver.")
#define dRelayrErrorMessageBLEModuleResetting       NSLocalizedStringFromTable(@"The BLE module is being resetted.", kRelayrErrorStringFile, @"It happens when the BLE is being resetted by the system or the user.")
#define dRelayrErrorMessageBLEProblemUnknwon        NSLocalizedStringFromTable(@"BLE error unknown.", kRelayrErrorStringFile, @"There was a problem with the BLE Module, but it is unknown.")

#pragma mark Error objects

#define RelayrErrorUnknwon                  [RelayrErrors errorWithCode:kRelayrErrorCodeUnknown localizedDescription:dRelayrErrorMessageUnknown userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorMissingArgument          [RelayrErrors errorWithCode:kRelayrErrorCodeMissingArgument localizedDescription:dRelayrErrorMessageMissingArgument userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorMissingExpectedValue     [RelayrErrors errorWithCode:kRelayrErrorCodeMissingExpectedValue localizedDescription:dRelayrErrorMessageMissingExpectedValue userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorWebRequestFailure        [RelayrErrors errorWithCode:kRelayrErrorCodeWebRequestFailure localizedDescription:dRelayrErrorMessageWebRequestFailure userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorRequestParsingFailure    [RelayrErrors errorWithCode:kRelayrErrorCodeRequestParsingFailure localizedDescription:dRelayrErrorMessageRequestParsingFailure userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorSigningFailure           [RelayrErrors errorWithCode:kRelayrErrorCodeSigningFailure localizedDescription:dRelayrErrorMessageSigningFailure userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorSystemNotSupported       [RelayrErrors errorWithCode:kRelayrErrorCodeSystemNotSupported localizedDescription:dRelayrErrorMessageSystemNotSupported userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorUserStoppedProcess       [RelayrErrors errorWithCode:kRelayrErrorCodeUserStoppedProcess localizedDescription:dRelayrErrorMessageUserStoppedProcess userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorWrongRelayrUser          [RelayrErrors errorWithCode:kRelayrErrorCodeWrongRelayrUser localizedDescription:dRelayrErrorMessageWrongRelayrUser userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorTimeoutExpired           [RelayrErrors errorWithCode:kRelayrErrorCodeTimeoutExpired localizedDescription:dRelayrErrorMessageTimeoutExpired userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorBLEModulePowerOff        [RelayrErrors errorWithCode:kRelayrErrorCodeBLEModulePoweredOff localizedDescription:dRelayrErrorMessageBLEModulePowerOff userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorBLEModuleUnauthorized    [RelayrErrors errorWithCode:kRelayrErrorCodeBLEModuleUnauthorized localizedDescription:dRelayrErrorMessageBLEModuleUnauthorized userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorBLEModuleResetting       [RelayrErrors errorWithCode:kRelayrErrorCodeBLEModuleResetting localizedDescription:dRelayrErrorMessageBLEModuleResetting userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorBLEUnsupported           [RelayrErrors errorWithCode:kRelayrErrorCodeBLEUnsupported localizedDescription:dRelayrErrorMessageBLEUnupported userInfo:RelayrErrorUserInfoLocal]
#define RelayrErrorBLEProblemUnknown        [RelayrErrors errorWithCode:kRelayrErrorCodeBLEProblemUnknown localizedDescription:dRelayrErrorMessageBLEProblemUnknwon userInfo:RelayrErrorUserInfoLocal]

/*!
 *  @abstract Utility class which provides convenience methods for initializing errors as well as internal framework error codes.
 */
@interface RelayrErrors : NSObject

/*!
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined <code>RelayrErrorCode</code> for the error.
 *  @param localizedDescription Localised string with the description of the error.
 *  @param userInfo A dictionary of information for the error. This parameter may be <code>nil</code>.
 *	@return An <code>NSError</code> object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RelayrErrorCode
 */
+ (NSError*)errorWithCode:(RelayrErrorCode)code
     localizedDescription:(NSString*)localizedDescription
                 userInfo:(NSDictionary*)userInfo;

/*!
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined RelayrErrorCode for the error.
 *  @param localizedDescription Localised string with the description of the error.
 *  @param failureReason A string specifying the reason for the failure.
 *	@return An NSError object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RelayrErrorCode
 */
+ (NSError*)errorWithCode:(RelayrErrorCode)code
     localizedDescription:(NSString*)localizedDescription
            failureReason:(NSString*)failureReason
                 userInfo:(NSDictionary*)userInfo;

@end
