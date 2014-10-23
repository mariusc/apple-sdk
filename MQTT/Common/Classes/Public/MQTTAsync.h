/*!
 *  @abstract Asynchronous MQTT client library for C
 *  @discussion An MQTT client application connects to MQTT-capable servers. A typical client is responsible for collecting information from a telemetry device and publishing the information to the server. It can also subscribe to topics, receive messages, and use this information to control the telemetry device.
 *
 *   <b>Using the client</b><br>
 *  Applications that use the client library typically use a similar structure:
 *  <ul>
 *      <li>Create a client object</li>
 *      <li>Set the options to connect to an MQTT server</li>
 *      <li>Set up callback functions</li>
 *      <li>Connect the client to an MQTT server</li>
 *      <li>Subscribe to any topics the client needs to receive</li>
 *      <li>Repeat until finished:</li>
 *          <ul>
 *              <li>Publish any messages the client needs to</li>
 *              <li>Handle any incoming messages</li>
 *          </ul>
 *      <li>Disconnect the client</li>
 *      <li>Free any memory being used by the client</li>
 *  </ul>
 *
 *  @namespace MQTT
 *
 *  @page async Threading
 *     The client application runs on several threads. Processing of handshaking and maintaining the network connection is performed in the background. Notifications of status and message reception are provided to the client application using callbacks registered with the library by the call to MQTTAsync_setCallbacks() (see MQTTAsync_messageArrived(), MQTTAsync_connectionLost() and MQTTAsync_deliveryComplete()).
 *
 *  @page wildcard Subscription wildcards
 *     Every MQTT message includes a topic that classifies it. MQTT servers use topics to determine which subscribers should receive messages published to the server.
 *
 *     Consider the server receiving messages from several environmental sensors. Each sensor publishes its measurement data as a message with an associated topic. Subscribing applications need to know which sensor originally published each received message. A unique topic is thus used to identify each sensor and measurement type. Topics such as SENSOR1TEMP, SENSOR1HUMIDITY, SENSOR2TEMP and so on achieve this but are not very flexible. If additional sensors are added to the system at a later date, subscribing applications must be modified to receive them.
 *
 *     To provide more flexibility, MQTT supports a hierarchical topic namespace. This allows application designers to organize topics to simplify their management. Levels in the hierarchy are delimited by the '/' character, such as SENSOR/1/HUMIDITY. Publishers and subscribers use these hierarchical topics as already described.
 *
 *     For subscriptions, two wildcard characters are supported:
 *     <ul>
 *         <li>A '#' character represents a complete sub-tree of the hierarchy and thus must be the last character in a subscription topic string, such as SENSOR/#. This will match any topic starting with SENSOR/, such as SENSOR/1/TEMP and SENSOR/2/HUMIDITY.</li>
 *         <li> A '+' character represents a single level of the hierarchy and is used between delimiters. For example, SENSOR/+/TEMP will match SENSOR/1/TEMP and SENSOR/2/TEMP.</li>
 *     </ul>
 *     Publishers are not allowed to use the wildcard characters in their topic names. Deciding on your topic hierarchy is an important step in your system design.
 *
 *  @page qos Quality of service
 *     The MQTT protocol provides three qualities of service for delivering messages between clients and servers: "at most once", "at least once" and "exactly once".
 *
 *     Quality of service (QoS) is an attribute of an individual message being published. An application sets the QoS for a specific message by setting the MQTTAsync_message.qos field to the required value.
 *
 *     A subscribing client can set the maximum quality of service a server uses to send messages that match the client subscriptions. The MQTTAsync_subscribe() and MQTTAsync_subscribeMany() functions set this maximum. The QoS of a message forwarded to a subscriber thus might be different to the QoS given to the message by the original publisher. The lower of the two values is used to forward a message. The three levels are:
 *
 *     <b>QoS0, At most once:</b> The message is delivered at most once, or it may not be delivered at all. Its delivery across the network is not acknowledged. The message is not stored. The message could be lost if the client is disconnected, or if the server fails. QoS0 is the fastest mode of transfer. It is sometimes called "fire and forget".
 *
 *     The MQTT protocol does not require servers to forward publications at QoS0 to a client. If the client is disconnected at the time the server receives the publication, the publication might be discarded, depending on the server implementation.
 *
 *     <b>QoS1, At least once:</b> The message is always delivered at least once. It might be delivered multiple times if there is a failure before an acknowledgment is received by the sender. The message must be stored locally at the sender, until the sender receives confirmation that the message has been published by the receiver. The message is stored in case the message must be sent again.
 *
 *     <b>QoS2, Exactly once:</b> The message is always delivered exactly once. The message must be stored locally at the sender, until the sender receives confirmation that the message has been published by the receiver. The message is stored in case the message must be sent again. QoS2 is the safest, but slowest mode of transfer. A more sophisticated handshaking and acknowledgement sequence is used than for QoS1 to ensure no duplication of messages occurs.
 */
#pragma once

#include <stdio.h>                      // C Standard

#if !defined(NO_PERSISTENCE)
    #include "MQTTClientPersistence.h"  // MQTT (Public)
