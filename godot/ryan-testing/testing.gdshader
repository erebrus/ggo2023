shader_type spatial;

uniform sampler2D u_dither_tex;
uniform sampler2D u_color_tex;

//uniform int u_bit_depth;
//uniform float u_contrast;
//uniform float u_offset;
uniform float u_dither_start = 2;
uniform float u_dither_end = 4;
uniform float u_dither_size = 8;

float bayer4(float x, float y) {
	int x_int = int(4.0*x);
	int y_int = int(4.0*y);
	
	return 1.0;
}

bool dither(vec2 screen_size, vec2 uv, float threshold) {
	// Get dither sample location
	vec2 dither_uv = screen_size * uv;
	dither_uv.x = mod(dither_uv.x, u_dither_size) / u_dither_size;
	dither_uv.y = mod(dither_uv.y, u_dither_size) / u_dither_size;
	// Get dither amount
	
	// Determine dither
	return texture(u_dither_tex, dither_uv).x > threshold;
}

void fragment() {
	vec3 world_camera = (INV_VIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	
	vec2 base_uv = UV.xy;
	ALBEDO = texture(u_color_tex, base_uv).xyz;
	ALPHA = texture(u_color_tex, base_uv).a * (dither(VIEWPORT_SIZE, SCREEN_UV.xy, smoothstep(u_dither_start, u_dither_end, distance(a.xyz, world_camera))) ? 1.0 : 0.0);
}

void vertex() {
	// vec2 pos = VERTEX.xz;
	// float k = height(pos, TIME);
	// VERTEX.y = k;
	// NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}