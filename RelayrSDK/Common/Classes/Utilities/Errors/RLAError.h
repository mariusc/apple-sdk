@import Foundation; // Apple

/*!
 *  @class RLAError
 *
 *  @abstract Utility class which provides convenience methods for initializing errors as well as internal framework error codes.
 */
@interface RLAError : NSObject

#pragma mark Constants

/*!
 *  @enum RLAErrorCode
 *
 *  @abstract Enumeration of all the error codes inside the relayr error domain.
 *
 *  @constant RLAErrorCodeUnknown Error Unknown.
 *  @constant RLAErrorCodeAPIMisuse API misuse.
 *  @constant RLAErrorCodeMissingArgument Method missing an argument.
 *  @constant RLAErrorCodeMissingExpectedValue Missing an expected value.
 *  @constant RLAErrorCodeConnectionChannelPoweredOff The Bluetooth or Wifi antenna is powered off.
 *  @constant RLAErrorCodeConnectionError General connection error.
 *  @constant RLAErrorCodeUnknownConnectionError Unknown connection error.
 *  @constant RLAErrorCodeSerializationFailed Binary serialisation error.
 */
typedef NS_ENUM(NSInteger, RLAErrorCode) {
  RLAErrorCodeUnknown                       = 0,
  RLAErrorCodeAPIMisuse                     = 11983297,
  RLAErrorCodeMissingArgument               = 27631290,
  RLAErrorCodeMissingExpectedValue          = 12074001,
  RLAErrorCodeConnectionChannelPoweredOff   = 6060606,
  RLAErrorCodeConnectionError               = 17666669,
  RLAErrorCodeUnknownConnectionError        = 16579464,
  RLAErrorCodeSerializationFailed           = 40443032
};

#pragma mark Class methods

/*!
 *  @method errorWithCode:info:
 *
 *  @abstract Convenience method for initializing framework specific errors.
 *
 *  @param code The predefined RLAErrorCode for the error.
 *  @param info A dictionary of information for the error. This parameter may be nil.
 *	@return An NSError object for the error domain with the specified error code and a dictionary of error user information.
 *
 *  @seealso RLAErrorCode
 */
+ (NSError *)errorWithCode:(RLAErrorCode)code
                      info:(NSDictionary *)info;

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
+ (NSError *)errorWithCode:(RLAErrorCode)code
      localizedDescription:(NSString *)localizedDescription
             failureReason:(NSString *)failureReason;

@end