#endif

#pragma mark Definitions

/*!
 *  @abstract Code returned by several MQTT functions.
 *  @discussion They express success or a specific type of error.
 *
 *  @constant MQTTCODE_SUCCESS Indicates successful completion of an MQTT client operation.
 *  @constant MQTTCODE_FAILURE A generic error code indicating the failure of an MQTT client operation.
 *  @constant MQTTCODE_PERSISTANCE_ERROR It is MQTTAync_PERSISTANCE_ERROR.
 *  @constant MQTTCODE_DISCONNECT The client is disconnected.
 *  @constant MQTTCODE_MAX_MESSAGES_INFLIGHT The maximum number of messages allowed to be simultaneously in-flight has been reached.
 *  @constant MQTTCODE_BAD_UTF8_STRING An invalid UTF-8 string has been detected.
 *  @constant MQTTCODE_NULL_PARAMETER A NULL parameter has been supplied when this is invalid.
 *  @constant MQTTCODE_TOPICNAME_TRUNCATED The topic has been truncated (the topic string includes embedded NULL characters). String functions will not access the full topic. Use the topic length value to access the full topic.
 *  @constant MQTTCODE_BAD_STRUCTURE A structure parameter does not have the correct eyecatcher and version number.
 *  @constant MQTTCODE_BAD_QOS A qos parameter is not 0, 1 or 2.
 *  @constant MQTTCODE_NO_MORE_MSGIDS All 65535 MQTT msgids are being used.
 */
typedef enum MQTTCODE {
    MQTTCODE_SUCCESS = 0,
    MQTTCODE_FAILURE = -1,
    MQTTCODE_PERSISTANCE_ERROR = -2,
    MQTTCODE_DISCONNECT = -3,
    MQTTCODE_MAX_MESSAGES_INFLIGHT = -4,
    MQTTCODE_BAD_UTF8_STRING = -5,
    MQTTCODE_NULL_PARAMETER = -6,
    MQTTCODE_TOPICNAME_TRUNCATED = -7,
    MQTTCODE_BAD_STRUCTURE = -8,
    MQTTCODE_BAD_QOS = -9,
    MQTTCODE_NO_MORE_MSGIDS = -10
} MQTTCode;

/**
 * Default MQTT version to connect with.  Use 3.1.1 then fall back to 3.1
 */
#define MQTTVERSION_DEFAULT 0
/**
 * MQTT version to connect with: 3.1
 */
#define MQTTVERSION_3_1 3
/**
 * MQTT version to connect with: 3.1.1
 */
#define MQTTVERSION_3_1_1 4
/**
 * Bad return code from subscribe, as defined in the 3.1.1 specification
 */
#define MQTT_BAD_SUBSCRIBE 0x80

/*!
 *  @abstract A handle representing an MQTT client. A valid client handle is available following a successful call to MQTTAsync_create().
 */
typedef void* MQTTAsync;

/*!
 *  @abstract A value representing an MQTT message.
 *  @discussion A token is returned to the client application when a message is published. The token can then be used to check that the message was successfully delivered to its destination (see: MQTTAsync_publish(), MQTTAsync_publishMessage(), MQTTAsync_deliveryComplete(), and MQTTAsync_getPendingTokens()).
 */
typedef int MQTTAsync_token;

/*!
 *  @abstract A structure representing the payload and attributes of an MQTT message.
 *  @discussion The message topic is not part of this structure (see MQTTAsync_publishMessage(), MQTTAsync_publish(), MQTTAsync_receive(), MQTTAsync_freeMessage() and MQTTAsync_messageArrived()).
 *
 *  @field struct_id The eyecatcher for this structure. Must be MQTM.
 *  @field struct_version The version number of this structure. Must be 0.
 *  @field payloadlen The length of the MQTT message payload in bytes.
 *  @field payload A pointer to the payload of the MQTT message.
 *  @field qos The quality of service (QoS) assigned to the message. There are three levels of QoS: 0 (Fire and forget - the message may not be delivered), 1 (At least once - the message will be delivered, but may be delivered more than once in some circumstances), 2 (Once and one only - the message will be delivered exactly once).
 *  @field retained The retained flag serves two purposes depending on whether the message it is associated with is being published or received.
 *      <b>retained = true</b><br>
 *      For messages being published, a true setting indicates that the MQTT server should retain a copy of the message. The message will then be transmitted to new subscribers to a topic that matches the message topic.
 *      For subscribers registering a new subscription, the flag being true indicates that the received message is not a new one, but one that has been retained by the MQTT server.
 *      <b>retained = false</b> <br>
 *      For publishers, this ndicates that this message should not be retained by the MQTT server.
 *      For subscribers, a false setting indicates this is a normal message, received as a result of it being published to the server.
 *  @field dup The dup flag indicates whether or not this message is a duplicate. It is only meaningful when receiving QoS1 messages. When true, the client application should take appropriate action to deal with the duplicate message.
 *  @field msgid The message identifier is normally reserved for internal use by the MQTT client and server.
 */
typedef struct
{
	char struct_id[4];
	int struct_version;
	int payloadlen;
	void* payload;
	int qos;
	int retained;
	int dup;
	int msgid;
} MQTTAsync_message;

