//
//  TricorderData.h
//  Tricorder
//
//  Created by Neal on 6/30/15.
//  Copyright (c) 2015 Pebble Technology. All rights reserved.
//

//#import "AccelData.h"
#import <Foundation/Foundation.h>

//@interface TricorderData : NSObject
@interface EczemamaLogger : NSObject

@property (readonly) uint32_t packetId; //4 bytes
@property (readonly) uint64_t timestamp; //4 bytes
@property (readonly) BOOL connectionStatus; //1 byte
//@property (readonly) uint8_t chargePercent;
//@property (readonly) AccelData *accelData;
//@property (readonly) uint32_t crc32Pebble;
//@property (readonly) uint32_t crc32Phone;

- (instancetype)initWithBytes:(const UInt8 *const)bytes andLength:(NSUInteger)length;
- (void)log;

@end
