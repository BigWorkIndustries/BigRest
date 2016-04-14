//
//  BigRest-Logging.h
//  Pods
//
//  Created by Vincil Bishop on 6/24/15.
//
//

#ifndef Pods_BigRest_Logging_h
#define Pods_BigRest_Logging_h
#endif

#import <CocoaLumberjack/CocoaLumberjack.h>

#define LOG_LEVEL_DEF BIGRestLogLevel

#ifdef DEBUG
#ifndef BIGREST_LOGGING_ON
#define BIGREST_LOGGING_ON 1
#endif
#endif

#ifndef BIGREST_LOGGING_ON
#define BIGREST_LOGGING_ON 0
#endif

#if BIGREST_LOGGING_ON
static const DDLogLevel BIGRestLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel BIGRestLogLevel = DDLogLevelOff;
#endif