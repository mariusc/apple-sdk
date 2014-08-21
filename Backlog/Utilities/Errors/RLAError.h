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

#define RLAErrorUserInfoLocal   @{ \
    @"file"     : [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding],          \
    @"function" : [NSString stringWithFormat:@"%i", __LINE__],                                  \
    @"line"     : [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]  }

/*!
 *  @enum RLAErrorCode
 *
 *  @abstract Enumeration of all the error codes inside the relayr error domain.
 *
 *  @constant RLAErrorCodeUnknown Error Unknown.
 *  @constant RLAErrorCodeMissingArgument Method missing an argument.
 *  @constant RLAErrorCodeMissingExpectedValue Missing an expected value.
 */
typedef NS_ENUM(NSInteger, RLAErrorCode) {
    RLAErrorCodeUnknown                 = 1,
    RLAErrorCodeMissingArgument         = 2,
    RLAErrorCodeMissingExpectedValue    = 3
};

// Error messages
#define RLAErrorMessageMissingArgument      \
    NSLocalizedStringFromTable(@"Error missing argument", kRLAErrorStringFile, @"This error happens when a method is expecting an argument which is not there.")
#define RLAErrorMessageMissingExpectedValue \
    NSLocalizedStringFromTable(@"The value is not the expected (probably nil)", kRLAErrorStringFile, @"This error happens when a value is received and it wasn't the expected.")

// Error objects
#define RLAErrorMissingArgument             \
    [RLAError errorWithCode:RLAErrorCodeMissingArgument localizedDescription:RLAErrorMessageMissingArgument userInfo:RLAErrorUserInfoLocal]
#define RLAErrorMissingExpectedValue        \
    [RLAError errorWithCode:RLAErrorCodeMissingExpectedValue localizedDescription:RLAErrorMessageMissingExpectedValue userInfo:RLAErrorUserInfoLocal]

/*!
 *  @class RLAError
 *
 *  @abstract Utility class which provides convenience methods for initializing errors as well as internal framework error codes.
 */
@interface RLAError : NSObject

#pragma mark Class methods

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
