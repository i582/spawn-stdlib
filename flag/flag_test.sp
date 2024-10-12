module main

import flag
import net.urllib

test "string flag, with value" {
	args := ['--file', 'name']
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', 0, '', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'name', 'actual file name is not equal to expected')
}

test "string flag, with value after =" {
	args := ['--file=name']
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', 0, '', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'name', 'actual file name is not equal to expected')
}

test "string flag, omitted" {
	args := []
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', 0, 'default', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'default', 'actual file name is not equal to expected')
}

test "short string flag, with value" {
	args := ['-f', 'name']
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', `f`, '', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'name', 'actual file name is not equal to expected')
}

test "short string flag, with value after =" {
	args := ['-f=name']
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', `f`, '', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'name', 'actual file name is not equal to expected')
}

test "short string flag, omitted" {
	args := []
	mut fs := flag.new_flag_set(args)
	mut file := ''
	fs.string_var(&mut file, 'file', `f`, 'default', 'file name')
	fs.parse().unwrap()

	t.assert_eq(file, 'default', 'actual file name is not equal to expected')
}

test "boolean flag, with true value" {
	args := ['--ci=true']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse().unwrap()

	t.assert_eq(is_ci, true, 'actual is_ci is not equal to expected')
}

test "boolean flag, with false value" {
	args := ['--ci=false']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, true, 'is CI')
	fs.parse().unwrap()

	t.assert_eq(is_ci, false, 'actual is_ci is not equal to expected')
}

test "boolean flag, without value" {
	args := ['--ci']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse().unwrap()

	t.assert_eq(is_ci, true, 'actual is_ci is not equal to expected')
}

test "boolean flag, omitted" {
	args := []
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, true, 'is CI')
	fs.parse().unwrap()

	t.assert_eq(is_ci, true, 'actual is_ci is not equal to expected')
}

test "boolean flag, with invalid value" {
	args := ['--ci=aaaa']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `aaaa` for flag --ci', 'actual error is not equal to expected')
	}

	t.assert_eq(is_ci, false, 'actual is_ci is not equal to expected')
}

test "int flag, with value" {
	args := ['--count', '42']
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 42, 'actual count is not equal to expected')
}

test "int flag, with value after =" {
	args := ['--count=42']
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 42, 'actual count is not equal to expected')
}

test "int flag, omitted" {
	args := []
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', 0, 10, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 10, 'actual count is not equal to expected')
}

test "short int flag, with value" {
	args := ['-c', '42']
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', `c`, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 42, 'actual count is not equal to expected')
}

test "float flag, with value" {
	args := ['--fraction', '5.6']
	mut fs := flag.new_flag_set(args)
	mut fraction := 0.0
	fs.float_var(&mut fraction, 'fraction', 0, 0, 'fraction value')
	fs.parse().unwrap()

	t.assert_eq(fraction, 5.6, 'actual count is not equal to expected')
}

test "float flag, with invalid value" {
	args := ['--fraction', 'x5.6']
	mut fs := flag.new_flag_set(args)
	mut fraction := 0.0
	fs.float_var(&mut fraction, 'fraction', 0, 0, 'fraction value')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `x5.6` for flag --fraction: invalid number `x5.6`', 'actual error is not equal to expected')
	}

	t.assert_eq(fraction, 0.0, 'actual count is not equal to expected')
}

test "float flag, without value" {
	args := ['--fraction']
	mut fs := flag.new_flag_set(args)
	mut fraction := 0.0
	fs.float_var(&mut fraction, 'fraction', 0, 0, 'fraction value')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag needs an argument: --fraction', 'actual error is not equal to expected')
	}

	t.assert_eq(fraction, 0.0, 'actual count is not equal to expected')
}

test "float flag, without value and with default value" {
	args := []
	mut fs := flag.new_flag_set(args)
	mut fraction := 0.0
	fs.float_var(&mut fraction, 'fraction', 0, 10.56, 'fraction value')
	fs.parse().unwrap()

	t.assert_eq(fraction, 10.56, 'actual count is not equal to expected')
}

test "short float flag, with value" {
	args := ['-f', '5.6']
	mut fs := flag.new_flag_set(args)
	mut fraction := 0.0
	fs.float_var(&mut fraction, 'fraction', `f`, 0, 'fraction value')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag needs an argument: --fraction', 'actual error is not equal to expected')
	}

	t.assert_eq(fraction, 5.6, 'actual count is not equal to expected')
}

