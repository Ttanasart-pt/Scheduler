/// @description init
#region global
	globalvar ProcessScale; 
	globalvar ProcessHeight;

	ProcessScale = 48;
	ProcessHeight = 32;
#endregion

#region algo
	enum algorithm {
		fcfs,
		priority_nonprem,
		priority_preemtive,
		round_robin
	}
	algo_names = ["FCFS", "PRI NONPREEMTIVE", "PRI PREEMTIVE", "ROUND ROBIN"];
	globalvar algo;
	algo = algorithm.round_robin;

	
	schedule_reset = function() {
		scheduled = [];
		for(var i = 0; i < ds_list_size(processes); i++)
			processes[| i].duration_left = processes[| i].getDuration();
	}
	schedule_sort = function() {
		process_sorted = ds_list_create();
		
		var start_array = [];
		for(var i = 0; i < ds_list_size(processes); i++) {
			start_array[array_length(start_array)] = processes[| i].start;	
		}
		
		for(var i = 0; i < ds_list_size(processes); i++) {
			index = array_min_index(start_array);
			ds_list_add(process_sorted, index);
			start_array[index] = 999;
		}
	}
	
	array_min_index = function(array) {
		var index = 0;
		var minn = 999;
		for(var i = 0; i < array_length(array); i++) {
			if(array[i] < minn) {
				minn = array[i];
				index = i;
			}
		}
		
		return index;
	}
	
	fcfs = function() {
		var runner = 0;
		while(!ds_list_empty(process_sorted)) {
			var index = process_sorted[| 0];
			ds_list_delete(process_sorted, 0);
			var process = processes[| index];
			
			runner = max(runner, process.start);
			scheduled[array_length(scheduled)] = [index, runner, process.getDuration()];
			wait_time += runner - process.start;
			
			runner += process.getDuration();
		}
	}
	
	pri_nonem = function() {
		var runner = processes[| process_sorted[| 0]].start;
		var queue = ds_priority_create();
		var process, index;
		
		while(ds_list_size(process_sorted) + ds_priority_size(queue) > 0) {
			while(!ds_list_empty(process_sorted) && processes[| process_sorted[| 0]].start <= runner) {
				ds_priority_add(queue, process_sorted[| 0], processes[| process_sorted[| 0]].getDuration());
				ds_list_delete(process_sorted, 0);
			}
			
			if(ds_priority_empty(queue) && !ds_list_empty(process_sorted))  {
				runner = processes[| process_sorted[| 0]].start;				
			} else {
				index = ds_priority_find_min(queue);
				process = processes[| index];
				ds_priority_delete_min(queue);
				
				runner = max(runner, process.start);
				scheduled[array_length(scheduled)] = [index, runner, process.getDuration()];
				wait_time += runner - process.start;
				runner += process.getDuration();
			}
		}
		
		ds_priority_destroy(queue);
	}
	
	pri_preem = function() {
		var runner_current = processes[| process_sorted[| 0]].start;
		var runner_next;
		var queue = ds_priority_create();
		var index, process;
		
		while(ds_list_size(process_sorted) + ds_priority_size(queue) > 0) {
			while(!ds_list_empty(process_sorted) && processes[| process_sorted[| 0]].start <= runner_current) {
				ds_priority_add(queue, process_sorted[| 0], processes[| process_sorted[| 0]].getDuration());
				ds_list_delete(process_sorted, 0);
			}
			if(!ds_priority_empty(queue)) {
				index = ds_priority_find_min(queue);
				process = processes[| index];
				
				ds_priority_delete_min(queue);
			}
			
			runner_current = max(runner_current, process.start);
			runner_next = min(runner_current + process.duration_left, ds_list_empty(process_sorted)? 999 : processes[| process_sorted[| 0]].start);
			
			scheduled[array_length(scheduled)] = [index, runner_current, runner_next - runner_current];
			process.duration_left -= runner_next - runner_current;
			
			var latest_runner = process.start;
			for(var i = 0; i < array_length(scheduled) - 1; i++) {
				if(scheduled[i][0] == index)
					latest_runner = max(latest_runner, scheduled[i][1] + scheduled[i][2]);
			}
			wait_time += runner_current - latest_runner;
			
			if(process.duration_left > 0)
				ds_priority_add(queue, index, process.duration_left);
			
			if(ds_priority_empty(queue) && !ds_list_empty(process_sorted)) 
				runner_current = processes[| process_sorted[| 0]].start;
			else
				runner_current = runner_next;
		}
		
		ds_priority_destroy(queue);
	}
	
	round_robin = function() {
		var runner = processes[| process_sorted[| 0]].start;
		var queue = ds_queue_create();
		
		while(ds_list_size(process_sorted) + ds_queue_size(queue) > 0) {
			while(!ds_list_empty(process_sorted) && processes[| process_sorted[| 0]].start <= runner) {
				ds_queue_enqueue(queue, process_sorted[| 0]);
				ds_list_delete(process_sorted, 0);
			}
			
			if(ds_queue_empty(queue) && !ds_list_empty(process_sorted)) {
				runner = processes[| process_sorted[| 0]].start;
			} else {
				var index = ds_queue_dequeue(queue);
				var process = processes[| index];
				var duration = min(rr_size, process.duration_left);
				
				process.duration_left -= duration;
				if(process.duration_left > 0)
					ds_queue_enqueue(queue, index);
				
				scheduled[array_length(scheduled)] = [index, runner, duration];
				
				var latest_runner = process.start;
				for(var i = 0; i < array_length(scheduled) - 1; i++) {
					if(scheduled[i][0] == index)
						latest_runner = max(latest_runner, scheduled[i][1] + scheduled[i][2]);
				}
				wait_time += runner - latest_runner;
			
				runner += duration;
			}
		}
	}
	
	sort_start = function() {
		schedule_reset();
		schedule_sort();
		wait_time = 0;
		
		if(ds_list_empty(processes)) return;
		switch(algo) {
			case algorithm.fcfs :				fcfs();			break;	
			case algorithm.priority_nonprem:	pri_nonem();	break;	
			case algorithm.priority_preemtive:	pri_preem();	break;	
			case algorithm.round_robin:			round_robin();	break;	
		}
	}
