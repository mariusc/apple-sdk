@import Foundation; // Apple

/*!
 *  @constant kRLAErrorDomain
 *
 *  @abstract It specifies the error domain of relayr.
 */
FOUNDATION_EXPORT NSString* const kRLAErrorDomain;

/*!
 *  @constant kRLAErrorStringFile
 *
 *  @abstract The string that contains the translation of all Relayr.framework error messages.
 */
FOUNDATION_EXPORT NSString* const kRLAErrorStringFile;

#pragma mark Error codes

/*!
 *  @enum RLAErrorCode
 *
 *  @abstract Enumeration of all the error codes inside the relayr error domain.
 *
 *  @constant kRLAErrorCodeUnknown Error Unknown.
 *  @constant kRLAErrorCodeMissingArgument Method missing an argument.
 *  @constant kRLAErrorCodeMissingExpectedValue Missing an expected value.
 *  @constant kRLAErrorCodeWebrequestFailure The HTTP web request failed.
 */
typedef NS_ENUM(NSInteger, RLAErrorCode) {
    kRLAErrorCodeUnknown                = 1,
    kRLAErrorCodeMissingArgument        = 2,
    kRLAErrorCodeMissingExpectedValue   = 3,
    kRLAErrorCodeWebrequestFailure      = 4,
    kRLAErrorCodeSigningFailure         = 5,
};

#define RLAErrorUserInfoLocal   @{                                                                      \
        @"file"     : [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding],              \
        @"function" : [NSString stringWithFormat:@"%i", __LINE__],                                      \
        @"line"     : [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]    }

#pragma mark Error messages

#define RLAErrorMessageMissingArgument      NSLocalizedStringFromTable(@"Error missing argument", kRLAErrorStringFile, @"This error happens when a method is expecting an argument which is not there.")
#define RLAErrorMessageMissingExpectedValue NSLocalizedStringFromTable(@"The value is not the expected (probably nil)", kRLAErrorStringFile, @"This error happens when a value is received and it wasn't the expected.")
#define RLAErrorMessageWebrequestFailure    NSLocalizedStringFromTable(@"The web request could not be satisfied", kRLAErrorStringFile, @"This error happens when a web request could not be routed or the answer was not the expected.")
#define RLAErrorMessageSigningFailure       NSLocalizedStringFromTable(@"The OAuth user signing process failed.", kRLAErrorStringFile, @"This error happens when an OAuth signing process failed.")

#pragma mark Error objects

#define RLAErrorMissingArgument         [RLAError errorWithCode:kRLAErrorCodeMissingArgument localizedDescription:RLAErrorMessageMissingArgument userInfo:RLAErrorUserInfoLocal]
#define RLAErrorMissingExpectedValue    [RLAError errorWithCode:kRLAErrorCodeMissingExpectedValue localizedDescription:RLAErrorMessageMissingExpectedValue userInfo:RLAErrorUserInfoLocal]
#define RLAErrorWebrequestFailure       [RLAError errorWithCode:kRLAErrorCodeWebrequestFailure localizedDescription:RLAErrorMessageWebrequestFailure userInfo:RLAErrorUserInfoLocal]
#define RLAErrorSigningFailure          [RLAError errorWithCode:kRLAErrorCodeSigningFailure localizedDescription:RLAErrorMessageSigningFailure userInfo:RLAErrorUserInfoLocal]

/*!
 *  @class RLAError
 *
 *  @abstract Utility class which provides convenience methods for initializing errors as well as internal framework error codes.
 */
@interface RLAError : NSObject

/*!
 *  @method errorWithCode:localizedDescription:info:
 *
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined <code>RLAErrorCode</code> for the error.
 *  @param localizedDescription Localised string with the description of the error.
 *  @param info A dictionary of information for the error. This parameter may be <code>nil</code>.
 *	@return An <code>NSError</code> object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RLAErrorCode
 */
+ (NSError*)errorWithCode:(RLAErrorCode)code
     localizedDescription:(NSString*)localizedDescription
                 userInfo:(NSDictionary*)userInfo;

/*!
 *  @method errorWithCode:localizedDescription:failureReason:
 *
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
