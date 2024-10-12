module net

import sys.windows.winsock

const WSA_V22 = 0x202

// WsaError is all of the socket errors that WSA provides from WSAGetLastError
pub enum WsaError {
	// WSAEINTR
	// A blocking operation was interrupted by a call to WSACancelBlockingCall.
	wsaeintr = 10004

	// WSAEBADF
	// The file handle supplied is not valid.
	wsaebadf = 10009

	// WSAEACCES
	// An attempt was made to access a socket in a way forbidden by its access permissions.
	wsaeacces = 10013

	// WSAEFAULT
	// The system detected an invalid pointer address in attempting to use a pointer argument in a call.
	wsaefault = 10014

	// WSAEINVAL
	// An invalid argument was supplied.
	wsaeinval = 10022

	// WSAEMFILE
	// Too many open sockets.
	wsaemfile = 10024

	// WSAEWOULDBLOCK
	// A non-blocking socket operation could not be completed immediately.
	wsaewouldblock = 10035

	// WSAEINPROGRESS
	// A blocking operation is currently executing.
	wsaeinprogress = 10036

	// WSAEALREADY
	// An operation was attempted on a non-blocking socket that already had an operation in progress.
	wsaealready = 10037

	// WSAENOTSOCK
	// An operation was attempted on something that is not a socket.
	wsaenotsock = 10038

	// WSAEDESTADDRREQ
	// A required address was omitted from an operation on a socket.
	wsaedestaddrreq = 10039

	// WSAEMSGSIZE
	// A message sent on a datagram socket was larger than the internal message buffer or some other network limit, or the buffer used to receive a datagram into was smaller than the datagram itself.
	wsaemsgsize = 10040

	// WSAEPROTOTYPE
	// A protocol was specified in the socket function call that does not support the semantics of the socket type requested.
	wsaeprototype = 10041

	// WSAENOPROTOOPT
	// An unknown, invalid, or unsupported option or level was specified in a getsockopt or setsockopt call.
	wsaenoprotoopt = 10042

	// WSAEPROTONOSUPPORT
	// The requested protocol has not been configured into the system, or no implementation for it exists.
	wsaeprotonosupport = 10043

	// WSAESOCKTNOSUPPORT
	// The support for the specified socket type does not exist in this address family.
	wsaesocktnosupport = 10044

	// WSAEOPNOTSUPP
	// The attempted operation is not supported for the type of object referenced.
	wsaeopnotsupp = 10045

	// WSAEPFNOSUPPORT
	// The protocol family has not been configured into the system or no implementation for it exists.
	wsaepfnosupport = 10046

	// WSAEAFNOSUPPORT
	// An address incompatible with the requested protocol was used.
	wsaeafnosupport = 10047

	// WSAEADDRINUSE
	// Only one usage of each socket address (protocol/network address/port) is normally permitted.
	wsaeaddrinuse = 10048

	// WSAEADDRNOTAVAIL
	// The requested address is not valid in its context.
	wsaeaddrnotavail = 10049

	// WSAENETDOWN
	// A socket operation encountered a dead network.
	wsaenetdown = 10050

	// WSAENETUNREACH
	// A socket operation was attempted to an unreachable network.
	wsaenetunreach = 10051

	// WSAENETRESET
	// The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.
	wsaenetreset = 10052

	// WSAECONNABORTED
	// An established connection was aborted by the software in your host machine.
	wsaeconnaborted = 10053

	// WSAECONNRESET
	// An existing connection was forcibly closed by the remote host.
	wsaeconnreset = 10054

	// WSAENOBUFS
	// An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.
	wsaenobufs = 10055

	// WSAEISCONN
	// A connect request was made on an already connected socket.
	wsaeisconn = 10056

	// WSAENOTCONN
	// A request to send or receive data was disallowed because the socket is not connected and (when sending on a datagram socket using a sendto call) no address was supplied.
	wsaenotconn = 10057

	// WSAESHUTDOWN
	// A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call.
	wsaeshutdown = 10058

	// WSAETOOMANYREFS
	// Too many references to some kernel object.
	wsaetoomanyrefs = 10059

	// WSAETIMEDOUT
	// A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.
	wsaetimedout = 10060

