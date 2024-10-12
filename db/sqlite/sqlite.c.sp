module sqlite

#[include_if(!windows, "<sqlite3.h>", "Looks like you don't have the 'sqlite3.h' header file installed.

On Ubuntu, you can install it with:
    sudo apt-get install libsqlite3-dev

On Fedora, you can install it with:
    sudo yum install sqlite-devel

On macOS, you can install it with:
    brew install sqlite3

On Windows, you can download the precompiled binaries from:
    http://www.sqlite.org/download.html

On FreeBSD, you can install it with:
    sudo pkg install sqlite3
")]

#[library_if(!windows, "sqlite3")]

#[include_if(windows, "$SPAWN_ROOT/thirdparty/sqlite/sqlite3.h")]
#[cflags_if(windows, "$SPAWN_ROOT/thirdparty/sqlite/sqlite3.c")]

extern {
	const (
		SQLITE_OPEN_READONLY      = 0x00000001 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_READWRITE     = 0x00000002 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_CREATE        = 0x00000004 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_DELETEONCLOSE = 0x00000008 // VFS only
		SQLITE_OPEN_EXCLUSIVE     = 0x00000010 // VFS only
		SQLITE_OPEN_AUTOPROXY     = 0x00000020 // VFS only
		SQLITE_OPEN_URI           = 0x00000040 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_MEMORY        = 0x00000080 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_MAIN_DB       = 0x00000100 // VFS only
		SQLITE_OPEN_TEMP_DB       = 0x00000200 // VFS only
		SQLITE_OPEN_TRANSIENT_DB  = 0x00000400 // VFS only
		SQLITE_OPEN_MAIN_JOURNAL  = 0x00000800 // VFS only
		SQLITE_OPEN_TEMP_JOURNAL  = 0x00001000 // VFS only
		SQLITE_OPEN_SUBJOURNAL    = 0x00002000 // VFS only
		SQLITE_OPEN_SUPER_JOURNAL = 0x00004000 // VFS only
		SQLITE_OPEN_NOMUTEX       = 0x00008000 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_FULLMUTEX     = 0x00010000 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_SHAREDCACHE   = 0x00020000 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_PRIVATECACHE  = 0x00040000 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_WAL           = 0x00080000 // VFS only
		SQLITE_OPEN_NOFOLLOW      = 0x01000000 // Ok for sqlite3_open_v2()
		SQLITE_OPEN_EXRESCODE     = 0x02000000 // Extended result codes
	)

	fn sqlite3_libversion() -> *u8
	fn sqlite3_libversion_number() -> i32
	fn sqlite3_threadsafe() -> i32

	struct sqlite3 {}

	fn sqlite3_close(s *sqlite3) -> i32
	fn sqlite3_exec(s *sqlite3, sql *u8, callback fn (_ *void, _ i32, _ **u8, _ **u8) -> i32, _ *void, errmsg **u8) -> i32

	struct sqlite3_file {
		pMethods *sqlite3_io_methods
	}

	struct sqlite3_io_methods {
		iVersion               i32
		xClose                 fn (_ *i32) -> i32
		xRead                  fn (_ *i32, _ *void, _ i32, _ i32) -> i32
		xWrite                 fn (_ *i32, _ *void, _ i32, _ i32) -> i32
		xTruncate              fn (_ *i32, _ i32) -> i32
		xSync                  fn (_ *i32, _ i32) -> i32
		xFileSize              fn (_ *i32, _ *i32) -> i32
		xLock                  fn (_ *i32, _ i32) -> i32
		xUnlock                fn (_ *i32, _ i32) -> i32
		xCheckReservedLock     fn (_ *i32, _ *i32) -> i32
		xFileControl           fn (_ *i32, _ i32, _ *void) -> i32
		xSectorSize            fn (_ *i32) -> i32
		xDeviceCharacteristics fn (_ *i32) -> i32
		xShmMap                fn (_ *i32, _ i32, _ i32, _ i32, _ **void) -> i32
		xShmLock               fn (_ *i32, _ i32, _ i32, _ i32) -> i32
		xShmBarrier            fn (_ *i32)
		xShmUnmap              fn (_ *i32, _ i32) -> i32
		xFetch                 fn (_ *i32, _ i32, _ i32, _ **void) -> i32
		xUnfetch               fn (_ *i32, _ i32, _ *void) -> i32
	}

	struct sqlite3_api_routines {}

	struct sqlite3_vfs {
		iVersion          i32
		szOsFile          i32
		mxPathname        i32
		pNext             *sqlite3_vfs
		zName             *u8
		pAppData          *void
		xOpen             fn (_ *i32, _ *u8, _ *i32, _ i32, _ *i32) -> i32
		xDelete           fn (_ *i32, _ *u8, _ i32) -> i32
		xAccess           fn (_ *i32, _ *u8, _ i32, _ *i32) -> i32
		xFullPathname     fn (_ *i32, _ *u8, _ i32, _ *u8) -> i32
		xDlOpen           fn (_ *i32, _ *u8) -> *void
		xDlError          fn (_ *i32, _ i32, _ *u8)
		xDlSym            fn (_ *i32, _ *void, _ *u8) -> fn ()
		xDlClose          fn (_ *i32, _ *void)
		xRandomness       fn (_ *i32, _ i32, _ *u8) -> i32
		xSleep            fn (_ *i32, _ i32) -> i32
		xCurrentTime      fn (_ *i32, _ *f64) -> i32
		xGetLastError     fn (_ *i32, _ i32, _ *u8) -> i32
		xCurrentTimeInt64 fn (_ *i32, _ *i32) -> i32
		xSetSystemCall    fn (_ *i32, _ *u8, _ i32) -> i32
		xGetSystemCall    fn (_ *i32) -> i32
		xNextSystemCall   fn (_ *i32, _ *u8) -> *u8
	}

	fn sqlite3_initialize() -> i32
	fn sqlite3_shutdown() -> i32
	fn sqlite3_os_init() -> i32
	fn sqlite3_os_end() -> i32
	fn sqlite3_config(_ i32) -> i32
	fn sqlite3_db_config(s *sqlite3, op i32) -> i32

	struct sqlite3_mem_methods {
		xMalloc   fn (_ i32) -> *void
		xFree     fn (_ *void)
		xRealloc  fn (_ *void, _ i32) -> *void
		xSize     fn (_ *void) -> i32
		xRoundup  fn (_ i32) -> i32
		xInit     fn (_ *void) -> i32
		xShutdown fn (_ *void)
		pAppData  *void
	}

	fn sqlite3_extended_result_codes(s *sqlite3, onoff i32) -> i32
	fn sqlite3_last_insert_rowid(s *sqlite3) -> i64
	fn sqlite3_set_last_insert_rowid(s *sqlite3, _ i64)
	fn sqlite3_changes(s *sqlite3) -> i32
	fn sqlite3_total_changes(s *sqlite3) -> i32
	fn sqlite3_interrupt(s *sqlite3)
	fn sqlite3_complete(sql *u8) -> i32
	fn sqlite3_complete16(sql *void) -> i32
	fn sqlite3_busy_handler(s *sqlite3, cb fn (_ *void, _ i32) -> i32, _ *void) -> i32
	fn sqlite3_busy_timeout(s *sqlite3, ms i32) -> i32
	fn sqlite3_get_table(db *sqlite3, zSql *u8, pazResult ***u8, pnRow *i32, pnColumn *i32, pzErrmsg **u8) -> i32
	fn sqlite3_free_table(result **u8)
	fn sqlite3_mprintf(_ *u8) -> *u8
	fn sqlite3_vmprintf(_ *u8, args ...any) -> *u8
	fn sqlite3_snprintf(_ i32, _ *u8, _ *u8) -> *u8
	fn sqlite3_malloc(_ i32) -> *void
	fn sqlite3_realloc(_ *void, _ i32) -> *void
	fn sqlite3_free(_ *void)
	fn sqlite3_memory_used() -> i64
	fn sqlite3_memory_highwater(resetFlag i32) -> i64
	fn sqlite3_randomness(N i32, P *void)
	fn sqlite3_set_authorizer(s *sqlite3, xAuth fn (_ *void, _ i32, _ *u8, _ *u8, _ *u8, _ *u8) -> i32, pUserData *void) -> i32
	fn sqlite3_progress_handler(s *sqlite3, _ i32, cb fn (_ *void) -> i32, _ *void)
	fn sqlite3_open(filename *u8, ppDb **sqlite3) -> i32
	fn sqlite3_open16(filename *void, ppDb **sqlite3) -> i32
	fn sqlite3_open_v2(filename *u8, ppDb *mut *sqlite3, flags i32, zVfs *u8) -> i32
	fn sqlite3_errcode(db *sqlite3) -> i32
	fn sqlite3_extended_errcode(db *sqlite3) -> i32
	fn sqlite3_errmsg(s *sqlite3) -> *u8
	fn sqlite3_errmsg16(s *sqlite3) -> *void

	struct sqlite3_stmt {}

	fn sqlite3_limit(s *sqlite3, id i32, newVal i32) -> i32
	fn sqlite3_prepare(db *sqlite3, zSql *u8, nByte i32, ppStmt *mut *sqlite3_stmt, pzTail **u8) -> i32
	fn sqlite3_prepare_v2(db *sqlite3, zSql *u8, nByte i32, ppStmt *mut *sqlite3_stmt, pzTail **u8) -> i32
	fn sqlite3_prepare16(db *sqlite3, zSql *void, nByte i32, ppStmt *mut *sqlite3_stmt, pzTail **void) -> i32
	fn sqlite3_prepare16_v2(db *sqlite3, zSql *void, nByte i32, ppStmt *mut *sqlite3_stmt, pzTail **void) -> i32
	fn sqlite3_sql(pStmt *sqlite3_stmt) -> *u8

	struct sqlite3_value {}

	struct sqlite3_context {}

	fn sqlite3_bind_blob(stmt *sqlite3_stmt, _ i32, _ *void, n i32, cb fn (_ *void)) -> i32
	fn sqlite3_bind_blob64(stmt *sqlite3_stmt, _ i32, _ *void, _ u64, cb fn (_ *void)) -> i32
	fn sqlite3_bind_double(stmt *sqlite3_stmt, _ i32, _ f64) -> i32
	fn sqlite3_bind_int(stmt *sqlite3_stmt, _ i32, _ i32) -> i32
	fn sqlite3_bind_int64(stmt *sqlite3_stmt, _ i32, _ i64) -> i32
	fn sqlite3_bind_null(stmt *sqlite3_stmt, _ i32) -> i32
	fn sqlite3_bind_text(stmt *sqlite3_stmt, _ i32, _ *u8, _ i32, cb fn (_ *void)) -> i32
	fn sqlite3_bind_text16(stmt *sqlite3_stmt, _ i32, _ *void, _ i32, cb fn (_ *void)) -> i32
	fn sqlite3_bind_text64(stmt *sqlite3_stmt, _ i32, _ *u8, _ u64, cb fn (_ *void), encoding u8) -> i32
	fn sqlite3_bind_value(stmt *sqlite3_stmt, _ i32, val *sqlite3_value) -> i32
	fn sqlite3_bind_zeroblob(stmt *sqlite3_stmt, _ i32, n i32) -> i32
	fn sqlite3_bind_parameter_count(stmt *sqlite3_stmt) -> i32
	fn sqlite3_bind_parameter_name(stmt *sqlite3_stmt, _ i32) -> *u8
	fn sqlite3_bind_parameter_index(stmt *sqlite3_stmt, zName *u8) -> i32
	fn sqlite3_clear_bindings(stmt *sqlite3_stmt) -> i32
	fn sqlite3_column_count(pStmt *sqlite3_stmt) -> i32
	fn sqlite3_column_name(stmt *sqlite3_stmt, N i32) -> *u8
	fn sqlite3_column_name16(stmt *sqlite3_stmt, N i32) -> *void
	fn sqlite3_column_database_name(stmt *sqlite3_stmt, _ i32) -> *u8
	fn sqlite3_column_database_name16(stmt *sqlite3_stmt, _ i32) -> *void
	fn sqlite3_column_table_name(stmt *sqlite3_stmt, _ i32) -> *u8
	fn sqlite3_column_table_name16(stmt *sqlite3_stmt, _ i32) -> *void
	fn sqlite3_column_origin_name(stmt *sqlite3_stmt, _ i32) -> *u8
	fn sqlite3_column_origin_name16(stmt *sqlite3_stmt, _ i32) -> *void
	fn sqlite3_column_decltype(stmt *sqlite3_stmt, _ i32) -> *u8
	fn sqlite3_column_decltype16(stmt *sqlite3_stmt, _ i32) -> *void
	fn sqlite3_step(stmt *sqlite3_stmt) -> i32
	fn sqlite3_data_count(pStmt *sqlite3_stmt) -> i32
	fn sqlite3_column_blob(stmt *sqlite3_stmt, iCol i32) -> *void
	fn sqlite3_column_double(stmt *sqlite3_stmt, iCol i32) -> f64
	fn sqlite3_column_int(stmt *sqlite3_stmt, iCol i32) -> i32
	fn sqlite3_column_int64(stmt *sqlite3_stmt, iCol i32) -> i64
	fn sqlite3_column_text(stmt *sqlite3_stmt, iCol i32) -> *u8
	fn sqlite3_column_text16(stmt *sqlite3_stmt, iCol i32) -> *void
	fn sqlite3_column_value(stmt *sqlite3_stmt, iCol i32) -> *sqlite3_value
	fn sqlite3_column_bytes(stmt *sqlite3_stmt, iCol i32) -> i32
	fn sqlite3_column_bytes16(stmt *sqlite3_stmt, iCol i32) -> i32
	fn sqlite3_column_type(stmt *sqlite3_stmt, iCol i32) -> i32
	fn sqlite3_finalize(pStmt *sqlite3_stmt) -> i32
	fn sqlite3_reset(pStmt *sqlite3_stmt) -> i32
	fn sqlite3_create_function(db *sqlite3, zFunctionName *u8, nArg i32, eTextRep i32, pApp *void, xFunc fn (_ *i32, _ i32, _ **i32), xStep fn (_ *i32, _ i32, _ **i32), xFinal fn (_ *i32)) -> i32
	fn sqlite3_create_function16(db *sqlite3, zFunctionName *void, nArg i32, eTextRep i32, pApp *void, xFunc fn (_ *i32, _ i32, _ **i32), xStep fn (_ *i32, _ i32, _ **i32), xFinal fn (_ *i32)) -> i32
	fn sqlite3_value_blob(val *sqlite3_value) -> *void
	fn sqlite3_value_double(val *sqlite3_value) -> f64
	fn sqlite3_value_int(val *sqlite3_value) -> i32
	fn sqlite3_value_int64(val *sqlite3_value) -> i64
	fn sqlite3_value_text(val *sqlite3_value) -> *u8
	fn sqlite3_value_text16(val *sqlite3_value) -> *void
	fn sqlite3_value_text16le(val *sqlite3_value) -> *void
	fn sqlite3_value_text16be(val *sqlite3_value) -> *void
	fn sqlite3_value_bytes(val *sqlite3_value) -> i32
	fn sqlite3_value_bytes16(val *sqlite3_value) -> i32
	fn sqlite3_value_type(val *sqlite3_value) -> i32
	fn sqlite3_value_numeric_type(val *sqlite3_value) -> i32
	fn sqlite3_aggregate_context(ctx *sqlite3_context, nBytes i32) -> *void
	fn sqlite3_user_data(ctx *sqlite3_context) -> *void
	fn sqlite3_context_db_handle(ctx *sqlite3_context) -> *sqlite3
	fn sqlite3_get_auxdata(ctx *sqlite3_context, N i32) -> *void
	fn sqlite3_set_auxdata(ctx *sqlite3_context, N i32, _ *void, cb fn (_ *void))
	fn sqlite3_result_blob(ctx *sqlite3_context, _ *void, _ i32, cb fn (_ *void))
	fn sqlite3_result_blob64(ctx *sqlite3_context, _ *void, _ u64, cb fn (_ *void))
	fn sqlite3_result_double(ctx *sqlite3_context, _ f64)
	fn sqlite3_result_error(ctx *sqlite3_context, _ *u8, _ i32)
	fn sqlite3_result_error16(ctx *sqlite3_context, _ *void, _ i32)
	fn sqlite3_result_error_toobig(ctx *sqlite3_context)
	fn sqlite3_result_error_nomem(ctx *sqlite3_context)
	fn sqlite3_result_error_code(ctx *sqlite3_context, _ i32)
	fn sqlite3_result_int(ctx *sqlite3_context, _ i32)
	fn sqlite3_result_int64(ctx *sqlite3_context, _ i64)
	fn sqlite3_result_null(ctx *sqlite3_context)
	fn sqlite3_result_text(ctx *sqlite3_context, _ *u8, _ i32, cb fn (_ *void))
	fn sqlite3_result_text64(ctx *sqlite3_context, _ *u8, _ u64, cb fn (_ *void), encoding u8)
	fn sqlite3_result_text16(ctx *sqlite3_context, _ *void, _ i32, cb fn (_ *void))
	fn sqlite3_result_text16le(ctx *sqlite3_context, _ *void, _ i32, cb fn (_ *void))
	fn sqlite3_result_text16be(ctx *sqlite3_context, _ *void, _ i32, cb fn (_ *void))
	fn sqlite3_result_value(ctx *sqlite3_context, val *sqlite3_value)
	fn sqlite3_result_zeroblob(ctx *sqlite3_context, n i32)
	fn sqlite3_create_collation(s *sqlite3, zName *u8, eTextRep i32, pArg *void, xCompare fn (_ *void, _ i32, _ *void, _ i32, _ *void) -> i32) -> i32
	fn sqlite3_create_collation_v2(s *sqlite3, zName *u8, eTextRep i32, pArg *void, xCompare fn (_ *void, _ i32, _ *void, _ i32, _ *void) -> i32, xDestroy fn (_ *void)) -> i32
	fn sqlite3_create_collation16(s *sqlite3, zName *void, eTextRep i32, pArg *void, xCompare fn (_ *void, _ i32, _ *void, _ i32, _ *void) -> i32) -> i32
	fn sqlite3_collation_needed(s *sqlite3, _ *void, cb fn (_ *void, _ *i32, _ i32, _ *u8)) -> i32
	fn sqlite3_collation_needed16(s *sqlite3, _ *void, cb fn (_ *void, _ *i32, _ i32, _ *void)) -> i32
	fn sqlite3_sleep(_ i32) -> i32
	fn sqlite3_get_autocommit(s *sqlite3) -> i32
	fn sqlite3_db_handle(stmt *sqlite3_stmt) -> *sqlite3
	fn sqlite3_next_stmt(pDb *sqlite3, pStmt *sqlite3_stmt) -> *sqlite3_stmt
	fn sqlite3_commit_hook(s *sqlite3, cb fn (_ *void) -> i32, _ *void) -> *void
	fn sqlite3_rollback_hook(s *sqlite3, cb fn (_ *void), _ *void) -> *void
	fn sqlite3_update_hook(s *sqlite3, cb fn (_ *void, _ i32, _ *u8, _ *u8, _ i32), _ *void) -> *void
	fn sqlite3_db_release_memory(s *sqlite3) -> i32
	fn sqlite3_table_column_metadata(db *sqlite3, zDbName *u8, zTableName *u8, zColumnName *u8, pzDataType **u8, pzCollSeq **u8, pNotNull *i32, pPrimaryKey *i32, pAutoinc *i32) -> i32

	struct sqlite3_module {
		iVersion      i32
		xCreate       fn (_ *i32, _ *void, _ i32, _ **u8, _ **i32, _ **u8) -> i32
		xConnect      fn (_ *i32, _ *void, _ i32, _ **u8, _ **i32, _ **u8) -> i32
		xBestIndex    fn (_ *i32, _ *i32) -> i32
		xDisconnect   fn (_ *i32) -> i32
		xDestroy      fn (_ *i32) -> i32
		xOpen         fn (_ *i32, _ **i32) -> i32
		xClose        fn (_ *i32) -> i32
		xFilter       fn (_ *i32, _ i32, _ *u8, _ i32, _ **i32) -> i32
		xNext         fn (_ *i32) -> i32
		xEof          fn (_ *i32) -> i32
		xColumn       fn (_ *i32, _ *i32, _ i32) -> i32
		xRowid        fn (_ *i32, _ *i32) -> i32
		xUpdate       fn (_ *i32, _ i32, _ **i32, _ *i32) -> i32
		xBegin        fn (_ *i32) -> i32
		xSync         fn (_ *i32) -> i32
		xCommit       fn (_ *i32) -> i32
		xRollback     fn (_ *i32) -> i32
		xFindFunction fn (_ *i32, _ i32, _ *u8, cb fn (_ *i32, _ i32, _ **i32), _ **void) -> i32
		xRename       fn (_ *i32, _ *u8) -> i32
		xSavepoint    fn (_ *i32, _ i32) -> i32
		xRelease      fn (_ *i32, _ i32) -> i32
		xRollbackTo   fn (_ *i32, _ i32) -> i32
		xShadowName   fn (_ *u8) -> i32
	}

	struct sqlite3_index_constraint {}
	struct sqlite3_index_orderby {}
	struct sqlite3_index_constraint_usage {}

	struct sqlite3_index_info {
		nConstraint      i32
		aConstraint      *sqlite3_index_constraint
		nOrderBy         i32
		aOrderBy         *sqlite3_index_orderby
		aConstraintUsage *sqlite3_index_constraint_usage
		idxNum           i32
		idxStr           *u8
		needToFreeIdxStr i32
		orderByConsumed  i32
		estimatedCost    f64
		estimatedRows    i64
		idxFlags         i32
		colUsed          u64
	}

	fn sqlite3_create_module(db *sqlite3, zName *u8, p *sqlite3_module, pClientData *void) -> i32
	fn sqlite3_create_module_v2(db *sqlite3, zName *u8, p *sqlite3_module, pClientData *void, xDestroy fn (_ *void)) -> i32
	fn sqlite3_drop_modules(db *sqlite3, azKeep **u8) -> i32

	struct sqlite3_vtab {
		pModule *sqlite3_module
		nRef    i32
		zErrMsg *u8
	}

	struct sqlite3_vtab_cursor {
		pVtab *sqlite3_vtab
	}

	fn sqlite3_declare_vtab(s *sqlite3, zSQL *u8) -> i32
	fn sqlite3_overload_function(s *sqlite3, zFuncName *u8, nArg i32) -> i32

	struct sqlite3_blob {}

	fn sqlite3_blob_open(s *sqlite3, zDb *u8, zTable *u8, zColumn *u8, iRow i64, flags i32, ppBlob **sqlite3_blob) -> i32
	fn sqlite3_blob_close(b *sqlite3_blob) -> i32
	fn sqlite3_blob_bytes(b *sqlite3_blob) -> i32
	fn sqlite3_blob_read(b *sqlite3_blob, Z *void, N i32, iOffset i32) -> i32
	fn sqlite3_blob_write(b *sqlite3_blob, z *void, n i32, iOffset i32) -> i32
	fn sqlite3_vfs_find(zVfsName *u8) -> *sqlite3_vfs
	fn sqlite3_vfs_register(v *sqlite3_vfs, makeDflt i32) -> i32
	fn sqlite3_vfs_unregister(v *sqlite3_vfs) -> i32
}

