#pragma once

#define dRLAMQTT_ProtocolTCP            @"tcp://"
#define dRLAMQTT_ProtocolSSL            @"ssl://"
#define dRLAMQTT_Host                   @"mqtt.relayr.io"
#define dRLAMQTT_PortTCP                1883
#define dRLAMQTT_PortSSL                8883
#define dRLAMQTT_QoS                    0
#define dRLAMQTT_topic(deviceID)        [NSString stringWithFormat:@"/v1/%@/data", deviceID]