#define MQTTAsync_message_initializer { {'M', 'Q', 'T', 'M'}, 0, 0, NULL, 0, 0, 0, 0 }

/*!
 *  @abstract Callback function for message received.
 *  @discussion The client application must provide an implementation of this function to enable asynchronous receipt of messages. The function is registered with the client library by passing it as an argument to MQTTAsync_setCallbacks(). It is called by the client library when a new message that matches a client subscription has been received from the server. This function is executed on a separate thread to the one on which the client application is running.
 *
 *  @param context A pointer to the <i>context</i> value originally passed to MQTTAsync_setCallbacks(), which contains any application-specific context.
 *  @param topicName The topic associated with the received message.
 *  @param topicLen The length of the topic if there are one more NULL characters embedded in <i>topicName</i>, otherwise <i>topicLen</i> is 0. If <i>topicLen</i> is 0, the value returned by <i>strlen(topicName)</i> can be trusted. If <i>topicLen</i> is greater than 0, the full topic name can be retrieved by accessing <i>topicName</i> as a byte array of length <i>topicLen</i>.
 *  @param message The MQTTAsync_message structure for the received message. This structure contains the message payload and attributes.
 *  @return This function must return a boolean value indicating whether or not the message has been safely received by the client application. Returning true indicates that the message has been successfully handled. Returning false indicates that there was a problem. In this case, the client library will reinvoke MQTTAsync_messageArrived() to attempt to deliver the message to the application again.
 *
 */
typedef int MQTTAsync_messageArrived(void* context, char* topicName, size_t topicLen, MQTTAsync_message* message);

/*!
 *  @abstract Callback function for a message delivered.
 *  @discussion The client application must provide an implementation of this function to enable asynchronous notification of delivery of messages to the server. The function is registered with the client library by passing it as an argument to MQTTAsync_setCallbacks(). It is called by the client library after the client application has published a message to the server. It indicates that the necessary handshaking and acknowledgements for the requested quality of service (see MQTTAsync_message.qos) have been completed. This function is executed on a separate thread to the one on which the client application is running.
 *
 *  @param context A pointer to the <i>context</i> value originally passed to MQTTAsync_setCallbacks(), which contains any application-specific context.
 *  @param token The MQTTAsync_token associated with the published message. Applications can check that all messages have been correctly published by matching the tokens returned from calls to MQTTAsync_send() and MQTTAsync_sendMessage() with the tokens passed to this callback.
 */
typedef void MQTTAsync_deliveryComplete(void* context, MQTTAsync_token token);

/*!
 *  @abstract Callback function for a connection lost.
 *  @discussion The client application must provide an implementation of this function to enable asynchronous notification of the loss of connection to the server. The function is registered with the client library by passing it as an argument to MQTTAsync_setCallbacks(). It is called by the client library if the client loses its connection to the server. The client application must take appropriate action, such as trying to reconnect or reporting the problem. This function is executed on a separate thread to the one on which the client application is running.
 *
 *  @param context A pointer to the <i>context</i> value originally passed to MQTTAsync_setCallbacks(), which contains any application-specific context.
 *  @param cause The reason for the disconnection. Currently, <i>cause</i> is always set to NULL.
 */
typedef void MQTTAsync_connectionLost(void* context, char* cause);

/*!
 *  @abstract The data returned on completion of an unsuccessful API call in the response callback onFailure.
 *
 *  @field token A token identifying the failed request.
 *  @field code A numeric code identifying the error.
 *  @field message Optional text explaining the error. Can be NULL.
 */
typedef struct
{
	MQTTAsync_token token;
	int code;
	char* message;
} MQTTAsync_failureData;

/*!
 *  @abstract The data returned on completion of a successful API call in the response callback onSuccess.
 *
 *  @field token A token identifying the successful request. Can be used to refer to the request later.
 *  @field alt A union of the different values that can be returned for subscribe, unsubscribe and publish.
 *      @field qos For subscribe, the granted QoS of the subscription returned by the server.
 *      @field qosList For subscribeMany, the list of granted QoSs of the subscriptions returned by the server.
 *      @field pub For publish, the message being sent to the server.
 *      @field connect For connect, the server connected to, MQTT version used, and sessionPresentation flag.
 */
typedef struct
{
	MQTTAsync_token token;
	union
	{
		int qos;
		int* qosList;
		struct
		{
			MQTTAsync_message message;
			char* destinationName;
		} pub;
		struct
		{
			char* serverURI;
			int MQTTVersion;
			int sessionPresent;
		} connect;
	} alt;
} MQTTAsync_successData;

/*!
 *  @abstract This is a callback function. The client application must provide an implementation of this function to enable asynchronous notification of the successful completion of an API call. The function is registered with the client library by passing it as an argument in MQTTAsync_responseOptions.
 *
 *  @param context A pointer to the <i>context</i> value originally passed to MQTTAsync_responseOptions, which contains any application-specific context.
 *  @param response Any success data associated with the API completion.
 */
typedef void MQTTAsync_onSuccess(void* context, MQTTAsync_successData* response);

