#import "RLABluetoothAdapterController.h"   // Header
#import "RLAPeripheralnfo.h"                // Relayr.framework (domain object)
#import "RLAMappingInfo.h"                  // Relayr.framework (domain object)
//#import "RLAColorSensor.h"                  // Relayr.framework (sensor)
//#import "RLAProximitySensor.h"              // Relayr.framework (sensor)
//#import "RLAGyroscopeSensor.h"              // Relayr.framework (sensor)
//#import "RLAAccelerometerSensor.h"          // Relayr.framework (sensor)
//#import "RLATemperatureSensor.h"            // Relayr.framework (sensor)
//#import "RLAHumiditySensor.h"               // Relayr.framework (sensor)
//#import "RLANoiseSensor.h"                  // Relayr.framework (sensor)
#import "RLABluetoothAdapterSensorAccelerometer.h"
#import "RLABluetoothAdapterSensorColor.h"
#import "RLABluetoothAdapterSensorGyroscope.h"
#import "RLABluetoothAdapterSensorHumidity.h"
#import "RLABluetoothAdapterSensorNoise.h"
#import "RLABluetoothAdapterSensorProximity.h"
#import "RLABluetoothAdapterSensorTemperature.h"
//#import "RLAWunderbarGroveOutput.h"         // Relayr.framework (output)
//#import "RLAWunderbarInfraredOutput.h"      // Relayr.framework (output)

@implementation RLABluetoothAdapterController
{
    NSArray* _acceptedPeripherals;
}

#pragma mark - Public API

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _acceptedPeripherals = [self setupAcceptedPeripherals];
    }
    return self;
}

- (RLAPeripheralnfo*)infoForPeripheralWithName:(NSString *)name bleIdentifier:(NSString*)identifier serviceUUID:(NSString*)serviceUUID characteristicUUID:(NSString*)characteristicUUID
{
    // Iterate over accepted peripherals
    for (RLAPeripheralnfo* info in _acceptedPeripherals) {
        
        // Match peripherals that have equal names and ble identifiers
        BOOL const isEqualName = [info.name isEqualToString:name];
        BOOL isEqualIdentifier = [info.bleIdentifier isEqualToString:identifier];
        if (info.bleIdentifier.length == 0) { isEqualIdentifier = YES; }
        
        if (isEqualName && isEqualIdentifier)
        {
            // Check mapping for those peripherals
            for (RLAMappingInfo* mappingInfo in info.mappings)
            {
                // Match peripherals that expose the same services and characteristics as required by the mappings
                BOOL isEqualService = ([mappingInfo.serviceUUIDs indexOfObject:serviceUUID] != NSNotFound);
                if ( !serviceUUID ) { isEqualService = YES; }
                
                BOOL isEqualCharacteristic = ([[mappingInfo characteristicUUIDs] indexOfObject:characteristicUUID] != NSNotFound);
                if ( !characteristicUUID ) { isEqualCharacteristic = YES; }
                
                if (isEqualService && isEqualCharacteristic) { return info; }
            }
        }
    }
    return nil;
}

#warning Ghost method
- (RLAPeripheralnfo*)infoForPeripheralWithModelIdentifier:(NSString*)identifier
{
    for (RLAPeripheralnfo *info in [self setupAcceptedPeripherals])
    {
        if ([[info relayrModelID] isEqualToString:identifier]) { return info; }
    }
    return nil;
}

#pragma mark - Private methods

// TODO: Uncomment code
- (NSArray*)setupAcceptedPeripherals
{
    // Standard wunderbar services and characteristics
    NSArray* services = @[@"2000", @"2002"];
    NSArray* characteristics = @[@"2016"];
    // The bleIdentifiers are used to filter devices with specific udids for testing reasons when many devices are beeing advertised Sensors
    NSArray* peripherals = @[
//         @{@"name"          : @"WunderbarLIGHT",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"a7ec1b21-8582-4304-b1cf-15a1fc66d1e8",
//           @"mappings"      : @[
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLAColorSensor class] adapterClass:[RLABluetoothAdapterSensorColor class] serviceUUIDs:services characteristicUUIDs:characteristics],
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLAProximitySensor class] adapterClass:[RLABluetoothAdapterSensorProximity class] serviceUUIDs:services characteristicUUIDs:characteristics] ]
//         },
//         @{@"name"          : @"WunderbarGYRO",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"173c44b5-334e-493f-8eb8-82c8cc65d29f",
//           @"mappings"      : @[
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLAGyroscopeSensor class] adapterClass:[RLABluetoothAdapterSensorGyroscope class] serviceUUIDs:services characteristicUUIDs:characteristics],
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLAAccelerometerSensor class] adapterClass:[RLABluetoothAdapterSensorAccelerometer class] serviceUUIDs:services characteristicUUIDs:characteristics] ]
//         },
//         @{@"name"          : @"WunderbarHTU",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"ecf6cf94-cb07-43ac-a85e-dccf26b48c86",
//           @"mappings"      : @[
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLATemperatureSensor class] adapterClass:[RLABluetoothAdapterSensorTemperature class] serviceUUIDs:services characteristicUUIDs:characteristics],
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLAHumiditySensor class] adapterClass:[RLABluetoothAdapterSensorHumidity class] serviceUUIDs:services characteristicUUIDs:characteristics] ]
//         },
//         @{@"name"          : @"WunderbarMIC",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"4f38b6c6-a8e9-4f93-91cd-2ac4064b7b5a",
//           @"mappings"      : @[
//                [[RLAMappingInfo alloc] initWithSensorClass:[RLANoiseSensor class] adapterClass:[RLABluetoothAdapterSensorNoise class] serviceUUIDs:services characteristicUUIDs:characteristics] ]
//         },
//         // Outputs
//         @{@"name"          : @"WunderbarBRIDG",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"ebd828dd-250c-4baf-807d-69d85bed065b",
//           @"mappings"      : @[ [[RLAMappingInfo alloc] initWithOutputClass:[RLAWunderbarGroveOutput class]] ],
//         },
//         @{@"name"          : @"WunderbarIR",
//           @"bleIdentifier" : @"",
//           @"relayrModelID" : @"bab45b9c-1c44-4e71-8e98-a321c658df47",
//           @"mappings"      : @[ [[RLAMappingInfo alloc] initWithOutputClass:[RLAWunderbarInfraredOutput class]] ],
//         }
    ];
    
    NSMutableArray* tmp = [NSMutableArray array];
    for (NSDictionary* dict in peripherals)
    {
        RLAPeripheralnfo* info = [[RLAPeripheralnfo alloc] initWithName:dict[@"name"] bleIdentifier:dict[@"bleIdentifier"] relayrModelID:dict[@"relayrModelID"] mappings:dict[@"mappings"]];
        [tmp addObject:info];
    }
    
    return [tmp copy];
}

@end