test "only values" {
	args := ['flag.sp', 'other.sp']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse().unwrap()

	t.assert_eq(is_ci, false, 'actual is_ci is not equal to expected')
	t.assert_eq(fs.args().str(), ['flag.sp', 'other.sp'].str(), 'actual args are not equal to expected')
}

test "bad flag, short flag and long name" {
	args := ['-name', 'aaa']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'bad flag syntax: -name', 'actual error is not equal to expected')
	}

	t.assert_eq(is_ci, false, 'actual is_ci is not equal to expected')
}

test "bad flag, three dashes" {
	args := ['---name']
	mut fs := flag.new_flag_set(args)
	mut is_ci := false
	fs.bool_var(&mut is_ci, 'ci', 0, false, 'is CI')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'bad flag syntax: ---name', 'actual error is not equal to expected')
	}

	t.assert_eq(is_ci, false, 'actual is_ci is not equal to expected')
}

test "all arguments after -- are treated as values" {
	args := ['--count', '42', '--', '--some-flag', '32', '45']
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', `c`, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 42, 'actual count is not equal to expected')
	t.assert_eq(fs.args().str(), ['--some-flag', '32', '45'].str(), 'actual args are not equal to expected')
}

test "last flag value is used" {
	args := ['--count', '42', '--count', '43']
	mut fs := flag.new_flag_set(args)
	mut count := 0
	fs.int_var(&mut count, 'count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(count, 43, 'actual count is not equal to expected')
}

test "last flag value is used for boolean" {
	args := ['-g', '-g=false']
	mut fs := flag.new_flag_set(args)
	mut debug := false
	fs.bool_var(&mut debug, 'debug', `g`, false, 'debug mode')
	fs.parse().unwrap()

	t.assert_eq(debug, false, 'actual debug is not equal to expected')
}

test "forbid flag redefinition" {
	args := ['--count=10', '--count', '20']
	mut fs := flag.new_flag_set(args)
	fs.forbid_duplicates()

	count := fs.int('count', 0, 0, 'count values')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag redefined: --count', 'actual error is not equal to expected')
	}

	t.assert_eq(*count, 10, 'actual count is not equal to expected')
}

test "undefined flag" {
	args := ['--undefined=10']
	mut fs := flag.new_flag_set(args)

	count := fs.int('count', 0, 0, 'count values')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag provided but not defined: --undefined=10', 'actual error is not equal to expected')
	}

	t.assert_eq(*count, 0, 'actual count is not equal to expected')
}

