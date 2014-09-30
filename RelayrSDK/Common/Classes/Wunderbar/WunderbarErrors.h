#pragma once

@import Foundation;         // Apple
#import "RelayrErrors.h"    // Relayr.framework (Utilities)

/*!
 *  @abstract The string file that contains the translation of all Wunderbar error messages.
 */
#define kWunderbarErrorStringFile = @"WunderbarErrors"

#pragma mark Error codes

/*!
 *  @abstract Enumeration of all the error codes for Wunderbar related actions.
 *
 *  @constant kWunderbarErrorCodeTimeoutTooLow The timeout given for the Wunderbar
 */
typedef NS_ENUM(NSInteger, WunderbarErrorCode) {
    kWunderbarErrorCodeTimeoutTooLow        = 6
};

#pragma mark Error messages

#define dWunderbarErrorMessageTimeoutTooLow NSLocalizedStringFromTable(@"The timeout provided is too low for the given process", kRelayrErrorStringFile, @"It happens when the system consider that the timeout passed as argument is too low for the process about to run.")

#pragma mark Error objects

#define WunderbarErrorTimeoutTooLow         [RelayrErrors errorWithCode:kWunderbarErrorCodeTimeoutTooLow localizedDescription:dWunderbarErrorMessageTimeoutTooLow userInfo:RelayrErrorUserInfoLocal]
