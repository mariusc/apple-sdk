@import Foundation; // Apple

/*!
 *  @abstract It specifies the error domain of relayr.
 */
FOUNDATION_EXPORT NSString* const kRLAErrorDomain;

/*!
 *  @abstract The string that contains the translation of all Relayr.framework error messages.
 */
FOUNDATION_EXPORT NSString* const kRLAErrorStringFile;

#pragma mark Error codes

/*!
 *  @abstract Enumeration of all the error codes inside the relayr error domain.
 *
 *  @constant kRLAErrorCodeUnknown Error Unknown.
 *  @constant kRLAErrorCodeMissingArgument Method missing an argument.
 *  @constant kRLAErrorCodeMissingExpectedValue Missing an expected value.
 *  @constant kRLAErrorCodeWebRequestFailure The HTTP web request failed.
 */
typedef NS_ENUM(NSInteger, RLAErrorCode) {
    kRLAErrorCodeUnknown                = 1,
    kRLAErrorCodeMissingArgument        = 2,
    kRLAErrorCodeMissingExpectedValue   = 3,
    kRLAErrorCodeWebRequestFailure      = 4,
    kRLAErrorCodeRequestParsingFailure  = 5,
    kRLAErrorCodeSigningFailure         = 6,
    kRLAErrorCodeSystemNotSupported     = 7,
    kRLAErrorCodeUserStoppedProcess     = 8,
    kRLAErrorCodeWrongRelayrUser        = 9,
    kRLAErrorCodeBLEModulePoweredOff    = 20,
    kRLAErrorCodeBLEModuleUnauthorized  = 21,
    kRLAErrorCodeBLEUnsupported         = 22,
    kRLAErrorCodeBLEModuleResetting     = 23,
    kRLAErrorCodeBLEProblemUnknown      = 24
};

#define RLAErrorUserInfoLocal   @{                                                                      \
        @"file"     : [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding],              \
        @"function" : [NSString stringWithFormat:@"%i", __LINE__],                                      \
        @"line"     : [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]    }

#pragma mark Error messages

#define dRLAErrorMessageMissingArgument         NSLocalizedStringFromTable(@"Missing one or more arguments", kRLAErrorStringFile, @"It happens when a method is expecting an argument which is not there.")
#define dRLAErrorMessageMissingExpectedValue    NSLocalizedStringFromTable(@"The value is not the expected (probably nil)", kRLAErrorStringFile, @"It happens when a value is received and it wasn't the expected.")
#define dRLAErrorMessageWebRequestFailure       NSLocalizedStringFromTable(@"The web request could not be satisfied", kRLAErrorStringFile, @"It happens when a web request could not be routed or the answer was not the expected.")
#define dRLAErrorMessageRequestParsingFailure   NSLocalizedStringFromTable(@"The web request could not be successfully parsed", kRLAErrorStringFile, @"It happens when the message from the server could not be parsed.")
#define dRLAErrorMessageSigningFailure          NSLocalizedStringFromTable(@"The OAuth user signing process failed.", kRLAErrorStringFile, @"It happens when an OAuth signing process failed.")
#define dRLAErrorMessageSystemNotSupported      NSLocalizedStringFromTable(@"The system your are running on doesn't support the Relayr framework.", kRLAErrorStringFile, @"It happens when your system is not supported")
#define dRLAErrorMessageUserStoppedProcess      NSLocalizedStringFromTable(@"The user has stopped the current process.", kRLAErrorStringFile, @"It happens when an user has canceled somehow the current process.")
#define dRLAErrorMessageWrongRelayrUser         NSLocalizedStringFromTable(@"The user passed or selected is not a valid Relayr user.", kRLAErrorStringFile, @"It occurs when trying to perform operations on an invalid Relayr user.")
#define dRLAErrorMessageBLEModulePowerOff       NSLocalizedStringFromTable(@"The BLE module is powered off", kRLAErrorStringFile, @"It appears when trying to use the BLE module and the user has it powered off")
#define dRLAErrorMessageBLEModuleUnauthorized   NSLocalizedStringFromTable(@"The application is not authorised to use the BLE module", kRLAErrorStringFile, @"It happens when the application tries to use the Bluetooth module and the user has actively unathorise the application")
#define dRLAErrorMessageBLEUnupported           NSLocalizedStringFromTable(@"The current system doesn't support Bluetooth Low Energy", kRLAErrorStringFile, @"It happens when the system running the SDK doesn't have a BLE transceiver")
#define dRLAErrorMessageBLEModuleResetting      NSLocalizedStringFromTable(@"The BLE module is being resetted", kRLAErrorStringFile, @"It happens when the BLE is being resetted by the system or the user")
#define dRLAErrorMessageBLEProblemUnknwon       NSLocalizedStringFromTable(@"BLE error unknown", kRLAErrorStringFile, @"There was a problem with the BLE Module, but it is unknown")

