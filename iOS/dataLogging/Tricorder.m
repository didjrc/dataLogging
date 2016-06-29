//
//  Tricorder.m
//  Tricorder
//
//  Created by Neal on 7/2/15.
//  Copyright (c) 2015 Pebble Technology. All rights reserved.
//

#import "Tricorder.h"

#import "AppDelegate.h"
#import "TricorderData.h"

NSString *const TricorderDataUpdatedNotification = @"tricorderUpdated";

@interface Tricorder ()

@property NSMutableArray *packetIds;

@end

@implementation Tricorder

+ (instancetype)sharedTricorder {
    static Tricorder *sharedTricorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTricorder = [[self alloc] init];
    });
    return sharedTricorder;
}

- (instancetype)init {
    if (self = [super init]) {
        _recordedData = [[NSMutableArray alloc] init];
        _packetIds = [[NSMutableArray alloc] init];
		//test
		_persistDataContainer = [[NSMutableArray alloc] init];
		//endTest
    }
    return self;
}

//http://nshipster.com/nscoding/
- (id) initWithCoder:(NSCoder *) decoder {
	self = [super init];
	if (!self) {
		return nil;
	}
	self.persistDataContainer = [decoder decodeObjectForKey:@"Logs"];
	return self;
}

- (void) encodeWithCoder:(NSCoder *) encoder {
	[encoder encodeObject:self.persistDataContainer forKey:@"Logs"];
}

- (NSString *)connectionStatus {
    return self.latestData.connectionStatus ? @"Connected" : @"Disconnected";
}

- (uint32_t)latestPacketId {
    return self.latestData.packetId;
}

- (NSString *)latestPacketTime {
    if (_recordedData.count == 0) {
        return @"N/A";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, h:mm:ss.SSS"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.latestData.timestamp / 1000]];
}

- (NSUInteger)numberOfLogs {
    return _recordedData.count;
}

- (EczemamaLogger *)latestData {
//- (TricorderData *)latestData {
    return _recordedData.firstObject;
}

- (void)resetData {
    _crcMismatches = 0;
    _duplicatePackets = 0;
    _outOfOrderPackets = 0;
    _missingPackets = 0;
    [_recordedData removeAllObjects];
    [_packetIds removeAllObjects];
//	//test --> Not necessary b/c don't want to overwrite this container....or is it possible to just use this as an active container for each datalogging session....NSUserDefaults obj will act as container Array. Each datalogging container array can then be appended to the NSUserDefaults container?
//	[_persistDataContainer removeAllObjects];
//	//endTest
	
    [[NSNotificationCenter defaultCenter] postNotificationName:TricorderDataUpdatedNotification object:self];
}

#pragma mark - PBDataLoggingServiceDelegate

- (BOOL)dataLoggingService:(PBDataLoggingService *)service
             hasByteArrays:(const UInt8 *const)bytes
             numberOfItems:(UInt16)numberOfItems
     forDataLoggingSession:(PBDataLoggingSessionMetadata *)session {
    for (NSUInteger i = 0; i < numberOfItems; i++) {
        const uint8_t *logBytes = &bytes[i * session.itemSize];
        
//        TricorderData *data = [[TricorderData alloc] initWithBytes:logBytes andLength:session.itemSize];
        EczemamaLogger *data = [[EczemamaLogger alloc] initWithBytes:logBytes andLength:session.itemSize];
        [data log];
        
        if (data.packetId == 1) {
            [self resetData];
        }
        
//        if (data.crc32Pebble != data.crc32Phone) {
//            _crcMismatches++;
//        }
        
        if (data.packetId < self.latestPacketId) {
            _outOfOrderPackets++;
        }
        
        if ([_packetIds containsObject:@(data.packetId)]) {
            _duplicatePackets++;
        }
        
        [_packetIds addObject:@(data.packetId)];
        
        [_recordedData insertObject:data atIndex:0];
		
//		//test write to _persistDataContainer
		[_persistDataContainer insertObject:data atIndex:0];
//		//endTest
    }
    
    _missingPackets = [[_packetIds valueForKeyPath:@"@max.self"] intValue] - (_recordedData.count - _duplicatePackets);
    return YES;
}

- (void)dataLoggingService:(PBDataLoggingService *)service
          sessionDidFinish:(PBDataLoggingSessionMetadata *)session {
    [[NSNotificationCenter defaultCenter] postNotificationName:TricorderDataUpdatedNotification object:self];
	
	//test writes to NSUserDefaults
	NSUserDefaults *persistedLogs = [NSUserDefaults standardUserDefaults];
	//test
//	_persistDataContainer = [[NSMutableArray alloc] init];
//	[persistedLogs setObject:_persistDataContainer forKey:@"Logs"];
	// http://stackoverflow.com/questions/15857408/attempt-to-insert-non-property-value-objective-c
	[persistedLogs setObject:[[NSKeyedArchiver archivedDataWithRootObject:self.persistDataContainer] mutableCopy] forKey:@"Logs"];
	//endTest
	[persistedLogs synchronize];  //pushes save to NSUserDefaults
}

@end