#endregion

process = function(_start, _finish) constructor {
	start = _start;
	start_shadow = start;
	finish = _finish;
	finish_shadow = finish;
	duration_left = 0;
	
	color = make_color_hsv(random(255), 255, 255);
	
	static getDuration = function() {
		return finish - start;	
	}
	
	static draw_partial = function(_x, _y, _duration) {
		draw_set_color(color);
		draw_roundrect_ext(_x, _y, _x + _duration * ProcessScale, _y + ProcessHeight, 32, 32, false);
		
		return [_duration * ProcessScale, ProcessHeight];
	}
	static draw = function(_x, _y) {
		return draw_partial(_x, _y, getDuration());
	}
	
	static draw_wait = function(_x, _y, _start) { 
		draw_set_color(color);
		draw_roundrect_ext(_x + start * ProcessScale, _y + ProcessHeight / 2 - 2, _x + _start * ProcessScale + 8, _y + ProcessHeight / 2 + 2, 4, 4, false);
	}
	
	static shiftProcess = function(dx) {
		var duration = getDuration();
		start_shadow = max(start_shadow + dx, 0);
		
		start = round(start_shadow);
		finish = start + duration;
		
		controller.sort_start();
	}
	
	static applyChange = function() {
		var minn = min(start, finish);
		var maxx = max(start, finish);
		
		start = minn;
		start_shadow = minn;
		
		finish = maxx;
		finish_shadow = maxx;
		
		controller.sort_start();
	}
}

#region data
	processes = ds_list_create();
	ds_list_add(processes, new process(0, 3));
	
	process_sorted = [];
	scheduled = [];
	
	rr_size = 3;
	
	sort_start();
	
	wait_time = 0;
#endregion

#region UI
	draggingIndex = -1;
	draggingX = 0;
	
	process_creating = -1;
#endregion