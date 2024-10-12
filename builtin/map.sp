module builtin

// MapKey is the interface that must be implemented by types
// to be used as keys in a Map/Set.
pub interface MapKey {
	Hashable
	Equality
}

struct Entry[TKey: MapKey, TValue] {
	next  ?&mut Entry[TKey, TValue]
	key   TKey
	value TValue
}

// Map is a hash map implementation.
pub struct Map[TKey: MapKey, TValue] {
	entries []?&mut Entry[TKey, TValue]
	cap     usize
	len     usize
}

pub fn Map.new[TKey: MapKey, TValue]() -> Map[TKey, TValue] {
	return Map[TKey, TValue]{ entries: [none], cap: 1 }
}

pub fn new_map[TKey: MapKey, TValue]() -> Map[TKey, TValue] {
	return Map[TKey, TValue]{ entries: [none], cap: 1 }
}

pub fn new_map_from_raw[TKey: MapKey, TValue](keys *TKey, values *TValue, len usize) -> Map[TKey, TValue] {
	mut map := new_map[TKey, TValue]()
	map.reserve(len)

	for i in 0 .. len {
		unsafe { map.insert(keys[i], values[i]) }
	}

	return map
}

pub fn (m &Map[TKey, TValue]) is_empty() -> bool {
	return m.len == 0
}

pub fn (m &Map[TKey, TValue]) equal(other &Map[TKey, TValue]) -> bool
	where TKey: Equality, 
          TValue: Equality
{
	if m.len != other.len {
		return false
	}

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			other_value := other.get(entry.key) or { return false }
			if entry.value != other_value {
				return false
			}
			entry = entry.next or { break }
		}
	}

	return true
}

pub fn (m &Map[TKey, TValue]) contains(key TKey) -> bool {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h) or { return false }
	for {
		if entry.key == key {
			return true
		}
		entry = entry.next or { return false }
	}
}

pub fn (m &Map[TKey, TValue]) contains_value(value TValue) -> bool
	where TValue: Equality
{
	for i in 0 .. m.cap {
		// SAFETY: we know that the entries array is not empty and at least `m.cap` long.
		//         since `h` also in the range of `m.cap`, we know that `m.entries[h]` is
		//         always valid.
		mut entry := unsafe { m.entries.fast_get(i) } or { continue }
		for {
			if entry.value == value {
				return true
			}
			entry = entry.next or { break }
		}
	}

	return false
}

pub fn (m &mut Map[TKey, TValue]) insert(key TKey, value TValue) {
	h := key.hash() as usize % m.cap

	// SAFETY: we know that the entries array is not empty and at least `m.cap` long.
	//         since `h` also in the range of `m.cap`, we know that `m.entries[h]` is
	//         always valid.
	hashed_entry := unsafe { m.entries.fast_get(h) }

	// check if we already have an entry with the same key
	if mut entry := hashed_entry {
		for {
			if entry.key == key {
				entry.value = value
				return
			}
			entry = entry.next or { break }
		}
	}

	m.ensure_cap(m.len + 1)
	h_after := key.hash() as usize % m.cap

	// SAFETY: we know that the entries array is not empty and at least `m.cap` long.
	//         since `h_after` also in the range of `m.cap`, we know that `m.entries[h_after]` is
	//         always valid.
	prev_entry := unsafe { m.entries.fast_get(h_after) }

	m.entries[h_after] = &mut Entry[TKey, TValue]{
		next: prev_entry
		key: key
		value: value
	}
	m.len++
}

pub fn (m &mut Map[TKey, TValue]) clear() {
	m.entries.clear()
	m.entries.push(none)
	m.cap = 1
	m.len = 0
}

pub fn (m &mut Map[TKey, TValue]) reserve(additional usize) {
	m.ensure_cap(m.len + additional)
}

pub fn (m &Map[TKey, TValue]) clone() -> map[TKey]TValue
	where TKey: Clone, 
          TValue: Clone
{
	mut n_map := new_map[TKey, TValue]()
	n_map.reserve(m.len)

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			n_map.insert(entry.key.clone(), entry.value.clone())
			entry = entry.next or { break }
		}
	}

	return n_map
}

pub fn (m &Map[TKey, TValue]) copy() -> map[TKey]TValue {
	mut n_map := new_map[TKey, TValue]()
	n_map.reserve(m.len)

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			n_map.insert(entry.key, entry.value)
			entry = entry.next or { break }
		}
	}

	return n_map
}

pub fn (m &Map[TKey, TValue]) get(key TKey) -> ?TValue {
	h := key.hash() as usize % m.cap

	// SAFETY: we know that the entries array is not empty and at least `m.cap` long.
	//         since `h` also in the range of `m.cap`, we know that `m.entries[h]` is
	//         always valid.
	mut entry := unsafe { m.entries.fast_get(h) }?
	for {
		if entry.key == key {
			return entry.value
		}
		entry = entry.next?
	}
}

