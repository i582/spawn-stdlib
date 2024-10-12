module main

import text

test "wrap_string with width more than string length" {
	content := "hello"
	actual := text.wrap_string(content, 100)
	t.assert_eq(actual, "hello", 'actual should be equal to expected')
}

test "wrap_string with single word and width less than string length" {
	content := "hello"
	actual := text.wrap_string(content, 2)
	t.assert_eq(actual, "hello", 'actual should be equal to expected')
}

test "wrap_string with two words and width as first word length" {
	content := "hello world"
	actual := text.wrap_string(content, 5)
	t.assert_eq(actual, "hello
world", 'actual should be equal to expected')
}

test "wrap_string with two words and width less than first word length" {
	content := "hello world"
	actual := text.wrap_string(content, 3)
	t.assert_eq(actual, "
hello
world", 'actual should be equal to expected')
}

test "wrap_string with two words and width as first world length + 3" {
	content := "hello world"
	actual := text.wrap_string(content, 5 + 3)
	t.assert_eq(actual, "hello
world", 'actual should be equal to expected')
}

test "wrap_string for long text and width 10" {
	content := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut ante tincidunt venenatis. Proin vel blandit libero, efficitur vehicula enim. Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor ante, euismod dapibus turpis elementum non. Nunc blandit risus nibh, eget luctus elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada tempus. Morbi mattis nisi vitae massa placerat luctus. Nunc vitae turpis turpis. Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum dignissim ante, sed tincidunt metus ultrices quis."
	actual := text.wrap_string(content, 10)
	expected := "Lorem ipsum
dolor sit
amet,
consectetur
adipiscing
elit.
Aliquam
eleifend
nisl ut
ante
tincidunt
venenatis.
Proin vel
blandit
libero,
efficitur
vehicula
enim.
Aenean ut
lectus
mattis,
interdum
nisi quis,
ornare
diam.
Aenean
pharetra
tortor
ante,
euismod
dapibus
turpis
elementum
non. Nunc
blandit
risus nibh,
eget luctus
elit
viverra
sed. Morbi
sodales
hendrerit
dolor, id
efficitur
lectus
malesuada
tempus.
Morbi
mattis nisi
vitae massa
placerat
luctus.
Nunc vitae
turpis
turpis. Sed
cursus
ornare
augue, eu
dapibus
ligula
scelerisque
et. Nullam
elementum
dignissim
ante, sed
tincidunt
metus
ultrices
quis."

	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "wrap_string for long text and width 50" {
	content := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut ante tincidunt venenatis. Proin vel blandit libero, efficitur vehicula enim. Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor ante, euismod dapibus turpis elementum non. Nunc blandit risus nibh, eget luctus elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada tempus. Morbi mattis nisi vitae massa placerat luctus. Nunc vitae turpis turpis. Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum dignissim ante, sed tincidunt metus ultrices quis."
	actual := text.wrap_string(content, 50)
	expected := "Lorem ipsum dolor sit amet, consectetur adipiscing
elit. Aliquam eleifend nisl ut ante tincidunt
venenatis. Proin vel blandit libero, efficitur
vehicula enim. Aenean ut lectus mattis, interdum
nisi quis, ornare diam. Aenean pharetra tortor
ante, euismod dapibus turpis elementum non. Nunc
blandit risus nibh, eget luctus elit viverra sed.
Morbi sodales hendrerit dolor, id efficitur lectus
malesuada tempus. Morbi mattis nisi vitae massa
placerat luctus. Nunc vitae turpis turpis. Sed
cursus ornare augue, eu dapibus ligula scelerisque
et. Nullam elementum dignissim ante, sed tincidunt
metus ultrices quis."

	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "wrap_string for long text and width 80" {
	content := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut ante tincidunt venenatis. Proin vel blandit libero, efficitur vehicula enim. Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor ante, euismod dapibus turpis elementum non. Nunc blandit risus nibh, eget luctus elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada tempus. Morbi mattis nisi vitae massa placerat luctus. Nunc vitae turpis turpis. Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum dignissim ante, sed tincidunt metus ultrices quis."
	actual := text.wrap_string(content, 80)
	expected := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut
ante tincidunt venenatis. Proin vel blandit libero, efficitur vehicula enim.
Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor
ante, euismod dapibus turpis elementum non. Nunc blandit risus nibh, eget luctus
elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada
tempus. Morbi mattis nisi vitae massa placerat luctus. Nunc vitae turpis turpis.
Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum
dignissim ante, sed tincidunt metus ultrices quis."

	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "wrap_string for long text and width 150" {
	content := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut ante tincidunt venenatis. Proin vel blandit libero, efficitur vehicula enim. Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor ante, euismod dapibus turpis elementum non. Nunc blandit risus nibh, eget luctus elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada tempus. Morbi mattis nisi vitae massa placerat luctus. Nunc vitae turpis turpis. Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum dignissim ante, sed tincidunt metus ultrices quis."
	actual := text.wrap_string(content, 150)
	expected := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam eleifend nisl ut ante tincidunt venenatis. Proin vel blandit libero, efficitur
vehicula enim. Aenean ut lectus mattis, interdum nisi quis, ornare diam. Aenean pharetra tortor ante, euismod dapibus turpis elementum non. Nunc
blandit risus nibh, eget luctus elit viverra sed. Morbi sodales hendrerit dolor, id efficitur lectus malesuada tempus. Morbi mattis nisi vitae massa
placerat luctus. Nunc vitae turpis turpis. Sed cursus ornare augue, eu dapibus ligula scelerisque et. Nullam elementum dignissim ante, sed tincidunt
metus ultrices quis."

	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "indent_text for single line" {
	content := "hello"
	actual := text.indent_text(content, 4, skip_first_line: false)
	t.assert_eq(actual, "    hello", 'actual should be equal to expected')
}

test "indent_text for single line with skip first line" {
	content := "hello"
	actual := text.indent_text(content, 4, skip_first_line: true)
	t.assert_eq(actual, "hello", 'actual should be equal to expected')
}

test "indent_text for multiline string" {
	content := "hello
world"
	actual := text.indent_text(content, 4, skip_first_line: false)
	expected := "    hello
    world"
	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "indent_text for multiline string with skip first line" {
	content := "hello
world"
	actual := text.indent_text(content, 4, skip_first_line: true)
	expected := "hello
    world"
	t.assert_eq(actual, expected, 'actual should be equal to expected')
}

test "indent_text for multiline string 2" {
	content := "Foo{
    name: 'bar'
    age: 42
}"
	actual := text.indent_text(content, 4, skip_first_line: false)
	expected := "    Foo{
        name: 'bar'
        age: 42
    }"
	t.assert_eq(actual, expected, 'actual should be equal to expected')
}
