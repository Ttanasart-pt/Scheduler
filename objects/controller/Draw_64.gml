/// @description init
#region scale
	if(window_w != browser_width || window_h != browser_height - 4) {
		window_w = browser_width;
		window_h = browser_height - 4;
		window_set_size(window_w, window_h);
		room_width = window_w;
		room_height = window_h;
	}
	
	var cw = window_get_width();
	var ch = window_get_height();

	var mx = window_mouse_get_x();
	var my = window_mouse_get_y();
#endregion

#region process
	draw_set_text(f_p1, fa_center, fa_center);
	draw_set_color(c_white);
	draw_text(cw / 2, 100, "Processes");
	var xst = 80;
	var yst = 100 + 50;
	var process_amount = ds_list_size(processes);
	var process_remove = -1;
	for(var i = 0; i <= process_amount; i++) {
		#region area
			var ax1 = xst;
			var ay1 = yst;	
			var ax2 = cw - xst + 2;
			var ay2 = yst + ProcessHeight + 8 - 2;
			
			if(in_range(mx, ax1, ax2) && in_range(my, ay1, ay2)) {
				draw_set_color(c_white);
				draw_set_alpha(0.1);
				draw_roundrect_ext(ax1, ay1, ax2, ay2, 32 + 8, 32 + 8, false);
				draw_set_alpha(1);
				
				if(i == ds_list_size(processes) && mouse_check_button_pressed(mb_left)) {
					process_creating = max(0, round((mx - 120 - xst) / ProcessScale));
					ds_list_add(processes, new process(process_creating, 0));
				}
			}
		#endregion
		
		#region process
			if(i < process_amount) {
				var bx1 = 120 + xst + processes[| i].start * ProcessScale;
				var by1 = (ay1 + ay2) / 2 - ProcessHeight / 2;
		
				var size = processes[| i].draw(bx1, by1);
				var bx2 = bx1 + size[0];
				var by2 = by1 + size[1];
	
				if(in_range(mx, bx1, bx2) && in_range(my, by1, by2)) {
					if(process_creating == -1 && mouse_check_button_pressed(mb_left)) {
						draggingIndex = i;
						draggingX = mx;
					} else if (mouse_check_button_pressed(mb_right)) {
						process_remove = i;
					}
				}
	
				yst += size[1] + 8;
			}
		#endregion
	}
	
	#region modify
		if(process_creating > -1) {
			var process_end = max(0, round((mx - 120 - xst) / ProcessScale));
			processes[| ds_list_size(processes)-1].finish = process_end;
			if(mouse_check_button_released(mb_left)) {
				processes[| ds_list_size(processes) -1].applyChange();
				process_creating = -1;	
			}
		} else if(draggingIndex > -1) {
			var mouseDelta = mx - draggingX;
			draggingX = mx;
			var delta = mouseDelta / ProcessScale;
			processes[| draggingIndex].shiftProcess(delta);
			
			if(mouse_check_button_released(mb_left)) {
				processes[| draggingIndex].applyChange();
				draggingIndex = -1;
			}
		}
		
		if(process_remove > -1) {
			ds_list_delete(processes, process_remove);
			sort_start();
		}
	#endregion
#endregion

#region scheduled
	#region method
		for(var i = 0; i < 4; i++) {
			var xx = cw / 5 * (i + 1);
			var yy = ch / 2;
			
			draw_set_text(algo == i? f_p2 : f_p1, fa_center, fa_center);
			draw_set_color(c_white);
			draw_text(xx, yy, algo_names[i]);
			
			var ax1 = xx - 120;
			var ax2 = xx + 120;
			var ay1 = yy - 25;
			var ay2 = yy + 25;
			
			if(in_range(mx, ax1, ax2) && in_range(my, ay1, ay2)) {
				draw_set_color(c_white);
				draw_set_alpha(0.1);
				draw_roundrect_ext(ax1, ay1, ax2, ay2, 50, 50, false);
				draw_set_alpha(1);
				
				if(mouse_check_button_pressed(mb_left)) {
					algo = i;
					sort_start();
				}
			}
		}
	#endregion

	var xst = 80 + 120;
	var yst = ch / 2 + 50;
	
	for(var i = 0; i < ds_list_size(processes); i++) {
		#region area
			var ax1 = 80;
			var ay1 = yst;	
			var ax2 = cw - 80 + 2;
			var ay2 = yst + ProcessHeight + 8 - 2;
			
			if(in_range(mx, ax1, ax2) && in_range(my, ay1, ay2)) {
				draw_set_color(c_white);
				draw_set_alpha(0.1);
				draw_roundrect_ext(ax1, ay1, ax2, ay2, 32 + 8, 32 + 8, false);
				draw_set_alpha(1);
			}
			
			yst += ProcessHeight + 8;
		#endregion
	}
	
	var yst = ch / 2 + 50;
	for(var i = 0; i < array_length(scheduled); i++) {
		#region process
			var sh = scheduled[i];
			var proc = processes[| sh[0]];
			var star = sh[1];
			var dura = sh[2];
			
			var bx1 = xst + star * ProcessScale;
			var by1 = yst + sh[0] * (ProcessHeight + 8) + 2;
			
			proc.draw_partial(bx1, by1, dura);
			proc.draw_wait(xst, by1, star);
			
		#endregion
	}
#endregion

#region data
	draw_set_text(f_p1, fa_center, fa_center);
	draw_set_color(c_white);
	draw_text(cw / 2, ch - 50, "Wait time: " + string(wait_time));
#endregion