/*!
 *  @abstract This is a callback function. The client application must provide an implementation of this function to enable asynchronous notification of the unsuccessful completion of an API call. The function is registered with the client library by passing it as an argument in MQTTAsync_responseOptions.
 *
 *  @param context A pointer to the <i>context</i> value originally passed to MQTTAsync_responseOptions, which contains any application-specific context.
 *  @param response Any failure data associated with the API completion.
 */
typedef void MQTTAsync_onFailure(void* context,  MQTTAsync_failureData* response);

/*!
 *  @abstract <#Brief intro#>
 *  @field struct_id The eyecatcher for this structure. Must be MQTR.
 *  @field struct_version The version number of this structure. Must be 0.
 *  @field onSuccess A pointer to a callback function to be called if the API call successfully completes. Can be set to NULL, in which case no indication of successful completion will be received.
 *  @field onFailure A pointer to a callback function to be called if the API call fails. Can be set to NULL, in which case no indication of unsuccessful completion will be received.
 *  @field context A pointer to any application-specific context. The <i>context</i> pointer is passed to success or failure callback functions to provide access to the context information in the callback.
 *  @field token Output.
 */
typedef struct
{
    char struct_id[4];
    int struct_version;
    MQTTAsync_onSuccess* onSuccess;
    MQTTAsync_onFailure* onFailure;
    void* context;
    MQTTAsync_token token;
} MQTTAsync_responseOptions;

#define MQTTAsync_responseOptions_initializer { {'M', 'Q', 'T', 'R'}, 0, NULL, NULL, 0, 0 }

#pragma mark Public API

/*!
 *  @abstract This function creates an MQTT client ready for connection to the specified server and using the specified persistent storage (@link MQTTAsync_persistence @/link).
 *
 *  @param handle A pointer to an MQTTAsync handle. The handle is populated with a valid client reference following a successful return from this function.
 *  @param serverURI A null-terminated string specifying the server to which the client will connect. It takes the form <code>protocol://host:port</code>. The <code>protocol</code> must be <code>tcp</code> or <code>ssl</code>. For <code>host</code>, you can specify either an IP address or a domain name. For instance, to connect to a server running on the local machines with the default MQTT port, specify <code>tcp://localhost:1883</code>.
 *  @param clientId The client identifier passed to the server when the client connects to it. It is a null-terminated UTF-8 encoded string. ClientIDs must be no longer than 23 characters according to the MQTT specification.
 *  @param persistence_type The type of persistence to be used by the client:
 *  <ul>
 *      <li><code>MQTTCLIENT_PERSISTENCE_NONE</code>: Use in-memory persistence. If the device or system on which the client is running fails or is switched off, the current state of any in-flight messages is lost and some messages may not be delivered even at QoS1 and QoS2.</li>
 *      <li><code>MQTTCLIENT_PERSISTENCE_DEFAULT</code>: Use the default (file system-based) persistence mechanism. Status about in-flight messages is held in persistent storage and provides some protection against message loss in the case of unexpected failure.</li>
 *      <li><code>MQTTCLIENT_PERSISTENCE_USER</code>: Use an application-specific persistence implementation. Using this type of persistence gives control of the persistence mechanism to the application. The application has to implement the MQTTClient_persistence interface.</li>
 *  </ul>
 *  @param persistence_context If the application uses <code>MQTTCLIENT_PERSISTENCE_NONE</code> persistence, this argument is unused and should be set to <code>NULL</code>. For <code>MQTTCLIENT_PERSISTENCE_DEFAULT</code> persistence, it should be set to the location of the persistence directory (if set to NULL, the persistence directory used is the working directory). Applications that use <code>MQTTCLIENT_PERSISTENCE_USER</code> persistence set this argument to point to a valid <code>MQTTClient_persistence</code> structure.
 *  @return MQTTCODE_SUCCESS if the client is successfully created, otherwise an error code is returned.
 *
 *  @see MQTTAsync_destroy
 */
MQTTCode MQTTAsync_create(MQTTAsync* handle, char const* restrict serverURI, char const* restrict clientId, int const persistence_type, void* restrict persistence_context)
__attribute__( (visibility("default")) );

/*!
 *  @abstract This function sets the global callback functions for a specific client.
 *  @discussion If your client application doesn't use a particular callback, set the relevant parameter to NULL. Any necessary message acknowledgements and status communications are handled in the background without any intervention from the client application.  If you do not set a messageArrived callback function, you will not be notified of the receipt of any messages as a result of a subscription.
 *
 *  @note  The MQTT client must be disconnected when this function is called.
 *  @param handle A valid client handle from a successful call to MQTTAsync_create().
 *  @param context A pointer to any application-specific context. The the <i>context</i> pointer is passed to each of the callback functions to provide access to the context information in the callback.
 *  @param cl A pointer to an MQTTAsync_connectionLost() callback function. You can set this to NULL if your application doesn't handle disconnections.
 *  @param ma A pointer to an MQTTAsync_messageArrived() callback function.  You can set this to NULL if your application doesn't handle receipt of messages.
 *  @param dc A pointer to an MQTTAsync_deliveryComplete() callback function. You can set this to NULL if you do not want to check for successful delivery.
 *  @return MQTTCODE_SUCCESS if the callbacks were correctly set, MQTTCODE_FAILURE if an error occurred.
 */