	// WSAECONNREFUSED
	// No connection could be made because the target machine actively refused it.
	wsaeconnrefused = 10061

	// WSAELOOP
	// Cannot translate name.
	wsaeloop = 10062

	// WSAENAMETOOLONG
	// Name component or name was too long.
	wsaenametoolong = 10063

	// WSAEHOSTDOWN
	// A socket operation failed because the destination host was down.
	wsaehostdown = 10064

	// WSAEHOSTUNREACH
	// A socket operation was attempted to an unreachable host.
	wsaehostunreach = 10065

	// WSAENOTEMPTY
	// Cannot remove a directory that is not empty.
	wsaenotempty = 10066

	// WSAEPROCLIM
	// A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously.
	wsaeproclim = 10067

	// WSAEUSERS
	// Ran out of quota.
	wsaeusers = 10068

	// WSAEDQUOT
	// Ran out of disk quota.
	wsaedquot = 10069

	// WSAESTALE
	// File handle reference is no longer available.
	wsaestale = 10070

	// WSAEREMOTE
	// Item is not available locally.
	wsaeremote = 10071

	// WSASYSNOTREADY
	// WSAStartup cannot function at this time because the underlying system it uses to provide network services is currently unavailable.
	wsasysnotready = 10091

	// WSAVERNOTSUPPORTED
	// The Windows Sockets version requested is not supported.
	wsavernotsupported = 10092

	// WSANOTINITIALISED
	// Either the application has not called WSAStartup, or WSAStartup failed.
	wsanotinitialised = 10093

	// WSAEDISCON
	// Returned by WSARecv or WSARecvFrom to indicate the remote party has initiated a graceful shutdown sequence.
	wsaediscon = 10101

	// WSAENOMORE
	// No more results can be returned by WSALookupServiceNext.
	wsaenomore = 10102

	// WSAECANCELLED
	// A call to WSALookupServiceEnd was made while this call was still processing. The call has been canceled.
	wsaecancelled = 10103

	// WSAEINVALIDPROCTABLE
	// The procedure call table is invalid.
	wsaeinvalidproctable = 10104

	// WSAEINVALIDPROVIDER
	// The requested service provider is invalid.
	wsaeinvalidprovider = 10105

	// WSAEPROVIDERFAILEDINIT
	// The requested service provider could not be loaded or initialized.
	wsaeproviderfailedinit = 10106

	// WSASYSCALLFAILURE
	// A system call has failed.
	wsasyscallfailure = 10107

	// WSASERVICE_NOT_FOUND
	// No such service is known. The service cannot be found in the specified name space.
	wsaservice_not_found = 10108

	// WSATYPE_NOT_FOUND
	// The specified class was not found.
	wsatype_not_found = 10109

	// WSA_E_NO_MORE
	// No more results can be returned by WSALookupServiceNext.
	wsa_e_no_more = 10110

	// WSA_E_CANCELLED
	// A call to WSALookupServiceEnd was made while this call was still processing. The call has been canceled.
	wsa_e_cancelled = 10111

	// WSAEREFUSED
	// A database query failed because it was actively refused.
	wsaerefused = 10112

	// WSAHOST_NOT_FOUND
	// No such host is known.
	wsahost_not_found = 11001

	// WSATRY_AGAIN
	// This is usually a temporary error during hostname resolution and means that the local server did not receive a response from an authoritative server.
	wsatry_again = 11002

	// WSANO_RECOVERY
	// A non-recoverable error occurred during a database lookup.
	wsano_recovery = 11003

	// WSANO_DATA
	// The requested name is valid, but no data of the requested type was found.
	wsano_data = 11004

	// WSA_QOS_RECEIVERS
	// At least one reserve has arrived.
	wsa_qos_receivers = 11005

	// WSA_QOS_SENDERS
	// At least one path has arrived.
	wsa_qos_senders = 11006

	// WSA_QOS_NO_SENDERS
	// There are no senders.
	wsa_qos_no_senders = 11007

	// WSA_QOS_NO_RECEIVERS
	// There are no receivers.
	wsa_qos_no_receivers = 11008

	// WSA_QOS_REQUEST_CONFIRMED
	// Reserve has been confirmed.
	wsa_qos_request_confirmed = 11009

