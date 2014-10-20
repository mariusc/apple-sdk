/**
 * @page tracing Tracing
 *
 * Runtime tracing can be controlled by environment variables or API calls.
 *
 * #### Environment variables
 *
 * Tracing is switched on by setting the MQTT_C_CLIENT_TRACE environment variable.
 * A value of ON, or stdout, prints to stdout, any other value is interpreted as a file name to use.
 *
 * The amount of trace detail is controlled with the MQTT_C_CLIENT_TRACE_LEVEL environment
 * variable - valid values are ERROR, PROTOCOL, MINIMUM, MEDIUM and MAXIMUM
 * (from least to most verbose).
 *
 * The variable MQTT_C_CLIENT_TRACE_MAX_LINES limits the number of lines of trace that are output
 * to a file.  Two files are used at most, when they are full, the last one is overwritten with the
 * new trace entries.  The default size is 1000 lines.
 *
 * #### Trace API calls
 *
 * MQTTAsync_traceCallback() is used to set a callback function which is called whenever trace
 * information is available.  This will be the same information as that printed if the
 * environment variables were used to control the trace.
 *
 * The MQTTAsync_setTraceLevel() calls is used to set the maximum level of trace entries that will be
 * passed to the callback function.  The levels are:
 * 1. ::MQTTASYNC_TRACE_MAXIMUM
 * 2. ::MQTTASYNC_TRACE_MEDIUM
 * 3. ::MQTTASYNC_TRACE_MINIMUM
 * 4. ::MQTTASYNC_TRACE_PROTOCOL
 * 5. ::MQTTASYNC_TRACE_ERROR
 * 6. ::MQTTASYNC_TRACE_SEVERE
 * 7. ::MQTTASYNC_TRACE_FATAL
 *
 * Selecting ::MQTTASYNC_TRACE_MAXIMUM will cause all trace entries at all levels to be returned.
 * Choosing ::MQTTASYNC_TRACE_ERROR will cause ERROR, SEVERE and FATAL trace entries to be returned
 * to the callback function.
 *
 * ### MQTT Packet Tracing
 *
 * A feature that can be very useful is printing the MQTT packets that are sent and received.  To
 * achieve this, use the following environment variable settings:
 * @code
 MQTT_C_CLIENT_TRACE=ON
 MQTT_C_CLIENT_TRACE_LEVEL=PROTOCOL
 * @endcode
 * The output you should see looks like this:
 * @code
 20130528 155936.813 3 stdout-subscriber -> CONNECT cleansession: 1 (0)
 20130528 155936.813 3 stdout-subscriber <- CONNACK rc: 0
 20130528 155936.813 3 stdout-subscriber -> SUBSCRIBE msgid: 1 (0)
 20130528 155936.813 3 stdout-subscriber <- SUBACK msgid: 1
 20130528 155941.818 3 stdout-subscriber -> DISCONNECT (0)
 * @endcode
 * where the fields are:
 * 1. date
 * 2. time
 * 3. socket number
 * 4. client id
 * 5. direction (-> from client to server, <- from server to client)
 * 6. packet details
 *
 * ### Default Level Tracing
 *
 * This is an extract of a default level trace of a call to connect:
 * @code
 19700101 010000.000 (1152206656) (0)> MQTTClient_connect:893
 19700101 010000.000 (1152206656)  (1)> MQTTClient_connectURI:716
 20130528 160447.479 Connecting to serverURI localhost:1883
 20130528 160447.479 (1152206656)   (2)> MQTTProtocol_connect:98
 20130528 160447.479 (1152206656)    (3)> MQTTProtocol_addressPort:48
 20130528 160447.479 (1152206656)    (3)< MQTTProtocol_addressPort:73
 20130528 160447.479 (1152206656)    (3)> Socket_new:599
 20130528 160447.479 New socket 4 for localhost, port 1883
 20130528 160447.479 (1152206656)     (4)> Socket_addSocket:163
 20130528 160447.479 (1152206656)      (5)> Socket_setnonblocking:73
 20130528 160447.479 (1152206656)      (5)< Socket_setnonblocking:78 (0)
 20130528 160447.479 (1152206656)     (4)< Socket_addSocket:176 (0)
 20130528 160447.479 (1152206656)     (4)> Socket_error:95
 20130528 160447.479 (1152206656)     (4)< Socket_error:104 (115)
 20130528 160447.479 Connect pending
 20130528 160447.479 (1152206656)    (3)< Socket_new:683 (115)
 20130528 160447.479 (1152206656)   (2)< MQTTProtocol_connect:131 (115)
 * @endcode
 * where the fields are:
 * 1. date
 * 2. time
 * 3. thread id
 * 4. function nesting level
 * 5. function entry (>) or exit (<)
 * 6. function name : line of source code file
 * 7. return value (if there is one)
 *
 * ### Memory Allocation Tracing
 *
 * Setting the trace level to maximum causes memory allocations and frees to be traced along with
 * the default trace entries, with messages like the following:
 * @code
 20130528 161819.657 Allocating 16 bytes in heap at file /home/icraggs/workspaces/mqrtc/mqttv3c/src/MQTTPacket.c line 177 ptr 0x179f930
 
 20130528 161819.657 Freeing 16 bytes in heap at file /home/icraggs/workspaces/mqrtc/mqttv3c/src/MQTTPacket.c line 201, heap use now 896 bytes
 * @endcode
 * When the last MQTT client object is destroyed, if the trace is being recorded
 * and all memory allocated by the client library has not been freed, an error message will be
 * written to the trace.  This can help with fixing memory leaks.  The message will look like this:
 * @code
 20130528 163909.208 Some memory not freed at shutdown, possible memory leak
 20130528 163909.208 Heap scan start, total 880 bytes
 20130528 163909.208 Heap element size 32, line 354, file /home/icraggs/workspaces/mqrtc/mqttv3c/src/MQTTPacket.c, ptr 0x260cb00
 20130528 163909.208   Content
 20130528 163909.209 Heap scan end
 * @endcode
 * @endcond
 */