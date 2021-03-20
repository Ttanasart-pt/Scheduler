/// @description lerp_float
/// @param from
/// @param to
/// @param speed
/// @param *precision
function lerp_float(from, to, speed) {
    var pre = argument_count > 3? argument[3] : 0.01;

    if(abs(from - to) < pre)
        return to;
    else
        return from + (to - from) / speed * delta_time/15000;
}