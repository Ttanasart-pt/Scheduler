/// @description  @function draw_9patch()
/// @param x
/// @param y
/// @param w
/// @param h
/// @param sprite
/// @param alpha
/// @param scale
/// @param color
/// @param mouse
/// @param hovercolor

function draw_9patch() {
	var xx = argument[0];
	var yy = argument[1];
	var ww = argument[2];
	var hh = argument[3];
	var spr = argument[4];
	var aa = argument[5];
	var ss = argument[6];
	var cc = argument_count >= 8?    argument[7] : c_white;
	var mouse = argument_count >= 9? argument[8] : [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)];
	var ch = argument_count >= 10?   argument[9] : merge_color(cc, c_white, .2);

	var over = (in_range(mouse[0], xx, xx + ww) && in_range(mouse[1], yy, yy + hh)) && argument_count >= 9;
	if(over) cc = ch;

	var width = sprite_get_width(spr) * ss;
	var heigh = sprite_get_height(spr) * ss;

	var scale_width = (ww / width - 2) * ss;
	var scale_heigh = (hh / heigh - 2) * ss;

	draw_sprite_ext(spr, 0, xx, yy, ss, ss, 0, cc, aa);								//Top left
	draw_sprite_ext(spr, 2, xx + ww - width, yy, ss, ss, 0, cc, aa);				//Top right
	draw_sprite_ext(spr, 6, xx, yy + hh - heigh, ss, ss, 0, cc, aa);				//Bottom left
	draw_sprite_ext(spr, 8, xx + ww - width, yy + hh - heigh, ss, ss, 0, cc, aa);	//Bottom right

	draw_sprite_ext(spr, 1, xx + width, yy, scale_width, ss, 0, cc, aa);				//Top
	draw_sprite_ext(spr, 7, xx + width, yy + hh - heigh, scale_width, ss, 0, cc, aa);	//Bottom

	if(hh > heigh * 2){
	    draw_sprite_ext(spr, 3, xx, yy + heigh, ss, scale_heigh, 0, cc, aa);					//Left
	    draw_sprite_ext(spr, 5, xx + ww - width, yy + heigh, ss, scale_heigh, 0, cc, aa);		//Right
    
	    draw_sprite_ext(spr, 4, xx + width, yy + heigh, scale_width, scale_heigh, 0, cc, aa);	//Center
	}

	return over;
}