extern {
	struct sqlite3_mutex {}

	fn sqlite3_mutex_alloc(_ i32) -> *sqlite3_mutex
	fn sqlite3_mutex_free(mtx *sqlite3_mutex)
	fn sqlite3_mutex_enter(mtx *sqlite3_mutex)
	fn sqlite3_mutex_try(mtx *sqlite3_mutex) -> i32
	fn sqlite3_mutex_leave(mtx *sqlite3_mutex)

	struct sqlite3_mutex_methods {
		xMutexInit    fn () -> i32
		xMutexEnd     fn () -> i32
		xMutexAlloc   fn (_ i32) -> *i32
		xMutexFree    fn (_ *i32)
		xMutexEnter   fn (_ *i32)
		xMutexTry     fn (_ *i32) -> i32
		xMutexLeave   fn (_ *i32)
		xMutexHeld    fn (_ *i32) -> i32
		xMutexNotheld fn (_ *i32) -> i32
	}

	fn sqlite3_db_mutex(s *sqlite3) -> *sqlite3_mutex
}

extern {
	fn sqlite3_file_control(s *sqlite3, zDbName *u8, op i32, _ *void) -> i32
	fn sqlite3_test_control(op i32) -> i32

	struct sqlite3_str {}

	fn sqlite3_status(op i32, pCurrent *i32, pHighwater *i32, resetFlag i32) -> i32
	fn sqlite3_db_status(s *sqlite3, op i32, pCur *i32, pHiwtr *i32, resetFlg i32) -> i32
	fn sqlite3_stmt_status(stmt *sqlite3_stmt, op i32, resetFlg i32) -> i32

	struct sqlite3_pcache {}

	struct sqlite3_pcache_page {
		pBuf   *void
		pExtra *void
	}

	struct sqlite3_pcache_methods2 {
		iVersion   i32
		pArg       *void
		xInit      fn (_ *void) -> i32
		xShutdown  fn (_ *void)
		xCreate    fn (_ i32, _ i32, _ i32) -> *i32
		xCachesize fn (_ *i32, _ i32)
		xPagecount fn (_ *i32) -> i32
		xFetch     fn (_ *i32, _ u32, _ i32) -> *i32
		xUnpin     fn (_ *i32, _ *i32, _ i32)
		xRekey     fn (_ *i32, _ *i32, _ u32, _ u32)
		xTruncate  fn (_ *i32, _ u32)
		xDestroy   fn (_ *i32)
		xShrink    fn (_ *i32)
	}

	struct sqlite3_pcache_methods {
		pArg       *void
		xInit      fn (_ *void) -> i32
		xShutdown  fn (_ *void)
		xCreate    fn (_ i32, _ i32) -> *i32
		xCachesize fn (_ *i32, _ i32)
		xPagecount fn (_ *i32) -> i32
		xFetch     fn (_ *i32, _ u32, _ i32) -> *void
		xUnpin     fn (_ *i32, _ *void, _ i32)
		xRekey     fn (_ *i32, _ *void, _ u32, _ u32)
		xTruncate  fn (_ *i32, _ u32)
		xDestroy   fn (_ *i32)
	}

	struct sqlite3_backup {}

	fn sqlite3_backup_init(pDest *sqlite3, zDestName *u8, pSource *sqlite3, zSourceName *u8) -> *sqlite3_backup
	fn sqlite3_backup_step(b *sqlite3_backup, nPage i32) -> i32
	fn sqlite3_backup_finish(b *sqlite3_backup) -> i32
	fn sqlite3_backup_remaining(b *sqlite3_backup) -> i32
	fn sqlite3_backup_pagecount(b *sqlite3_backup) -> i32

	struct sqlite3_snapshot {
		hidden [48]u8
	}

	type sqlite3_rtree_dbl = f64

	struct sqlite3_rtree_geometry {
		pContext *void
		nParam   i32
		aParam   *sqlite3_rtree_dbl
		pUser    *void
		xDelUser fn (_ *void)
	}

	struct sqlite3_rtree_query_info {
		pContext      *void
		nParam        i32
		aParam        *sqlite3_rtree_dbl
		pUser         *void
		xDelUser      fn (_ *void)
		aCoord        *sqlite3_rtree_dbl
		anQueue       *u32
		nCoord        i32
		iLevel        i32
		mxLevel       i32
		iRowid        i64
		rParentScore  sqlite3_rtree_dbl
		eParentWithin i32
		eWithin       i32
		rScore        sqlite3_rtree_dbl
		apSqlParam    **sqlite3_value
	}

	struct Fts5Context {}

	struct Fts5PhraseIter {
		a *u8
		b *u8
	}

	struct Fts5ExtensionApi {
		iVersion           i32
		xUserData          fn (_ *i32) -> *void
		xColumnCount       fn (_ *i32) -> i32
		xRowCount          fn (_ *i32, _ *i32) -> i32
		xColumnTotalSize   fn (_ *i32, _ i32, _ *i32) -> i32
		xTokenize          fn (_ *i32, _ *u8, _ i32, _ *void, cb fn (_ *void, _ i32, _ *u8, _ i32, _ i32, _ i32) -> i32) -> i32
		xPhraseCount       fn (_ *i32) -> i32
		xPhraseSize        fn (_ *i32, _ i32) -> i32
		xInstCount         fn (_ *i32, _ *i32) -> i32
		xInst              fn (_ *i32, _ i32, _ *i32, _ *i32, _ *i32) -> i32
		xRowid             fn (_ *i32) -> i32
		xColumnText        fn (_ *i32, _ i32, _ **u8, _ *i32) -> i32
		xColumnSize        fn (_ *i32, _ i32, _ *i32) -> i32
		xQueryPhrase       fn (_ *i32, _ i32, _ *void, cb fn (_ *i32, _ *i32, _ *void) -> i32) -> i32
		xSetAuxdata        fn (_ *i32, _ *void, cb fn (_ *void)) -> i32
		xGetAuxdata        fn (_ *i32, _ i32) -> *void
		xPhraseFirst       fn (_ *i32, _ i32, _ *i32, _ *i32, _ *i32) -> i32
		xPhraseNext        fn (_ *i32, _ *i32, _ *i32, _ *i32)
		xPhraseFirstColumn fn (_ *i32, _ i32, _ *i32, _ *i32) -> i32
		xPhraseNextColumn  fn (_ *i32, _ *i32, _ *i32)
	}

	struct Fts5Tokenizer {}

	struct fts5_tokenizer {
		xCreate   fn (_ *void, _ **u8, _ i32, _ **i32) -> i32
		xDelete   fn (_ *i32)
		xTokenize fn (_ *i32, _ *void, _ i32, _ *u8, _ i32, cb fn (_ *void, _ i32, _ *u8, _ i32, _ i32, _ i32) -> i32) -> i32
	}

	struct fts5_api {
		iVersion         i32
		xCreateTokenizer fn (_ *i32, _ *u8, _ *void, _ *i32, cb fn (_ *void)) -> i32
		xFindTokenizer   fn (_ *i32, _ *u8, _ **void, _ *i32) -> i32
		xCreateFunction  fn (_ *i32, _ *u8, _ *void, _ i32, cb fn (_ *void)) -> i32
	}
}
