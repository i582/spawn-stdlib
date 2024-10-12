module main

import fs
import pathlib

#[run_if(!windows)] // symbolic links are not supported by `is_dir` yet
test "is_dir function" {
	root := t.tmp_dir()
	symlink_path_to_dir := pathlib.join(root, 'current_dir_symlink1')
	fs.symlink($DIR, symlink_path_to_dir).unwrap()

	symlink_path_to_file := pathlib.join(root, 'current_file_symlink1')
	fs.symlink($FILE, symlink_path_to_file).unwrap()

	cases := [
		($DIR, true),
		($SPAWN_ROOT, true),
		(pathlib.dir($SPAWN_COMPILER), true),
		($SPAWN_COMPILER, false),
		($FILE, false),
		// since this symlink points to directory, is_dir should return true
		(symlink_path_to_dir, true),
		// since this symlink points to file, is_dir should return true
		(symlink_path_to_file, false),
	]

	for case in cases {
		path, is_directory := case
		t.assert_eq(fs.is_dir(path), is_directory, 'actual result should be equal to expected')
	}

	fs.remove(symlink_path_to_dir).unwrap()
	fs.remove(symlink_path_to_file).unwrap()
}

test "mkdir existing directory" {
	fs.mkdir($DIR, 0o755) or {
		t.assert_true(err.msg().contains('File exists'), 'actual error should be equal to expected')
		return
	}

	t.fail('mkdir should fail')
}

test "mkdir existing file" {
	fs.mkdir($FILE, 0o755) or {
		t.assert_true(err.msg().contains('File exists'), 'actual error should be equal to expected')
		return
	}

	t.fail('mkdir should fail')
}

test "mkdir current directory" {
	fs.mkdir('.', 0o755).unwrap()
	t.assert_eq(fs.is_dir('.'), true, 'actual result should be equal to expected')
}

test "mkdir non-existing directory" {
	root := t.tmp_dir()

	path := pathlib.join(root, 'mkdir_dir')
	fs.mkdir(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
}

test "mkdir directory with spaces" {
	root := t.tmp_dir()

	path := pathlib.join(root, 'my cool directory')
	fs.mkdir(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
}

test "mkdir directory with cyrillic" {
	root := t.tmp_dir()

	path := pathlib.join(root, 'моя любимая директория UwU')
	fs.mkdir(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
}

test "mkdir_all single directory" {
	root := t.tmp_dir()

	path := pathlib.join(root, 'mkdir_dir')
	fs.mkdir_all(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
}

test "mkdir_all several directories" {
	root := t.tmp_dir()

	path := pathlib.join(root, 'mkdir_dir/next_dir')
	fs.mkdir_all(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')
	t.assert_eq(fs.is_dir(pathlib.dir(path)), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
	fs.remove(pathlib.dir(path)).unwrap()
}

test "mkdir_all several directories when middle one is already created" {
	root := t.tmp_dir()

	fs.mkdir(pathlib.join(root, 'mkdir_dir'), 0o755).unwrap()

	path := pathlib.join(root, 'mkdir_dir/next_dir')
	fs.mkdir_all(path, 0o755).unwrap()

	t.assert_eq(fs.is_dir(path), true, 'actual result should be equal to expected')
	t.assert_eq(fs.is_dir(pathlib.dir(path)), true, 'actual result should be equal to expected')

	fs.remove(path).unwrap()
	fs.remove(pathlib.dir(path)).unwrap()
}