int MQTTAsync_setCallbacks(MQTTAsync handle, void* context, MQTTAsync_connectionLost* cl, MQTTAsync_messageArrived* ma, MQTTAsync_deliveryComplete* dc) __attribute__( (visibility("default")) );

/**
 * MQTTAsync_willOptions defines the MQTT "Last Will and Testament" (LWT) settings for
 * the client. In the event that a client unexpectedly loses its connection to
 * the server, the server publishes the LWT message to the LWT topic on
 * behalf of the client. This allows other clients (subscribed to the LWT topic)
 * to be made aware that the client has disconnected. To enable the LWT
 * function for a specific client, a valid pointer to an MQTTAsync_willOptions
 * structure is passed in the MQTTAsync_connectOptions structure used in the
 * MQTTAsync_connect() call that connects the client to the server. The pointer
 * to MQTTAsync_willOptions can be set to NULL if the LWT function is not
 * required.
 */
typedef struct
{
	/** The eyecatcher for this structure.  must be MQTW. */
	const char struct_id[4];
	/** The version number of this structure.  Must be 0 */
	int struct_version;
	/** The LWT topic to which the LWT message will be published. */
	const char* topicName;
	/** The LWT payload. */
	const char* message;
	/**
      * The retained flag for the LWT message (see MQTTAsync_message.retained).
      */
	int retained;
	/**
      * The quality of service setting for the LWT message (see
      * MQTTAsync_message.qos and @ref qos).
      */
	int qos;
} MQTTAsync_willOptions;

#define MQTTAsync_willOptions_initializer { {'M', 'Q', 'T', 'W'}, 0, NULL, NULL, 0, 0 }

/**
* MQTTAsync_sslProperties defines the settings to establish an SSL/TLS connection using the
* OpenSSL library. It covers the following scenarios:
* - Server authentication: The client needs the digital certificate of the server. It is included
*   in a store containting trusted material (also known as "trust store").
* - Mutual authentication: Both client and server are authenticated during the SSL handshake. In
*   addition to the digital certificate of the server in a trust store, the client will need its own
*   digital certificate and the private key used to sign its digital certificate stored in a "key store".
* - Anonymous connection: Both client and server do not get authenticated and no credentials are needed
*   to establish an SSL connection. Note that this scenario is not fully secure since it is subject to
*   man-in-the-middle attacks.
*/
typedef struct
{
	/** The eyecatcher for this structure.  Must be MQTS */
	const char struct_id[4];
	/** The version number of this structure.  Must be 0 */
	int struct_version;

	/** The file in PEM format containing the public digital certificates trusted by the client. */
	const char* trustStore;

	/** The file in PEM format containing the public certificate chain of the client. It may also include
	* the client's private key.
	*/
	const char* keyStore;

	/** If not included in the sslKeyStore, this setting points to the file in PEM format containing
	* the client's private key.
	*/
	const char* privateKey;
	/** The password to load the client's privateKey if encrypted. */
	const char* privateKeyPassword;

	/**
	* The list of cipher suites that the client will present to the server during the SSL handshake. For a
	* full explanation of the cipher list format, please see the OpenSSL on-line documentation:
	* http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
	* If this setting is ommitted, its default value will be "ALL", that is, all the cipher suites -excluding
	* those offering no encryption- will be considered.
	* This setting can be used to set an SSL anonymous connection ("aNULL" string value, for instance).
	*/
	const char* enabledCipherSuites;

    /** True/False option to enable verification of the server certificate **/
    int enableServerCertAuth;

} MQTTAsync_SSLOptions;

#define MQTTAsync_SSLOptions_initializer { {'M', 'Q', 'T', 'S'}, 0, NULL, NULL, NULL, NULL, NULL, 1 }