	// WSA_QOS_ADMISSION_FAILURE
	// Error due to lack of resources.
	wsa_qos_admission_failure = 11010

	// WSA_QOS_POLICY_FAILURE
	// Rejected for administrative reasons - bad credentials.
	wsa_qos_policy_failure = 11011

	// WSA_QOS_BAD_STYLE
	// Unknown or conflicting style.
	wsa_qos_bad_style = 11012

	// WSA_QOS_BAD_OBJECT
	// Problem with some part of the filterspec or providerspecific buffer in general.
	wsa_qos_bad_object = 11013

	// WSA_QOS_TRAFFIC_CTRL_ERROR
	// Problem with some part of the flowspec.
	wsa_qos_traffic_ctrl_error = 11014

	// WSA_QOS_GENERIC_ERROR
	// General QOS error.
	wsa_qos_generic_error = 11015

	// WSA_QOS_ESERVICETYPE
	// An invalid or unrecognized service type was found in the flowspec.
	wsa_qos_eservicetype = 11016

	// WSA_QOS_EFLOWSPEC
	// An invalid or inconsistent flowspec was found in the QOS structure.
	wsa_qos_eflowspec = 11017

	// WSA_QOS_EPROVSPECBUF
	// Invalid QOS provider-specific buffer.
	wsa_qos_eprovspecbuf = 11018

	// WSA_QOS_EFILTERSTYLE
	// An invalid QOS filter style was used.
	wsa_qos_efilterstyle = 11019

	// WSA_QOS_EFILTERTYPE
	// An invalid QOS filter type was used.
	wsa_qos_efiltertype = 11020

	// WSA_QOS_EFILTERCOUNT
	// An incorrect number of QOS FILTERSPECs were specified in the FLOWDESCRIPTOR.
	wsa_qos_efiltercount = 11021

	// WSA_QOS_EOBJLENGTH
	// An object with an invalid ObjectLength field was specified in the QOS provider-specific buffer.
	wsa_qos_eobjlength = 11022

	// WSA_QOS_EFLOWCOUNT
	// An incorrect number of flow descriptors was specified in the QOS structure.
	wsa_qos_eflowcount = 11023

	// WSA_QOS_EUNKOWNPSOBJ
	// An unrecognized object was found in the QOS provider-specific buffer.
	wsa_qos_eunkownpsobj = 11024

	// WSA_QOS_EPOLICYOBJ
	// An invalid policy object was found in the QOS provider-specific buffer.
	wsa_qos_epolicyobj = 11025

	// WSA_QOS_EFLOWDESC
	// An invalid QOS flow descriptor was found in the flow descriptor list.
	wsa_qos_eflowdesc = 11026

	// WSA_QOS_EPSFLOWSPEC
	// An invalid or inconsistent flowspec was found in the QOS provider specific buffer.
	wsa_qos_epsflowspec = 11027

	// WSA_QOS_EPSFILTERSPEC
	// An invalid FILTERSPEC was found in the QOS provider-specific buffer.
	wsa_qos_epsfilterspec = 11028

	// WSA_QOS_ESDMODEOBJ
	// An invalid shape discard mode object was found in the QOS provider specific buffer.
	wsa_qos_esdmodeobj = 11029

	// WSA_QOS_ESHAPERATEOBJ
	// An invalid shaping rate object was found in the QOS provider-specific buffer.
	wsa_qos_eshaperateobj = 11030

	// WSA_QOS_RESERVED_PETYPE
	// A reserved policy element was found in the QOS provider-specific buffer.
	wsa_qos_reserved_petype = 11031

	// WSA_SECURE_HOST_NOT_FOUND
	// No such host is known securely.
	wsa_secure_host_not_found = 11032

	// WSA_IPSEC_NAME_POLICY_ERROR
	// Name based IPSEC policy could not be added.
	wsa_ipsec_name_policy_error = 11033
}

