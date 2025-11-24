shader_type canvas_item;

#define TWO_PI 6.28318530718

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float start_angle : hint_range(0.0, 360.0) = 90.0;
uniform bool clockwise = true;

void fragment() {
	vec2 uv = UV - vec2(0.5, 0.5);
	float angle = atan(uv.y, uv.x);
	angle = (angle + PI) / TWO_PI;
	
	float start_offset = radians(start_angle) / TWO_PI;
	angle = fract(angle - start_offset);
	
	if (!clockwise) {
		angle = 1.0 - angle;
	}
	
	vec4 col = COLOR;
	col.a = step(angle, progress);
	
	COLOR = col;
}
