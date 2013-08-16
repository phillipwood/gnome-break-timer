/*
 * This file is part of GNOME Break Timer.
 * 
 * GNOME Break Timer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * GNOME Break Timer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNOME Break Timer.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * A simple GTimer lookalike that keeps track of its own state.
 * This is implemented using the GTimer API, internally, so it behaves
 * exactly as described in the GTimer documentation, with two additions:
 *  - a state property to keep track of whether the timer is stopped.
 *  - a "lap" feature (start_lap, lap_time) to measure smaller time intervals
 */
public class StatefulTimer : Object {
	public enum State {
		STOPPED,
		COUNTING
	}
	public State state {public get; private set;}

	private Timer timer;
	private double lap_start;

	public StatefulTimer() {
		this.timer = new Timer();
		this.state = State.COUNTING;
	}

	public string serialize() {
		return string.joinv(",", {
			((int)this.state).to_string(),
			this.lap_start.to_string()
		});
	}

	public void deserialize(string data) {
		string[] data_parts = data.split(",");
		this.state = (State)int.parse(data_parts[0]);
		this.lap_start = double.parse(data_parts[1]);
	}

	public inline bool is_stopped() {
		return ! this.is_counting();
	}

	public bool is_counting() {
		return this.state == State.COUNTING;
	}

	public void start() {
		this.timer.start();
		this.state = State.COUNTING;
		this.lap_start = 0;
	}

	public void stop() {
		this.timer.stop();
		this.state = State.STOPPED;
	}

	public void continue() {
		this.timer.continue();
		this.state = State.COUNTING;
	}

	public double elapsed() {
		return this.timer.elapsed();
	}

	public void reset() {
		this.start();
	}

	/**
	 * Starts counting a new lap, and continues the timer if it is not
	 * already counting.
	 */
	public void start_lap() {
		if (this.is_stopped()) this.continue();
		this.lap_start = this.timer.elapsed();
	}

	/**
	 * Returns the time since the last lap was created, or the elapsed time if
	 * no laps have been created.
	 * @see start_lap
	 */
	public double lap_time() {
		return this.timer.elapsed() - this.lap_start;
	}

	/**
	 * Stops the timer, but does not advance the end time if if is already
	 * stopped.
	 */
	public void freeze() {
		if (this.state > State.STOPPED) {
			this.stop();
		}
	}
}