module http

// The status codes listed here are based on the comprehensive list,
// available at:
// https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
pub enum Status {
	unknown                         = -1
	unassigned                      = 0
	cont                            = 100
	switching_protocols             = 101
	processing                      = 102
	checkpoint_draft                = 103
	ok                              = 200
	created                         = 201
	accepted                        = 202
	non_authoritative_information   = 203
	no_content                      = 204
	reset_content                   = 205
	partial_content                 = 206
	multi_status                    = 207
	already_reported                = 208
	im_used                         = 226
	multiple_choices                = 300
	moved_permanently               = 301
	found                           = 302
	see_other                       = 303
	not_modified                    = 304
	use_proxy                       = 305
	switch_proxy                    = 306
	temporary_redirect              = 307
	permanent_redirect              = 308
	bad_request                     = 400
	unauthorized                    = 401
	payment_required                = 402
	forbidden                       = 403
	not_found                       = 404
	method_not_allowed              = 405
	not_acceptable                  = 406
	proxy_authentication_required   = 407
	request_timeout                 = 408
	conflict                        = 409
	gone                            = 410
	length_required                 = 411
	precondition_failed             = 412
	request_entity_too_large        = 413
	request_uri_too_long            = 414
	unsupported_media_type          = 415
	requested_range_not_satisfiable = 416
	expectation_failed              = 417
	im_a_teapot                     = 418
	misdirected_request             = 421
	unprocessable_entity            = 422
	locked                          = 423
	failed_dependency               = 424
	unordered_collection            = 425
	upgrade_required                = 426
	precondition_required           = 428
	too_many_requests               = 429
	request_header_fields_too_large = 431
	unavailable_for_legal_reasons   = 451
	client_closed_request           = 499
	internal_server_error           = 500
	not_implemented                 = 501
	bad_gateway                     = 502
	service_unavailable             = 503
	gateway_timeout                 = 504
	http_version_not_supported      = 505
	variant_also_negotiates         = 506
	insufficient_storage            = 507
	loop_detected                   = 508
	bandwidth_limit_exceeded        = 509
	not_extended                    = 510
	network_authentication_required = 511
}

// from returns the corresponding enum variant of `Status`
// given the `code` in integer value.
pub fn Status.from(code i32) -> Status {
	return match code {
		100 => .cont
		101 => .switching_protocols
		102 => .processing
		103 => .checkpoint_draft
		104..=199 => .unassigned
		200 => .ok
		201 => .created
		202 => .accepted
		203 => .non_authoritative_information
		204 => .no_content
		205 => .reset_content
		206 => .partial_content
		207 => .multi_status
		208 => .already_reported
		209..=225 => .unassigned
		226 => .im_used
		227..=299 => .unassigned
		300 => .multiple_choices
		301 => .moved_permanently
		302 => .found
		303 => .see_other
		304 => .not_modified
		305 => .use_proxy
		306 => .switch_proxy
		307 => .temporary_redirect
		308 => .permanent_redirect
		309..=399 => .unassigned
		400 => .bad_request
		401 => .unauthorized
		402 => .payment_required
		403 => .forbidden
		404 => .not_found
		405 => .method_not_allowed
		406 => .not_acceptable
		407 => .proxy_authentication_required
		408 => .request_timeout
		409 => .conflict
		410 => .gone
		411 => .length_required
		412 => .precondition_failed
		413 => .request_entity_too_large
		414 => .request_uri_too_long
		415 => .unsupported_media_type
		416 => .requested_range_not_satisfiable
		417 => .expectation_failed
		418 => .im_a_teapot
		419..=420 => .unassigned
		421 => .misdirected_request
		422 => .unprocessable_entity
		423 => .locked
		424 => .failed_dependency
		425 => .unordered_collection
		426 => .upgrade_required
		428 => .precondition_required
		429 => .too_many_requests
		431 => .request_header_fields_too_large
		432..=450 => .unassigned
		451 => .unavailable_for_legal_reasons
		452..=498 => .unassigned
		499 => .client_closed_request
		500 => .internal_server_error
		501 => .not_implemented
		502 => .bad_gateway
		503 => .service_unavailable
		504 => .gateway_timeout
		505 => .http_version_not_supported
		506 => .variant_also_negotiates
		507 => .insufficient_storage
		508 => .loop_detected
		509 => .bandwidth_limit_exceeded
		510 => .not_extended
		511 => .network_authentication_required
		512..=599 => .unassigned
		else => .unknown
	}
}

