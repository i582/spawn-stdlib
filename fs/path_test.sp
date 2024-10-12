module main

import fs
import os
import pathlib

#[run_if(!windows)]
test "real_path" {
	root := t.tmp_dir()

	cases := [
		("${root}/foo/bar/../", "${root}/foo"),
		("${root}/foo/bar/./baz", "${root}/foo/bar/baz"),
		("${root}/foo/../bar", "${root}/bar"),
		("${root}/foo/bar/baz", "${root}/foo/bar/baz"),
		("${root}/", "${root}/"),
		("${root}/foo/bar//baz", "${root}/foo/bar/baz"),
		("${root}/foo/bar/../baz/.", "${root}/foo/baz"),
		("${root}/foo/./bar/baz/../", "${root}/foo/bar"),
		("${root}/foo/bar/baz/../../qux", "${root}/foo/qux"),
		("", "real_path failed for \"\": No such file or directory"), // Expect an error or empty string handling
		(".", root), // Current working directory
		("foo/bar/../baz", "${root}/foo/baz"),
		("./foo/bar", "${root}/foo/bar"),
		("foo/../foo/bar", "${root}/foo/bar"),
		("nonexistent/path", "real_path failed for \"nonexistent/path\": No such file or directory"), // Expect an error for nonexistent paths
	]

	fs.mkdir_all("${root}/foo/bar/baz", mode: 0o755) or {}
	fs.mkdir_all("${root}/foo/baz", mode: 0o755) or {}
	fs.mkdir_all("${root}/foo/qux", mode: 0o755) or {}
	fs.mkdir_all("${root}/bar", mode: 0o755) or {}

	wd := os.get_wd()

	// change the working directory to the temporary directory
	// so that we can test relative paths
	os.chdir(root).unwrap()

	for i, case in cases {
		path, expected := case[0], case[1]
		result := fs.real_path(path) or {
			err.msg()
		}
		t.assert_eq(pathlib.relative(root, result), pathlib.relative(root, expected), 'actual should be equal to expected for ${i + 1} case')
	}

	// revert to the original working directory
	// since we run tests in one process
	os.chdir(wd).unwrap()
}