#pragma mark Error objects

#define RLAErrorMissingArgument         [RLAError errorWithCode:kRLAErrorCodeMissingArgument localizedDescription:dRLAErrorMessageMissingArgument userInfo:RLAErrorUserInfoLocal]
#define RLAErrorMissingExpectedValue    [RLAError errorWithCode:kRLAErrorCodeMissingExpectedValue localizedDescription:dRLAErrorMessageMissingExpectedValue userInfo:RLAErrorUserInfoLocal]
#define RLAErrorWebRequestFailure       [RLAError errorWithCode:kRLAErrorCodeWebRequestFailure localizedDescription:dRLAErrorMessageWebRequestFailure userInfo:RLAErrorUserInfoLocal]
#define RLAErrorRequestParsingFailure   [RLAError errorWithCode:kRLAErrorCodeRequestParsingFailure localizedDescription:dRLAErrorMessageRequestParsingFailure userInfo:RLAErrorUserInfoLocal]
#define RLAErrorSigningFailure          [RLAError errorWithCode:kRLAErrorCodeSigningFailure localizedDescription:dRLAErrorMessageSigningFailure userInfo:RLAErrorUserInfoLocal]
#define RLAErrorSystemNotSupported      [RLAError errorWithCode:kRLAErrorCodeSystemNotSupported localizedDescription:dRLAErrorMessageSystemNotSupported userInfo:RLAErrorUserInfoLocal]
#define RLAErrorUserStoppedProcess      [RLAError errorWithCode:kRLAErrorCodeUserStoppedProcess localizedDescription:dRLAErrorMessageUserStoppedProcess userInfo:RLAErrorUserInfoLocal]
#define RLAErrorWrongRelayrUser         [RLAError errorWithCode:kRLAErrorCodeWrongRelayrUser localizedDescription:dRLAErrorMessageWrongRelayrUser userInfo:RLAErrorUserInfoLocal]
#define RLAErrorBLEModulePowerOff       [RLAError errorWithCode:kRLAErrorCodeBLEModulePoweredOff localizedDescription:dRLAErrorMessageBLEModulePowerOff userInfo:RLAErrorUserInfoLocal]
#define RLAErrorBLEModuleUnauthorized   [RLAError errorWithCode:kRLAErrorCodeBLEModuleUnauthorized localizedDescription:dRLAErrorMessageBLEModuleUnauthorized userInfo:RLAErrorUserInfoLocal]
#define RLAErrorBLEModuleResetting      [RLAError errorWithCode:kRLAErrorCodeBLEModuleResetting localizedDescription:dRLAErrorMessageBLEModuleResetting userInfo:RLAErrorUserInfoLocal]
#define RLAErrorBLEUnsupported          [RLAError errorWithCode:kRLAErrorCodeBLEUnsupported localizedDescription:dRLAErrorMessageBLEUnupported userInfo:RLAErrorUserInfoLocal]
#define RLAErrorBLEProblemUnknown       [RLAError errorWithCode:kRLAErrorCodeBLEProblemUnknown localizedDescription:dRLAErrorMessageBLEProblemUnknwon userInfo:RLAErrorUserInfoLocal]

/*!
 *  @abstract Utility class which provides convenience methods for initializing errors as well as internal framework error codes.
 */
@interface RLAError : NSObject

/*!
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined <code>RLAErrorCode</code> for the error.
 *  @param localizedDescription Localised string with the description of the error.
 *  @param userInfo A dictionary of information for the error. This parameter may be <code>nil</code>.
 *	@return An <code>NSError</code> object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RLAErrorCode
 */
+ (NSError*)errorWithCode:(RLAErrorCode)code
     localizedDescription:(NSString*)localizedDescription
                 userInfo:(NSDictionary*)userInfo;

/*!
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined RLAErrorCode for the error.
 *  @param localizedDescription Localised string with the description of the error.
 *  @param failureReason A string specifying the reason for the failure.
 *	@return An NSError object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RLAErrorCode
 */
+ (NSError*)errorWithCode:(RLAErrorCode)code
      localizedDescription:(NSString*)localizedDescription
             failureReason:(NSString*)failureReason
                  userInfo:(NSDictionary*)userInfo;

@end