#[track_caller]
pub fn (m &Map[TKey, TValue]) get_ptr(key TKey) -> &TValue {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h) or { panic("key not found") }
	for {
		if entry.key == key {
			// TODO: remove unsafe
			return unsafe { &entry.value }
		}
		entry = entry.next or { panic("key not found") }
	}
}

#[track_caller]
pub fn (m &Map[TKey, TValue]) get_mut_ptr(key TKey) -> &mut TValue {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h) or { panic("key not found") }
	for {
		if entry.key == key {
			// TODO: remove unsafe
			return unsafe { &mut entry.value }
		}
		entry = entry.next or { panic("key not found") }
	}
}

pub fn (m &Map[TKey, TValue]) get_mut_ptr_or_none(key TKey) -> ?&mut TValue {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h)?
	for {
		if entry.key == key {
			// TODO: remove unsafe
			return unsafe { &mut entry.value }
		}
		entry = entry.next?
	}
}

pub fn (m &Map[TKey, TValue]) get_ptr_or_none(key TKey) -> ?&TValue {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h) or { return none }
	for {
		if entry.key == key {
			// TODO: remove unsafe
			return unsafe { &entry.value }
		}
		entry = entry.next or { return none }
	}
}

#[track_caller]
pub fn (m &Map[TKey, TValue]) get_or_panic(key TKey) -> TValue {
	return m.get(key) or { panic("key not found") }
}

#[track_caller]
pub fn (m &Map[TKey, TValue]) get_ptr_or_panic(key TKey) -> &mut TValue {
	return m.get_mut_ptr_or_none(key) or { panic("key not found") }
}

// get_or_insert returns the value for the given key. If the key is not found, it
// inserts the key with the given value and returns it.
//
// Example:
// ```
// mut mp := { "a": 1, "b": 2 }
// val := mp.get_or_insert("c", 3)
// val == 3
// mp == { "a": 1, "b": 2, "c": 3 }
// ```
pub fn (m &mut Map[TKey, TValue]) get_or_insert(key TKey, value TValue) -> TValue {
	return m.get(key) or {
		m.insert(key, value)
		*m.get_ptr(key)
	}
}

pub fn (m &mut Map[TKey, TValue]) get_ptr_or_insert(key TKey, value TValue) -> &mut TValue {
	return m.get_mut_ptr_or_none(key) or {
		m.insert(key, value)
		m.get_mut_ptr(key)
	}
}

pub fn (m &mut Map[TKey, TValue]) remove(key TKey) {
	h := key.hash() as usize % m.cap

	mut entry := m.entries.fast_get(h) or { return }
	mut prev := none as ?&mut Entry[TKey, TValue]
	for {
		if entry.key == key {
			if prev == none {
				m.entries[h] = entry.next
				m.len--
				// TODO
				if true {
					return
				}
			}
			prev.unwrap().next = entry.next
			m.len--
			return
		}
		prev = entry
		entry = entry.next or { return }
	}
}

pub fn (m &Map[TKey, TValue]) filter(f fn (k TKey, v TValue) -> bool) -> Map[TKey, TValue] {
	mut n_map := new_map[TKey, TValue]()
	n_map.reserve(m.len)

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			if f(entry.key, entry.value) {
				n_map.insert(entry.key, entry.value)
			}
			entry = entry.next or { break }
		}
	}

	return n_map
}

pub fn (m &Map[TKey, TValue]) invert() -> Map[TValue, TKey]
	where TValue: MapKey
{
	mut n_map := new_map[TValue, TKey]()
	n_map.reserve(m.len)

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			n_map.insert(entry.value, entry.key)
			entry = entry.next or { break }
		}
	}

	return n_map
}

pub fn (m Map[TKey, TValue]) str() -> string
	where TKey: Display, 
          TValue: Display
{
	return m.inner_str(0)
}

pub fn (m Map[TKey, TValue]) inner_str(indent usize) -> string
	where TKey: Display, TValue: Display
{
	mut sb := []u8{cap: 100}
	sb.push(b`{`)

	if m.len > 0 {
		sb.push(b`\n`)

		for el in m.iter() {
			for _ in 0 .. indent {
				sb.push_many('   '.bytes_no_copy())
			}
			sb.push_many('    '.bytes_no_copy())

			comptime if TKey is string {
				sb.push(b`'`)
			}
			key_str := el[0].str()
			sb.push_many(key_str.bytes_no_copy())
			comptime if TKey is string {
				sb.push(b`'`)
			}

			sb.push_many(': '.bytes_no_copy())

			comptime if TValue is string {
				sb.push(b`'`)
			}

			element_str := el[1].str()

			if element_str.count('\n') > 0 {
				indent_text_impl(&mut sb, element_str, indent + 4, true)
			} else {
				sb.push_many(element_str.bytes_no_copy())
			}

			comptime if TValue is string {
				sb.push(b`'`)
			}

			sb.push_many('\n'.bytes_no_copy())
		}

		for _ in 0 .. indent {
			sb.push_many('   '.bytes_no_copy())
		}
	}

	sb.push(b`}`)
	return string.view_from_bytes(sb)
}

