#pragma once

#import "RLAError.h"    // Relayr.framework
#import "RLALog.h"      // Relayr.framework

// Error objects

// RLAErrorDict
//#define RLAErrorDict(obj) \
//  [NSMutableDictionary dictionaryWithObjectsAndKeys: \
//  [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding], @"file", \
//  [NSString stringWithFormat:@"%i", __LINE__], @"line", \
//  [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding], @"function", \
//  [NSString stringWithCString:#obj encoding:NSUTF8StringEncoding], @"obj", nil]
//
//// RLASetErrorRef
//#define RLAErrorAssertTrueAndSetErrorRef(obj, ref, code) \
//  if (!obj) { \
//    if (ref == NULL) { \
//      [RLALog error:@"Missing error reference"]; \
//    } else { \
//      *ref = [RLAError errorWithCode:code info: RLAErrorDict(obj)]; \
//    } \
//  }
//
//// RLAErrorAssertTrueSetErrorRefAndReturnNil
//#define RLAErrorAssertTrueSetErrorRefAndReturnNil(obj, ref, code) \
//  do { \
//    if (!obj) { \
//      if (ref == NULL) { \
//        [RLALog error:@"Missing error reference"]; \
//      } else { \
//        *ref = [RLAError errorWithCode:code info: RLAErrorDict(obj)]; \
//        return nil; \
//      } \
//    } \
//  }while(0)
//
//// RLAErrorAssertTrueSetErrorRefAndReturn
//#define RLAErrorAssertTrueSetErrorRefAndReturn(obj, ref, code) \
//  do { \
//    if (!obj) { \
//      if (ref == NULL) { \
//        [RLALog error:@"Missing error reference"]; \
//      } else { \
//        *ref = [RLAError errorWithCode:code info: RLAErrorDict(obj)]; \
//        return; \
//      } \
//    } \
//  }while(0)
//
//// RLAErrorAssertTrueAndReturnNil
//#define RLAErrorAssertTrueAndReturnNil(obj, code) \
//    do{ \
//      if (!obj) { \
//        [RLALog error: [[RLAError errorWithCode:code info: RLAErrorDict(obj)] localizedDescription]]; \
//        return nil; \
//      } \
//    }while(0)
//
//// RLAErrorAssertTrueAndReturn
//#define RLAErrorAssertTrueAndReturn(obj, code) \
//    do{ \
//      if (!obj) { \
//        [RLALog error: [[RLAError errorWithCode:code info: RLAErrorDict(obj)] localizedDescription]]; \
//        return; \
//      } \
//    }while(0)
//
//// Assertions
//
//// Constant strings (Assertions)
//static NSString* const kRLAMessageAbstractMethod = @"This is an abstract method and should be overridden";
//
//// RLAAssertAbstractMethod
//#define RLAAssertAbstractMethod     NSAssert(NO, kRLAMessageAbstractMethod)
//
//// RLAAssertAbstractMethodAndReturnNil
//#define RLAAssertAbstractMethodAndReturnNil \
//  do{ \
//    NSAssert(NO, kRLAMessageAbstractMethod); \
//    return nil; \
//  }while(0)