/*!
 *  @abstract MQTTAsync_connectOptions defines several settings that control the way the client connects to an MQTT server.  Default values are set in MQTTAsync_connectOptions_initializer.
 *
 *  @field struct_id The eyecatcher for this structure. Must be MQTC.
 *  @field struct_version The version number of this structure.  Must be 0, 1 or 2.
 *      0 signifies no SSL options and no serverURIs
 *      1 signifies no serverURIs
 *      2 signifies no MQTTVersion
 *  @field keepAliveInterval The "keep alive" interval, measured in seconds, defines the maximum time that should pass without communication between the client and the server. The client will ensure that at least one message travels across the network within each keep alive period.  In the absence of a data-related message during the time period, the client sends a very small MQTT "ping" message, which the server will acknowledge. The keep alive interval enables the client to detect when the server is no longer available without having to wait for the long TCP/IP timeout. Set to 0 if you do not want any keep alive processing.
 *  @field cleansession This is a boolean value. The cleansession setting controls the behaviour of both the client and the server at connection and disconnection time. The client and server both maintain session state information. This information is used to ensure "at least once" and "exactly once" delivery, and "exactly once" receipt of messages. Session state also includes subscriptions created by an MQTT client. You can choose to maintain or discard state information between sessions.
 *      When cleansession is true, the state information is discarded at connect and disconnect. Setting cleansession to false keeps the state information. When you connect an MQTT client application with MQTTAsync_connect(), the client identifies the connection using the client identifier and the address of the server. The server checks whether session information for this client has been saved from a previous connection to the server. If a previous session still exists, and cleansession=true, then the previous session information at the client and server is cleared. If cleansession=false, the previous session is resumed. If no previous session exists, a new session is started.
 *  @field maxInflight This controls how many messages can be in-flight simultaneously.
 *  @field will This is a pointer to an MQTTAsync_willOptions structure. If your application does not make use of the Last Will and Testament feature, set this pointer to NULL.
 *  @field username MQTT servers that support the MQTT v3.1 protocol provide authentication and authorisation by user name and password. This is the user name parameter.
 *  @field password MQTT servers that support the MQTT v3.1 protocol provide authentication and authorisation by user name and password. This is the password parameter.
 *  @field connectTimeout The time interval in seconds to allow a connect to complete.
 *  @field retryInterval The time interval in seconds.
 *  @field ssl This is a pointer to an MQTTAsync_SSLOptions structure. If your application does not make use of SSL, set this pointer to NULL.
 *  @field onSuccess A pointer to a callback function to be called if the connect successfully completes.  Can be set to NULL, in which case no indication of successful completion will be received.
 *  @field onFailure A pointer to a callback function to be called if the connect fails. Can be set to NULL, in which case no indication of unsuccessful completion will be received.
 *  @field context A pointer to any application-specific context. The the <i>context</i> pointer is passed to success or failure callback functions to provide access to the context information in the callback.
 *  @field serverURIcount The number of entries in the serverURIs array.
 *  @field serverURIs An array of null-terminated strings specifying the servers to which the client will connect. Each string takes the form <i>protocol://host:port</i>. <i>protocol</i> must be <i>tcp</i> or <i>ssl</i>. For <i>host</i>, you can specify either an IP address or a domain name. For instance, to connect to a server running on the local machines with the default MQTT port, specify <i>tcp://localhost:1883</i>.
 *  @field MQTTVersion Sets the version of MQTT to be used on the connect.
 *      MQTTVERSION_DEFAULT (0) = default: start with 3.1.1, and if that fails, fall back to 3.1
 *      MQTTVERSION_3_1 (3) = only try version 3.1
 *      MQTTVERSION_3_1_1 (4) = only try version 3.1.1
 */
typedef struct
{
	const char struct_id[4];
	int struct_version;
	int keepAliveInterval;
	int cleansession;
	int maxInflight;
	MQTTAsync_willOptions* will;
	const char* username;
	const char* password;
	int connectTimeout;
	int retryInterval;
	MQTTAsync_SSLOptions* ssl;
	MQTTAsync_onSuccess* onSuccess;
	MQTTAsync_onFailure* onFailure;
	void* context;
	int serverURIcount;
	char* const* serverURIs;
	int MQTTVersion;
} MQTTAsync_connectOptions;


#define MQTTAsync_connectOptions_initializer { {'M', 'Q', 'T', 'C'}, 3, 60, 1, 10, NULL, NULL, NULL, 30, 0, NULL, NULL, NULL, NULL, 0, NULL, 0}

/**
  * This function attempts to connect a previously-created client (see
  * MQTTAsync_create()) to an MQTT server using the specified options. If you
  * want to enable asynchronous message and status notifications, you must call
  * MQTTAsync_setCallbacks() prior to MQTTAsync_connect().
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param options A pointer to a valid MQTTAsync_connectOptions
  * structure.
  * @return MQTTCODE_SUCCESS if the client connect request was accepted.
  * If the client was unable to connect to the server, an error code is
  * returned via the onFailure callback, if set.
  * Error codes greater than 0 are returned by the MQTT protocol:<br><br>
  * <b>1</b>: Connection refused: Unacceptable protocol version<br>
  * <b>2</b>: Connection refused: Identifier rejected<br>
  * <b>3</b>: Connection refused: Server unavailable<br>
  * <b>4</b>: Connection refused: Bad user name or password<br>
  * <b>5</b>: Connection refused: Not authorized<br>
  * <b>6-255</b>: Reserved for future use<br>
  */
int MQTTAsync_connect(MQTTAsync handle, const MQTTAsync_connectOptions* options) __attribute__( (visibility("default")) );


typedef struct
{
	/** The eyecatcher for this structure. Must be MQTD. */
	const char struct_id[4];
	/** The version number of this structure.  Must be 0 or 1.  0 signifies no SSL options */
	int struct_version;
	/**
      * The client delays disconnection for up to this time (in
      * milliseconds) in order to allow in-flight message transfers to complete.
      */
	int timeout;
	/**
    * A pointer to a callback function to be called if the disconnect successfully
    * completes.  Can be set to NULL, in which case no indication of successful
    * completion will be received.
    */
	MQTTAsync_onSuccess* onSuccess;
	/**
    * A pointer to a callback function to be called if the disconnect fails.
    * Can be set to NULL, in which case no indication of unsuccessful
    * completion will be received.
    */
	MQTTAsync_onFailure* onFailure;
	/**
	* A pointer to any application-specific context. The
    * the <i>context</i> pointer is passed to success or failure callback functions to
    * provide access to the context information in the callback.
    */
	void* context;
} MQTTAsync_disconnectOptions;