pub fn (m &Map[TKey, TValue]) as_pairs() -> [](TKey, TValue) {
	mut result := [](TKey, TValue){cap: m.cap}
	for k, v in m {
		result.push((k, v))
	}
	return result
}

pub fn (m &Map[TKey, TValue]) iter() -> MapIterator[TKey, TValue] {
	return MapIterator{ map: m }
}

pub fn (m &Map[TKey, TValue]) iter_mut() -> MutableMapIterator[TKey, TValue] {
	return MutableMapIterator{ map: m }
}

pub fn (m &Map[TKey, TValue]) keys() -> []TKey {
	mut keys := []TKey{cap: m.len}

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			keys.push(entry.key)
			entry = entry.next or { break }
		}
	}

	return keys
}

pub fn (m &Map[TKey, TValue]) keys_iter() -> KeysIterator[TKey, TValue] {
	return KeysIterator{ map: m }
}

pub fn (m &Map[TKey, TValue]) values() -> []TValue {
	mut values := []TValue{cap: m.len}

	for i in 0 .. m.cap {
		mut entry := m.entries.fast_get(i) or { continue }
		for {
			values.push(entry.value)
			entry = entry.next or { break }
		}
	}

	return values
}

pub fn (m &Map[TKey, TValue]) values_iter() -> ValuesIterator[TKey, TValue] {
	return ValuesIterator{ m: *m }
}

pub fn (m &mut Map[TKey, TValue]) ensure_cap(required usize) {
	if required <= m.cap {
		return
	}

	mut new_cap := if m.cap == 0 { 2 as usize } else { m.cap * 2 }
	for required > new_cap {
		new_cap = new_cap * 2
	}

	mut new_entries := []?&mut Entry[TKey, TValue]{len: new_cap, cap: new_cap}

	for i in 0 .. m.cap {
		mut cur := m.entries.fast_get(i) or { continue }
		for {
			next := cur.next
			h := cur.key.hash() as usize % new_cap
			cur.next = new_entries.fast_get(h)
			new_entries[h] = opt(cur)

			cur = next or { break }
		}
	}

	m.entries = new_entries
	m.cap = new_cap
}

struct MapIterator[TKey: MapKey, TValue] {
	map   &Map[TKey, TValue]
	entry ?&mut Entry[TKey, TValue]
	i     usize
}

pub fn (it &mut MapIterator[TKey, TValue]) next() -> ?(TKey, TValue) {
	if entry := it.entry {
		it.entry = entry.next
		return entry.key, entry.value
	}

	for i in it.i .. it.map.cap {
		it.i++
		entry := it.map.entries.fast_get(i) or { continue }
		it.entry = entry.next
		return entry.key, entry.value
	}

	return none
}

struct MutableMapIterator[TKey: MapKey, TValue] {
	map   &Map[TKey, TValue]
	entry ?&mut Entry[TKey, TValue]
	i     usize
}

pub fn (it &mut MutableMapIterator[TKey, TValue]) next() -> ?(TKey, &mut TValue) {
	if mut entry := it.entry {
		it.entry = entry.next
		return entry.key, unsafe { &mut entry.value }
	}

	for i in it.i .. it.map.cap {
		it.i++
		entry := it.map.entries.fast_get(i) or { continue }
		it.entry = entry.next
		return entry.key, unsafe { &mut entry.value }
	}

	return none
}

struct KeysIterator[TKey: MapKey, TValue] {
	map   &Map[TKey, TValue]
	entry ?&mut Entry[TKey, TValue]
	i     usize
}

pub fn (it &mut KeysIterator[TKey, TValue]) next() -> ?TKey {
	if entry := it.entry {
		key := entry.key
		it.entry = entry.next
		return entry.key
	}

	for i in it.i .. it.map.cap {
		it.i++
		entry := it.map.entries.fast_get(i) or { continue }
		it.entry = entry.next
		return entry.key
	}

	return none
}

pub struct ValuesIterator[TKey: MapKey, TValue] {
	m     Map[TKey, TValue]
	entry ?&mut Entry[TKey, TValue]
	i     usize
}

pub fn (it &mut ValuesIterator[TKey, TValue]) next() -> ?TValue {
	if entry := it.entry {
		it.entry = entry.next
		return entry.value
	}

	for i in it.i .. it.m.cap {
		it.i++
		entry := it.m.entries.fast_get(i) or { continue }
		it.entry = entry.next
		return entry.value
	}

	return none
}

fn indent_text_impl(sb &mut []u8, text string, indent usize, skip_first_line bool) {
	if !text.contains('\n') && skip_first_line {
		return
	}

	mut iter := text.split_iter('\n')
	if skip_first_line {
		if line := iter.next() {
			sb.push_many(line.bytes_no_copy())
		}
	}

	for line in iter {
		sb.push(b`\n`)
		for i in 0 .. indent {
			sb.push(b` `)
		}
		sb.push_many(line.bytes_no_copy())
	}
}
