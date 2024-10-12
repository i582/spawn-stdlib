module benchmark

import time
import runtime
import strings

pub fn bench(name string, count usize, cb fn (_ &Benchmark)) {
	for i in 0 .. count {
		mut b := Benchmark.new(name)
		b.run(cb)
		print(name)
		print('\t')
		print(b.result.str())
		println()
	}
}

pub type MemoryFootprint = i64

pub fn (f MemoryFootprint) str() -> string {
	m := f as i64

	if f < 1024 {
		return '${m}b'
	}
	if f < 1024 * 1024 {
		return '${(m / 1024)}kb'
	}
	return '${(m / (1024 * 1024))}mb'
}

pub struct BenchmarkResult {
	count_n      i64
	duration     time.Duration
	total_allocs i64
	total_bytes  MemoryFootprint
}

pub fn (r BenchmarkResult) time_per_op() -> time.Duration {
	return r.duration / r.count_n
}

pub fn (r BenchmarkResult) allocs_per_op() -> i64 {
	return r.total_allocs / r.count_n
}

pub fn (r BenchmarkResult) bytes_per_op() -> MemoryFootprint {
	return r.total_bytes / r.count_n
}

pub fn (r BenchmarkResult) str() -> string {
	mut res := strings.new_builder(50)

	res.write_str(r.count_n.str().pad_start(8, b` `))

	res.write_str('\t')
	res.write_str(r.time_per_op().str())
	res.write_str('/op')

	res.write_str('\t')
	res.write_str(r.bytes_per_op().str())
	res.write_str('/op')

	res.write_str('\t')
	res.write_str(r.allocs_per_op().str())
	res.write_str(' allocs/op')

	return res.str_view()
}

pub struct Benchmark {
	name    string
	count_n i64

	timer_on bool

	bench_time time.Duration

	start        time.SystemTime
	start_allocs i64
	start_bytes  MemoryFootprint

	total_allocs i64
	total_bytes  MemoryFootprint

	duration time.Duration

	result BenchmarkResult

	warmup_count i64
}

pub fn Benchmark.new(name string) -> Benchmark {
	return Benchmark{ name: name, warmup_count: 5, bench_time: 1 * time.SECOND }
}

pub fn (b &mut Benchmark) start_timer() {
	if b.timer_on {
		return
	}

	b.timer_on = true
	b.start = time.system_now()
	b.start_allocs = runtime.get_count_alloc()
	b.start_bytes = runtime.get_total_alloc()
}

pub fn (b &mut Benchmark) stop_timer() {
	if !b.timer_on {
		return
	}

	b.timer_on = false
	b.duration = time.system_now().duration_since(b.start)
	b.total_allocs = b.total_allocs + (runtime.get_count_alloc() - b.start_allocs)
	b.total_bytes = b.total_bytes + (runtime.get_total_alloc() - b.start_bytes)
}

pub fn (b &mut Benchmark) reset_timer() {
	if b.timer_on {
		b.start_allocs = runtime.get_count_alloc()
		b.start_bytes = runtime.get_total_alloc()
		b.start = time.system_now()
	}
	b.timer_on = false
	b.duration = 0 as time.Duration
	b.total_allocs = 0
	b.total_bytes = 0
}

pub fn (b &mut Benchmark) run_n(n i64, cb fn (_ &Benchmark)) {
	runtime.gc()
	b.count_n = n
	b.reset_timer()
	b.start_timer()
	cb(b)
	b.stop_timer()
}

pub fn (b &mut Benchmark) run(cb fn (_ &Benchmark)) {
	b.do_bench(cb)
}

pub fn (b &mut Benchmark) do_bench(cb fn (_ &Benchmark)) -> BenchmarkResult {
	dur := b.bench_time
	for count_n := 1 as i64; b.duration < dur && count_n < 1e9 as i64; {
		last := count_n

		goalns := dur.as_nanos()
		prev_iters := b.count_n
		mut prevns := b.duration.as_nanos()
		if prevns <= 0 {
			prevns = 1
		}
		count_n = goalns * prev_iters / prevns
		count_n = count_n + count_n / 5
		count_n = count_n.min(100 as i64 * last)
		count_n = count_n.max(last + 1)
		count_n = count_n.min(1e9 as i64)

		b.run_n(count_n, cb)
	}

	b.result = BenchmarkResult{
		count_n: b.count_n
		duration: b.duration
		total_allocs: b.total_allocs
		total_bytes: b.total_bytes
	}

	return b.result
}

pub fn (b &Benchmark) elapsed() -> time.Duration {
	mut dur := b.duration
	if b.timer_on {
		dur = dur + time.system_now().duration_since(b.start)
	}
	return dur
}
