#import "AppDelegate.h"
@import IOBluetooth;

NSTimeInterval const scanningPeriod = 3.0;

@interface AppDelegate () <CBCentralManagerDelegate>
@property (weak) IBOutlet NSWindow *window;

@property (readonly,nonatomic) CBCentralManager* centralManager;
@property (readonly,nonatomic) CBPeripheralManager* peripheralManager;

@property (readonly,nonatomic) BOOL isCentralManagerScanning;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _isCentralManagerScanning = NO;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (IBAction)buttonPushed:(id)sender
{
//    if (_centralManager.state == CBCentralManagerStatePoweredOn && !_isCentralManagerScanning)
//    {
//        _isCentralManagerScanning = YES;
//        [_centralManager scanForPeripheralsWithServices:nil options:nil];
//        [NSTimer scheduledTimerWithTimeInterval:scanningPeriod target:self selector:@selector(stopScanning) userInfo:nil repeats:NO];
//    }
    
}

- (void)stopScanning
{
    [_centralManager stopScan];
    _isCentralManagerScanning = NO;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth is On");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is powered off");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"Bluetooth is being reseted");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"BLE is not supported in your system");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"Bluetooth is unathorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"Problem with Bluetooth unknown");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    if ( !peripheral.name || [((NSString*)advertisementData[CBAdvertisementDataLocalNameKey]) rangeOfString:@"estimote"].location != NSNotFound ) { return; }
    NSString* localName = peripheral.name;
    NSString* peripheralUUID = peripheral.identifier.UUIDString;
    NSString* peripheralRSSI = RSSI.stringValue;
    
    NSString* advManufacturer = (advertisementData[CBAdvertisementDataManufacturerDataKey]) ? [[NSString alloc] initWithData:advertisementData[CBAdvertisementDataManufacturerDataKey] encoding:NSUTF8StringEncoding] : @"???";
    
    NSString* advServices = @"???";
    NSDictionary* tmpDict = advertisementData[CBAdvertisementDataServiceDataKey];
    if (tmpDict)
    {
        NSMutableString* tmpStr = [[NSMutableString alloc] init];
        [tmpDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [tmpStr appendString:[NSString stringWithFormat:@"%@, ", key]];
        }];
        
        if (tmpStr.length) { advServices = [NSString stringWithString:tmpStr]; }
    }
    
    NSString* advUUIDs = @"???";
    NSArray* tmpArray = advertisementData[CBAdvertisementDataServiceUUIDsKey];
    if (tmpArray)
    {
        NSMutableString* tmpStr = [[NSMutableString alloc] init];
        for (id uuid in tmpArray)
        {
            [tmpStr appendString:[NSString stringWithFormat:@"%@, ", uuid]];
        }
        
        if (tmpStr.length) { advServices = [NSString stringWithString:tmpStr]; }
    }
    
    NSString* advIsConnectable = (!advertisementData[CBAdvertisementDataIsConnectable] || !((NSNumber*)advertisementData[CBAdvertisementDataIsConnectable]).boolValue) ? @"No" : @"Yes";
    
    printf("%s\n", [NSString stringWithFormat:@"Peripheral discovered:\n{\n\tLocal name:\t\t%@\n\tUUID:\t\t\t%@\n\tRSSI:\t\t\t%@\n\tManufacturer:\t%@\n\tService data:\t%@\n\tService UUIDs:\t%@\n\tData overflow service: %@\n\tData Tx Power Level: %@\n\tis connectable: %@\n\tSolicited service UUIDs: %@\n}\n", localName, peripheralUUID, peripheralRSSI, advManufacturer, advServices, advUUIDs, advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey], advertisementData[CBAdvertisementDataTxPowerLevelKey], advIsConnectable, advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey]].UTF8String);
}

@end