test "allow undefined flag" {
	args := ['--undefined=10']
	mut fs := flag.new_flag_set(args)
	fs.allow_undefined()

	count := fs.int('count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(*count, 0, 'actual count is not equal to expected')
}

test "undefined flag with other flags" {
	args := ['--count=10', '--undefined=10', '--value=20']
	mut fs := flag.new_flag_set(args)
	fs.allow_undefined()

	count := fs.int('count', 0, 0, 'count values')
	value := fs.int('value', 0, 0, 'value')
	fs.parse().unwrap()

	t.assert_eq(*count, 10, 'actual count is not equal to expected')
	t.assert_eq(*value, 20, 'actual value is not equal to expected')
}

test "unified flags, single flag" {
	args := ['-b']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	bytes := fs.bool('bytes', `b`, false, 'show as bytes')
	fs.parse().unwrap()

	t.assert_eq(*bytes, true, 'actual bytes is not equal to expected')
}

test "unified flags, two boolean flags" {
	args := ['-cb']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.bool('count', `c`, false, 'count')
	bytes := fs.bool('bytes', `b`, false, 'show as bytes')
	fs.parse().unwrap()

	t.assert_eq(*count, true, 'actual count is not equal to expected')
	t.assert_eq(*bytes, true, 'actual bytes is not equal to expected')
}

test "unified flags, duplicate flag" {
	args := ['-cbc']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.bool('count', `c`, false, 'count')
	bytes := fs.bool('bytes', `b`, false, 'show as bytes')
	fs.parse().unwrap()

	t.assert_eq(*count, true, 'actual count is not equal to expected')
	t.assert_eq(*bytes, true, 'actual bytes is not equal to expected')
}

test "unified flags, single i32 flag with value without spaces" {
	args := ['-c10']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.int('count', `c`, 0, 'count')
	fs.parse().unwrap()

	t.assert_eq(*count, 10, 'actual count is not equal to expected')
}

test "unified flags, single i32 flag with invalid value without spaces" {
	args := ['-cAAA']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.int('count', `c`, 0, 'count')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `AAA` for flag -c', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "unified flags, single string flag with value without spaces" {
	args := ['-cnormal']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.string('count', `c`, '', 'count')
	fs.parse().unwrap()

	t.assert_eq(*count, 'normal', 'actual count is not equal to expected')
}

test "unified flags, single string flag with value after spaces" {
	args := ['-c', 'normal']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.string('count', `c`, '', 'count')
	fs.parse().unwrap()

	t.assert_eq(*count, 'normal', 'actual count is not equal to expected')
}

test "unified flags, single string flag with value after boolean flag" {
	args := ['-bcvalue']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	bytes := fs.bool('bytes', `b`, false, 'show as bytes')
	count := fs.string('count', `c`, '', 'count')
	fs.parse().unwrap()

	t.assert_eq(*bytes, true, 'actual bytes is not equal to expected')
	t.assert_eq(*count, 'value', 'actual count is not equal to expected')
}

test "unified flags, string flag without value" {
	args := ['-c']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.string('count', `c`, '', 'count')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag needs an argument: -c', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "unified flags, two boolean flags, second is undefined" {
	args := ['-cb']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.bool('count', `c`, false, 'count')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag provided but not defined: -b', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "unified flags, two i32 flags, second is undefined" {
	args := ['-cb']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.int('count', `c`, 0, 'count')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `b` for flag -c', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "unified flags, three boolean flags and second is undefined" {
	args := ['-cbg']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.bool('count', `c`, false, 'count')
	group := fs.bool('group', `g`, false, 'group')
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'flag provided but not defined: -b', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "unified flags, three strings flags and second is undefined" {
	args := ['-cbg']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	count := fs.string('count', `c`, '', 'count')
	group := fs.string('group', `g`, 'default', 'group')
	fs.parse().unwrap()

	t.assert_eq(*count, 'bg', 'actual count is not equal to expected')
	t.assert_eq(*group, 'default', 'actual group is not equal to expected')
}

test "unified flags, value without space and argument after" {
	args := ['-bg1', 'value']
	mut fs := flag.new_flag_set(args)
	fs.use_unified_flags()

	bytes := fs.bool('bytes', `b`, false, 'show as bytes')
	group := fs.string('group', `g`, 'default', 'group')
	fs.parse().unwrap()

	t.assert_eq(*bytes, true, 'actual bytes is not equal to expected')
	t.assert_eq(*group, '1', 'actual group is not equal to expected')

	t.assert_eq(fs.args().str(), ['value'].str(), 'actual args are not equal to expected')
}

test "usage for single flag" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	fs.int('count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), 'app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT>
        count values
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
', 'usage help is not equal to expected')
}

test "usage for all types flag" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	fs.int('count', 0, 0, 'count values')
	fs.string('name', 0, '', 'name')
	fs.bool('debug', 0, false, 'debug mode')
	fs.float('fraction', 0, 0.0, 'fraction value')

	fs.parse().unwrap()

	t.assert_eq(fs.usage(), 'app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --debug
        debug mode
      --count <INT>
        count values
      --name <STRING>
        name
      --fraction <FLOAT> (default: 0.000000)
        fraction value
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
', 'usage help is not equal to expected')
}

test "usage for single flag with default value" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	fs.int('count', 0, 42, 'count values')
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), 'app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT> (default: 42)
        count values
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
', 'usage help is not equal to expected')
}

test "usage for single flag with short version" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	fs.int('count', `c`, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), 'app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
  -c, --count <INT>
        count values
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
', 'usage help is not equal to expected')
}

test "usage for app with description and version" {
	mut fs := flag.new_flag_set([])
	fs.app_description('some useful app')
	fs.app_version('1.2.3')
	fs.color_mode(.never)

	fs.int('count', 0, 0, 'count values')
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), 'app v1.2.3
some useful app

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT>
        count values
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
', 'usage help is not equal to expected')
}

test "usage for single flag with multiline text" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	fs.int('count', 0, 0, 'this is a\nmultiline\ntext')
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), "app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT>
        this is a
        multiline
        text

  -h, --help
        print this help message and exit

  -v, --version
        print the version and exit

", 'usage help is not equal to expected')
}

