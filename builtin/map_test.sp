module main

test "simple map string -> i32" {
	mut mp := map[string]i32{}
	mp["hello"] = 42
	mp["world"] = 43

	t.assert_eq(mp.len, 2, "len should be 2")
	t.assert_eq(mp.cap, 2, "cap should be 2")
	t.assert_eq(mp["hello"], 42, "hello key should be 42")
	t.assert_eq(mp["world"], 43, "world key should be 43")

	t.assert_none(mp.get("foo"), "foo key should not exist")
}

test "simple map i32 -> string" {
	mut mp := map[i32]string{}
	mp[42] = "hello"
	mp[43] = "world"
	mp[44] = "!"

	t.assert_eq(mp.len, 3, "len should be 3")
	t.assert_eq(mp.cap, 4, "cap should be 3")
	t.assert_eq(mp[42], "hello", "42 key should be hello")
	t.assert_eq(mp[43], "world", "43 key should be world")
	t.assert_eq(mp[44], "!", "44 key should be !")

	t.assert_none(mp.get(41), "41 key should not exist")

	mp.remove(42)
	t.assert_eq(mp.len, 2, "len should be 2")
	t.assert_eq(mp.cap, 4, "cap should be 3")
	t.assert_none(mp.get(42), "42 key should not exist")
}

test "map &i32 -> *u64" {
	(100000 as u64).hex()

	num1 := 10
	num2 := 20
	num3 := 30

	u64_num1 := 100000 as u64
	u64_num2 := 200000 as u64
	u64_num3 := 300000 as u64

	mut mp := map[&i32]*u64{}
	mp[&num1] = &u64_num1
	mp[&num2] = &u64_num2
	mp[&num3] = &u64_num3

	t.assert_eq(mp.len, 3, "len should be 3")
	t.assert_eq(mp.cap, 4, "cap should be 3")
	t.assert_eq(mp[&num1], &u64_num1, "num1 key should be &u64_num1")
	t.assert_eq(unsafe { *mp[&num1] }, u64_num1, "*num1 key should be u64_num1")
	t.assert_eq(mp[&num2], &u64_num2, "num2 key should be &u64_num2")
	t.assert_eq(unsafe { *mp[&num2] }, u64_num2, "*num2 key should be u64_num2")
	t.assert_eq(mp[&num3], &u64_num3, "num3 key should be &u64_num3")
	t.assert_eq(unsafe { *mp[&num3] }, u64_num3, "*num3 key should be u64_num3")
}

struct Foo {
	name string
	age  usize
}

fn (f &Foo) equal(other Foo) -> bool {
	return f.name == other.name && f.age == other.age
}

fn (f &Foo) hash() -> u64 {
	return f.name.hash() ^ f.age.hash()
}

test "map Foo -> string" {
	mut mp := map[Foo]string{}
	mp[Foo{ name: "hello", age: 42 }] = "world"
	mp[Foo{ name: "world", age: 43 }] = "hello"

	t.assert_eq(mp.len, 2, "len should be 2")
	t.assert_eq(mp.cap, 2, "cap should be 2")
	t.assert_eq(mp[Foo{ name: "hello", age: 42 }], "world", "hello key should be world")
	t.assert_eq(mp[Foo{ name: "world", age: 43 }], "hello", "world key should be hello")

	t.assert_none(mp.get(Foo{ name: "foo", age: 41 }), "foo key should not exist")
}

test "map []Foo -> string" {
	arr1 := [Foo{ name: "hello", age: 42 }, Foo{ name: "world", age: 43 }]
	arr2 := [Foo{ name: "world", age: 43 }, Foo{ name: "hello", age: 42 }]

	mut mp := map[[]Foo]string{}
	mp[arr1] = "world"
	mp[arr2] = "hello"

	t.assert_eq(mp.len, 2, "len should be 2")
	t.assert_eq(mp.cap, 2, "cap should be 2")
	t.assert_eq(mp[arr1], "world", "arr1 key should be world")
	t.assert_eq(mp[arr2], "hello", "arr2 key should be hello")

	t.assert_none(mp.get([Foo{ name: "foo", age: 41 }]), "foo key should not exist")

	t.assert_eq(mp.invert()["world"], arr1, "world value should be arr1")
	t.assert_eq(mp.invert()["hello"], arr2, "hello value should be arr2")
}

test "map values() method" {
	[1].equal([1])

	mut mp := map[string]i32{}
	mp["hello"] = 42
	mp["world"] = 43
	mp["!"] = 44

	t.assert_eq(mp.values(), [42, 43, 44], "values should be [42, 43, 44]")
}

test "map keys() method" {
	mut mp := map[string]i32{}
	mp["hello"] = 42
	mp["world"] = 43
	mp["!"] = 44

	t.assert_eq(mp.keys(), ["hello", "world", "!"], "keys should be [hello, world, !]")
}

test "map clone() method" {
	mut mp := map[string]i32{}
	mp["hello"] = 42
	mp["world"] = 43
	mp["!"] = 44
	mp.str()
	mp.equal(&mp)

	mut cloned := mp.clone()
	t.assert_eq(cloned, mp, "cloned map should be equal to original map")

	cloned.remove("hello")
	t.assert_ne(cloned, mp, "cloned map should not be equal to original map")
	t.assert_not_none(mp.get("hello"), "hello key should exist in original map")
}

test "map str() method for string -> string" {
	mut mp := { 'a': 'b', 'c': 'd' }
	t.assert_eq(mp.str(), "{
    'c': 'd'
    'a': 'b'
}", "actual value should be equal to expected")
}

test "map str() method for i32 -> string" {
	mut mp := { 10: 'b', 20: 'd' }
	t.assert_eq(mp.str(), "{
    10: 'b'
    20: 'd'
}", "actual value should be equal to expected")
}

test "map str() method for i32 -> string with multiline text" {
	mut mp := { 10: 'b\nc\nd', 20: 'e\nf\ng' }
	t.assert_eq(mp.str(), "{
    10: 'b
    c
    d'
    20: 'e
    f
    g'
}", "actual value should be equal to expected")
}

test "map str() method for i32 -> Foo" {
	mut mp := { 10: Foo{ name: 'b', age: 42 }, 20: Foo{ name: 'd', age: 43 } }
	t.assert_eq(mp.str(), "{
    10: main.Foo{
        name: 'b'
        age: 42
    }
    20: main.Foo{
        name: 'd'
        age: 43
    }
}", "actual value should be equal to expected")
}