// str returns the string representation of Status `code`.
pub fn (c Status) str() -> string {
	return match c {
		.cont => 'Continue'
		.switching_protocols => 'Switching Protocols'
		.processing => 'Processing'
		.checkpoint_draft => 'Checkpoint Draft'
		.ok => 'OK'
		.created => 'Created'
		.accepted => 'Accepted'
		.non_authoritative_information => 'Non Authoritative Information'
		.no_content => 'No Content'
		.reset_content => 'Reset Content'
		.partial_content => 'Partial Content'
		.multi_status => 'Multi Status'
		.already_reported => 'Already Reported'
		.im_used => 'IM Used'
		.multiple_choices => 'Multiple Choices'
		.moved_permanently => 'Moved Permanently'
		.found => 'Found'
		.see_other => 'See Other'
		.not_modified => 'Not Modified'
		.use_proxy => 'Use Proxy'
		.switch_proxy => 'Switch Proxy'
		.temporary_redirect => 'Temporary Redirect'
		.permanent_redirect => 'Permanent Redirect'
		.bad_request => 'Bad Request'
		.unauthorized => 'Unauthorized'
		.payment_required => 'Payment Required'
		.forbidden => 'Forbidden'
		.not_found => 'Not Found'
		.method_not_allowed => 'Method Not Allowed'
		.not_acceptable => 'Not Acceptable'
		.proxy_authentication_required => 'Proxy Authentication Required'
		.request_timeout => 'Request Timeout'
		.conflict => 'Conflict'
		.gone => 'Gone'
		.length_required => 'Length Required'
		.precondition_failed => 'Precondition Failed'
		.request_entity_too_large => 'Request Entity Too Large'
		.request_uri_too_long => 'Request URI Too Long'
		.unsupported_media_type => 'Unsupported Media Type'
		.requested_range_not_satisfiable => 'Requested Range Not Satisfiable'
		.expectation_failed => 'Expectation Failed'
		.im_a_teapot => 'Im a teapot'
		.misdirected_request => 'Misdirected Request'
		.unprocessable_entity => 'Unprocessable Entity'
		.locked => 'Locked'
		.failed_dependency => 'Failed Dependency'
		.unordered_collection => 'Unordered Collection'
		.upgrade_required => 'Upgrade Required'
		.precondition_required => 'Precondition Required'
		.too_many_requests => 'Too Many Requests'
		.request_header_fields_too_large => 'Request Header Fields Too Large'
		.unavailable_for_legal_reasons => 'Unavailable For Legal Reasons'
		.client_closed_request => 'Client Closed Request'
		.internal_server_error => 'Internal Server Error'
		.not_implemented => 'Not Implemented'
		.bad_gateway => 'Bad Gateway'
		.service_unavailable => 'Service Unavailable'
		.gateway_timeout => 'Gateway Timeout'
		.http_version_not_supported => 'HTTP Version Not Supported'
		.variant_also_negotiates => 'Variant Also Negotiates'
		.insufficient_storage => 'Insufficient Storage'
		.loop_detected => 'Loop Detected'
		.bandwidth_limit_exceeded => 'Bandwidth Limit Exceeded'
		.not_extended => 'Not Extended'
		.network_authentication_required => 'Network Authentication Required'
		.unassigned => 'Unassigned'
		else => 'Unknown'
	}
}

// int converts an assigned and known Status to its integral equivalent.
// if a Status is unknown or unassigned, this method will return zero
pub fn (c Status) int() -> i32 {
	if c in [.unknown, .unassigned] {
		return 0
	}
	return c as i32
}

// is_valid returns true if the status code is assigned and known
pub fn (c Status) is_valid() -> bool {
	number := c.int()
	return number >= 100 && number < 600
}

// is_error will return true if the status code represents either a client or
// a server error; otherwise will return false
pub fn (c Status) is_error() -> bool {
	number := c.int()
	return number >= 400 && number < 600
}

// is_success will return true if the status code represents either an
// informational, success, or redirection response; otherwise will return false
pub fn (c Status) is_success() -> bool {
	number := c.int()
	return number >= 100 && number < 400
}