test "usage for single flag with loooong text" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	value := "Set output style type (default: auto). Set this to 'basic' to disable output\
              coloring and interactive elements. Set it to 'full' to enable all effects even\
              if no interactive terminal was detected. Set this to 'nocolor' to keep the\
              interactive output without any colors. Set this to 'color' to keep the colors\
              without any interactive output. Set this to 'none' to disable all the output\
              of the tool."

	fs.int('count', 0, 0, value)
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), "app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT>
        Set output style type (default: auto). Set this to 'basic' to
        disable outputcoloring and interactive elements. Set it to
        'full' to enable all effects evenif no interactive terminal
        was detected. Set this to 'nocolor' to keep theinteractive
        output without any colors. Set this to 'color' to keep the
        colorswithout any interactive output. Set this to 'none' to
        disable all the outputof the tool.

  -h, --help
        print this help message and exit

  -v, --version
        print the version and exit

", 'usage help is not equal to expected')
}

test "usage for single flag with loooong text and wrap at 100 symbols" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)
	fs.help_text_wrap(100)

	value := "Set output style type (default: auto). Set this to 'basic' to disable output\
              coloring and interactive elements. Set it to 'full' to enable all effects even\
              if no interactive terminal was detected. Set this to 'nocolor' to keep the\
              interactive output without any colors. Set this to 'color' to keep the colors\
              without any interactive output. Set this to 'none' to disable all the output\
              of the tool."

	fs.int('count', 0, 0, value)
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), "app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --count <INT>
        Set output style type (default: auto). Set this to 'basic' to disable outputcoloring and interactive
        elements. Set it to 'full' to enable all effects evenif no interactive terminal was detected. Set
        this to 'nocolor' to keep theinteractive output without any colors. Set this to 'color' to keep the
        colorswithout any interactive output. Set this to 'none' to disable all the outputof the tool.

  -h, --help
        print this help message and exit

  -v, --version
        print the version and exit

", 'usage help is not equal to expected')
}

struct TestUrlFlag {
	url &mut urllib.URL = &mut urllib.URL{}
}

fn (u TestUrlFlag) url() -> urllib.URL {
	return *u.url
}

fn (u TestUrlFlag) as_str() -> string {
	return (*u.url).str()
}

fn (u &mut TestUrlFlag) set(s string) -> ! {
	if s.len == 0 {
		return error("url cannot be empty")
	}
	*u.url = urllib.parse(s)!
}

fn (u TestUrlFlag) value_type() -> string {
	return "URL"
}

test "custom url flag" {
	args := ['--url', 'https://example.com']
	mut fs := flag.new_flag_set(args)
	fs.color_mode(.never)

	url_flag := TestUrlFlag{}
	fs.custom_var(url_flag, "url", 0, "url to open")
	fs.parse().unwrap()

	t.assert_eq(url_flag.url().str(), "https://example.com", "actual url is not equal to expected")
}

test "custom url flag with invalid url value" {
	args := ['--url', 'http://aaa:aaa']
	mut fs := flag.new_flag_set(args)
	fs.color_mode(.never)

	url_flag := TestUrlFlag{}
	fs.custom_var(url_flag, "url", 0, "url to open")
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `http://aaa:aaa` for flag --url: invalid port :aaa after host', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "custom url flag with empty value" {
	args := ['--url', '']
	mut fs := flag.new_flag_set(args)
	fs.color_mode(.never)

	url_flag := TestUrlFlag{}
	fs.custom_var(url_flag, "url", 0, "url to open")
	fs.parse() or {
		t.assert_eq[string](err.msg(), 'invalid value `` for flag --url: url cannot be empty', 'actual error is not equal to expected')
		return
	}

	t.fail("expected error, but got none")
}

test "custom url flag with default value" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)

	mut default_val := urllib.parse("https://example.com").unwrap()
	url_flag := TestUrlFlag{
		url: &mut default_val
	}
	fs.custom_var(url_flag, "url", 0, "url to open")
	fs.parse().unwrap()

	t.assert_eq(url_flag.url().str(), "https://example.com", "actual url is not equal to expected")
}

test "usage for custom flag" {
	mut fs := flag.new_flag_set([])
	fs.color_mode(.never)
	fs.help_text_wrap(100)

	url_flag := TestUrlFlag{}
	fs.custom_var(url_flag, "url", 0, "url to open")
	fs.parse().unwrap()

	t.assert_eq(fs.usage(), "app v1.0.0

USAGE:
    app [OPTIONS]

OPTIONS:
      --url <URL>
        url to open
  -h, --help
        print this help message and exit
  -v, --version
        print the version and exit
", 'usage help is not equal to expected')
}