pub fn (e WsaError) desc() -> string {
	return match e {
		6 => "Specified event object handle is invalid"
		8 => "Insufficient memory available"
		87 => "One or more parameters are invalid"
		995 => "Overlapped operation aborted"
		996 => "Overlapped I/O event object not in signaled state"
		997 => "Overlapped operations will complete later"
		10004 => "Interrupted function call"
		10009 => "File handle is not valid"
		10013 => "Permission denied"
		10014 => "Bad address"
		10022 => "Invalid argument"
		10024 => "Too many open files"
		10035 => "Resource temporarily unavailable"
		10036 => "Operation now in progress"
		10037 => "Operation already in progress"
		10038 => "Socket operation on nonsocket"
		10039 => "Destination address required"
		10040 => "Message too long"
		10041 => "Protocol wrong type for socket"
		10042 => "Bad protocol option"
		10043 => "Protocol not supported"
		10044 => "Socket type not supported"
		10045 => "Operation not supported"
		10046 => "Protocol family not supported"
		10047 => "Address family not supported by protocol family"
		10048 => "Address already in use"
		10049 => "Cannot assign requested address"
		10050 => "Network is down"
		10051 => "Network is unreachable"
		10052 => "Network dropped connection on reset"
		10053 => "Software caused connection abort"
		10054 => "Connection reset by peer"
		10055 => "No buffer space available"
		10056 => "Socket is already connected"
		10057 => "Socket is not connected"
		10058 => "Cannot send after socket shutdown"
		10059 => "Too many references"
		10060 => "Connection timed out"
		10061 => "Connection refused"
		10062 => "Cannot translate name"
		10063 => "Name too long"
		10064 => "Host is down"
		10065 => "No route to host"
		10066 => "Directory not empty"
		10067 => "Too many processes"
		10068 => "User quota exceeded"
		10069 => "Disk quota exceeded"
		10070 => "Stale file handle reference"
		10071 => "Item is remote"
		10091 => "Network subsystem is unavailable"
		10092 => "Winsock.dll version out of range"
		10093 => "Successful WSAStartup not yet performed"
		10101 => "Graceful shutdown in progress"
		10102 => "No more results"
		10103 => "Call has been canceled"
		10104 => "Procedure call table is invalid"
		10105 => "Service provider is invalid"
		10106 => "Service provider failed to initialize"
		10107 => "System call failure"
		10108 => "Service not found"
		10109 => "Class type not found"
		10110 => "No more results"
		10111 => "Call was canceled"
		10112 => "Database query was refused"
		11001 => "Host not found"
		11002 => "Nonauthoritative host not found"
		11003 => "This is a nonrecoverable error"
		11004 => "Valid name, no data record of requested type"
		11005 => "QoS receivers"
		11006 => "QoS senders"
		11007 => "No QoS senders"
		11008 => "QoS no receivers"
		11009 => "QoS request confirmed"
		11010 => "QoS admission error"
		11011 => "QoS policy failure"
		11012 => "QoS bad style"
		11013 => "QoS bad object"
		11014 => "QoS traffic control error"
		11015 => "QoS generic error"
		11016 => "QoS service type error"
		11017 => "QoS flowspec error"
		11018 => "Invalid QoS provider buffer"
		11019 => "Invalid QoS filter style"
		11020 => "Invalid QoS filter type"
		11021 => "Incorrect QoS filter count"
		11022 => "Invalid QoS object length"
		11023 => "Incorrect QoS flow count"
		11024 => "Unrecognized QoS object"
		11025 => "Invalid QoS policy object"
		11026 => "Invalid QoS flow descriptor"
		11027 => "Invalid QoS provider-specific flowspec"
		11028 => "Invalid QoS provider-specific filterspec"
		11029 => "Invalid QoS shape discard mode object"
		11030 => "Invalid QoS shaping rate object"
		11031 => "Reserved policy QoS element type"
		else => "Unknown error code"
	}
}

// wsa_error tries to convert a i32 to a WsaError
pub fn wsa_error(code i32) -> WsaError {
	return code as WsaError
}

// error_code returns the last socket error
pub fn error_code() -> i32 {
	return winsock.WSAGetLastError()
}

pub fn wsa_last_error() -> WsaError {
	return wsa_error(error_code())
}

pub fn init() {
	mut wsadata := winsock.WSAData{}
	res := winsock.WSAStartup(WSA_V22, &mut wsadata)
	if res != 0 {
		panic('socket: WSAStartup failed')
	}
}