#define MQTTAsync_disconnectOptions_initializer { {'M', 'Q', 'T', 'D'}, 0, 0, NULL, NULL, NULL }


/**
  * This function attempts to disconnect the client from the MQTT
  * server. In order to allow the client time to complete handling of messages
  * that are in-flight when this function is called, a timeout period is
  * specified. When the timeout period has expired, the client disconnects even
  * if there are still outstanding message acknowledgements.
  * The next time the client connects to the same server, any QoS 1 or 2
  * messages which have not completed will be retried depending on the
  * cleansession settings for both the previous and the new connection (see
  * MQTTAsync_connectOptions.cleansession and MQTTAsync_connect()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param options The client delays disconnection for up to this time (in
  * milliseconds) in order to allow in-flight message transfers to complete.
  * @return MQTTCODE_SUCCESS if the client successfully disconnects from
  * the server. An error code is returned if the client was unable to disconnect
  * from the server
  */
int MQTTAsync_disconnect(MQTTAsync handle, const MQTTAsync_disconnectOptions* options) __attribute__( (visibility("default")) );


/**
  * This function allows the client application to test whether or not a
  * client is currently connected to the MQTT server.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @return Boolean true if the client is connected, otherwise false.
  */
int MQTTAsync_isConnected(MQTTAsync handle) __attribute__( (visibility("default")) );


/**
  * This function attempts to subscribe a client to a single topic, which may
  * contain wildcards (see @ref wildcard). This call also specifies the
  * @ref qos requested for the subscription
  * (see also MQTTAsync_subscribeMany()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param topic The subscription topic, which may include wildcards.
  * @param qos The requested quality of service for the subscription.
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return MQTTCODE_SUCCESS if the subscription request is successful.
  * An error code is returned if there was a problem registering the
  * subscription.
  */
int MQTTAsync_subscribe(MQTTAsync handle, const char* topic, int qos, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );


/**
  * This function attempts to subscribe a client to a list of topics, which may
  * contain wildcards (see @ref wildcard). This call also specifies the
  * @ref qos requested for each topic (see also MQTTAsync_subscribe()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param count The number of topics for which the client is requesting
  * subscriptions.
  * @param topic An array (of length <i>count</i>) of pointers to
  * topics, each of which may include wildcards.
  * @param qos An array (of length <i>count</i>) of @ref qos
  * values. qos[n] is the requested QoS for topic[n].
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return MQTTCODE_SUCCESS if the subscription request is successful.
  * An error code is returned if there was a problem registering the
  * subscriptions.
  */
int MQTTAsync_subscribeMany(MQTTAsync handle, int count, char* const* topic, int* qos, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );

/**
  * This function attempts to remove an existing subscription made by the
  * specified client.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param topic The topic for the subscription to be removed, which may
  * include wildcards (see @ref wildcard).
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return MQTTCODE_SUCCESS if the subscription is removed.
  * An error code is returned if there was a problem removing the
  * subscription.
  */
int MQTTAsync_unsubscribe(MQTTAsync handle, const char* topic, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );

/**
  * This function attempts to remove existing subscriptions to a list of topics
  * made by the specified client.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param count The number subscriptions to be removed.
  * @param topic An array (of length <i>count</i>) of pointers to the topics of
  * the subscriptions to be removed, each of which may include wildcards.
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return MQTTCODE_SUCCESS if the subscriptions are removed.
  * An error code is returned if there was a problem removing the subscriptions.
  */
int MQTTAsync_unsubscribeMany(MQTTAsync handle, int count, char* const* topic, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );


/**
  * This function attempts to publish a message to a given topic (see also
  * MQTTAsync_sendMessage()). An MQTTAsync_token is issued when
  * this function returns successfully. If the client application needs to
  * test for successful delivery of messages, a callback should be set
  * (see MQTTAsync_onSuccess() and MQTTAsync_deliveryComplete()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param destinationName The topic associated with this message.
  * @param payloadlen The length of the payload in bytes.
  * @param payload A pointer to the byte array payload of the message.
  * @param qos The @ref qos of the message.
  * @param retained The retained flag for the message.
  * @param response A pointer to an MQTTAsync_responseOptions structure. Used to set callback functions.
  * This is optional and can be set to NULL.
  * @return MQTTCODE_SUCCESS if the message is accepted for publication.
  * An error code is returned if there was a problem accepting the message.
  */
int MQTTAsync_send(MQTTAsync handle, const char* destinationName, int payloadlen, void* payload, int qos, int retained, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );


/**
  * This function attempts to publish a message to a given topic (see also
  * MQTTAsync_publish()). An MQTTAsync_token is issued when
  * this function returns successfully. If the client application needs to
  * test for successful delivery of messages, a callback should be set
  * (see MQTTAsync_onSuccess() and MQTTAsync_deliveryComplete()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param destinationName The topic associated with this message.
  * @param msg A pointer to a valid MQTTAsync_message structure containing
  * the payload and attributes of the message to be published.
  * @param response A pointer to an MQTTAsync_responseOptions structure. Used to set callback functions.
  * @return MQTTCODE_SUCCESS if the message is accepted for publication.
  * An error code is returned if there was a problem accepting the message.
  */
int MQTTAsync_sendMessage(MQTTAsync handle, const char* destinationName, const MQTTAsync_message* msg, MQTTAsync_responseOptions* response) __attribute__( (visibility("default")) );


/**
  * This function sets a pointer to an array of tokens for
  * messages that are currently in-flight (pending completion).
  *
  * <b>Important note:</b> The memory used to hold the array of tokens is
  * malloc()'d in this function. The client application is responsible for
  * freeing this memory when it is no longer required.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param tokens The address of a pointer to an MQTTAsync_token.
  * When the function returns successfully, the pointer is set to point to an
  * array of tokens representing messages pending completion. The last member of
  * the array is set to -1 to indicate there are no more tokens. If no tokens
  * are pending, the pointer is set to NULL.
  * @return MQTTCODE_SUCCESS if the function returns successfully.
  * An error code is returned if there was a problem obtaining the list of
  * pending tokens.
  */
int MQTTAsync_getPendingTokens(MQTTAsync handle, MQTTAsync_token **tokens) __attribute__( (visibility("default")) );

#define MQTTASYNC_TRUE 1
int MQTTAsync_isComplete(MQTTAsync handle, MQTTAsync_token dt) __attribute__( (visibility("default")) );

int MQTTAsync_waitForCompletion(MQTTAsync handle, MQTTAsync_token dt, unsigned long timeout) __attribute__( (visibility("default")) );


/**
  * This function frees memory allocated to an MQTT message, including the
  * additional memory allocated to the message payload. The client application
  * calls this function when the message has been fully processed. <b>Important
  * note:</b> This function does not free the memory allocated to a message
  * topic string. It is the responsibility of the client application to free
  * this memory using the MQTTAsync_free() library function.
  * @param msg The address of a pointer to the MQTTAsync_message structure
  * to be freed.
  */
void MQTTAsync_freeMessage(MQTTAsync_message** msg) __attribute__( (visibility("default")) );

/**
  * This function frees memory allocated by the MQTT C client library, especially the
  * topic name. This is needed on Windows when the client libary and application
  * program have been compiled with different versions of the C compiler.  It is
  * thus good policy to always use this function when freeing any MQTT C client-
  * allocated memory.
  * @param ptr The pointer to the client library storage to be freed.
  */
void MQTTAsync_free(void* ptr) __attribute__( (visibility("default")) );

/**
  * This function frees the memory allocated to an MQTT client (see
  * MQTTAsync_create()). It should be called when the client is no longer
  * required.
  * @param handle A pointer to the handle referring to the MQTTAsync
  * structure to be freed.
  */
void MQTTAsync_destroy(MQTTAsync* handle) __attribute__( (visibility("default")) );



enum MQTTASYNC_TRACE_LEVELS
{
	MQTTASYNC_TRACE_MAXIMUM = 1,
	MQTTASYNC_TRACE_MEDIUM,
	MQTTASYNC_TRACE_MINIMUM,
	MQTTASYNC_TRACE_PROTOCOL,
	MQTTASYNC_TRACE_ERROR,
	MQTTASYNC_TRACE_SEVERE,
	MQTTASYNC_TRACE_FATAL,
};


/**
  * This function sets the level of trace information which will be
  * returned in the trace callback.
  * @param level the trace level required
  */
void MQTTAsync_setTraceLevel(enum MQTTASYNC_TRACE_LEVELS level) __attribute__( (visibility("default")) );


/**
  * This is a callback function prototype which must be implemented if you want
  * to receive trace information.
  * @param level the trace level of the message returned
  * @param meesage the trace message.  This is a pointer to a static buffer which
  * will be overwritten on each call.  You must copy the data if you want to keep
  * it for later.
  */
typedef void MQTTAsync_traceCallback(enum MQTTASYNC_TRACE_LEVELS level, char* message);

/**
  * This function sets the trace callback if needed.  If set to NULL,
  * no trace information will be returned.  The default trace level is
  * MQTTASYNC_TRACE_MINIMUM.
  * @param callback a pointer to the function which will handle the trace information
  */
void MQTTAsync_setTraceCallback(MQTTAsync_traceCallback* callback) __attribute__( (visibility("default")) );


typedef struct
{
	const char* name;
	const char* value;
} MQTTAsync_nameValue;

/**
  * This function returns version information about the library.
  * no trace information will be returned.  The default trace level is
  * MQTTASYNC_TRACE_MINIMUM
  * @return an array of strings describing the library.  The last entry is a NULL pointer.
  */
MQTTAsync_nameValue* MQTTAsync_getVersionInfo() __attribute__( (visibility("default")) );
