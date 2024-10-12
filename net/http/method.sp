module http

pub enum Method {
	// as of 2023-06-20
	get
	head
	post
	put

	// uncommon ones:
	acl
	baseline_control
	bind
	checkin
	checkout
	connect
	copy
	delete
	label
	link
	lock
	merge
	mkactivity
	mkcalendar
	mkcol
	mkredirectref
	mkworkspace
	move
	options
	orderpatch
	patch
	pri
	propfind
	proppatch
	rebind
	report
	search
	trace
	unbind
	uncheckout
	unlink
	unlock
	update
	updateredirectref
	version_control
}

// str returns the string representation of the HTTP Method `m`.
pub fn (m Method) str() -> string {
	return match m {
		.get => 'GET'
		.head => 'HEAD'
		.post => 'POST'
		.put => 'PUT'
		// uncommon ones:
		.acl => 'ACL'
		.baseline_control => 'BASELINE-CONTROL'
		.bind => 'BIND'
		.checkin => 'CHECKIN'
		.checkout => 'CHECKOUT'
		.connect => 'CONNECT'
		.copy => 'COPY'
		.delete => 'DELETE'
		.label => 'LABEL'
		.link => 'LINK'
		.lock => 'LOCK'
		.merge => 'MERGE'
		.mkactivity => 'MKACTIVITY'
		.mkcalendar => 'MKCALENDAR'
		.mkcol => 'MKCOL'
		.mkredirectref => 'MKREDIRECTREF'
		.mkworkspace => 'MKWORKSPACE'
		.move => 'MOVE'
		.options => 'OPTIONS'
		.orderpatch => 'ORDERPATCH'
		.patch => 'PATCH'
		.pri => 'PRI'
		.propfind => 'PROPFIND'
		.proppatch => 'PROPPATCH'
		.rebind => 'REBIND'
		.report => 'REPORT'
		.search => 'SEARCH'
		.trace => 'TRACE'
		.unbind => 'UNBIND'
		.uncheckout => 'UNCHECKOUT'
		.unlink => 'UNLINK'
		.unlock => 'UNLOCK'
		.update => 'UPDATE'
		.updateredirectref => 'UPDATEREDIRECTREF'
		.version_control => 'VERSION-CONTROL'
	}
}

// method_from_str returns the corresponding `Method` enum field
// given a string `m`, e.g. `'GET'` would return `Method.get`.
//
// Currently, the default value is `Method.get` for unsupported string value.
pub fn Method.from_str(m string) -> Method {
	return match m {
		'GET' => .get
		'HEAD' => .head
		'POST' => .post
		'PUT' => .put
		// uncommon ones:
		'ACL' => .acl
		'BASELINE-CONTROL' => .baseline_control
		'BIND' => .bind
		'CHECKIN' => .checkin
		'CHECKOUT' => .checkout
		'CONNECT' => .connect
		'COPY' => .copy
		'DELETE' => .delete
		'LABEL' => .label
		'LINK' => .link
		'LOCK' => .lock
		'MERGE' => .merge
		'MKACTIVITY' => .mkactivity
		'MKCALENDAR' => .mkcalendar
		'MKCOL' => .mkcol
		'MKREDIRECTREF' => .mkredirectref
		'MKWORKSPACE' => .mkworkspace
		'MOVE' => .move
		'OPTIONS' => .options
		'ORDERPATCH' => .orderpatch
		'PATCH' => .patch
		'PRI' => .pri
		'PROPFIND' => .propfind
		'PROPPATCH' => .proppatch
		'REBIND' => .rebind
		'REPORT' => .report
		'SEARCH' => .search
		'TRACE' => .trace
		'UNBIND' => .unbind
		'UNCHECKOUT' => .uncheckout
		'UNLINK' => .unlink
		'UNLOCK' => .unlock
		'UPDATE' => .update
		'UPDATEREDIRECTREF' => .updateredirectref
		'VERSION-CONTROL' => .version_control
		else => .get
	}
}
