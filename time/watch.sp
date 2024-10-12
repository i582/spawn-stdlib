module time

pub struct StopWatch {
	start Instant
	stop  Instant
	run   bool
}

pub fn new_stopwatch() -> StopWatch {
	return StopWatch{ start: instant_now(), run: true }
}

pub fn (sw &mut StopWatch) start() {
	sw.run = true
	sw.start = instant_now()
}

pub fn (sw &mut StopWatch) stop() {
	sw.stop = instant_now()
	sw.run = false
}

pub fn (sw &StopWatch) elapsed() -> Duration {
	if sw.run {
		return instant_now().duration_since(sw.start)
	}
	return sw.stop.duration_since(sw.start)
}

pub fn (sw &mut StopWatch) reset() {
	sw.run = true
	sw.start = instant_now()
}
