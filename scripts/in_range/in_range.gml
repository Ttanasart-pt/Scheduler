/// @description in_range
/// @param var
/// @param from
/// @param to
/// @param *include_from
/// @param *include_to
function in_range(val, from, to) {
	var minn = min(from, to);
	var maxx = max(from, to);
	var in_from = argument_count > 3? argument[3] : false;
	var in_to = argument_count > 4? argument[4] : false;

	var pass_min = in_from? val >= minn : val > minn;
	var pass_max = in_to? val <= maxx : val < maxx;

	return pass_min && pass_max;
}