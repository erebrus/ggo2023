shader_type canvas_item;

uniform vec3 bias = vec3(1.0, 0.25, 1.5); // Hue, Saturation (Saturation * Value), and Lightness (From LAB)
 
uniform sampler2D palette_texture;
varying flat float palette_size;
varying flat vec4 color_palette[24];
 
 
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
 
   float d = q.x - min(q.w, q.y);
   float e = 1.0e-10;
   return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
 
float rgb2lightness(vec3 c) { // adapted from lab color space equations
    vec3 tmp = vec3(
        (c.r>.04045)?pow((c.r+.055)/1.055,2.4):c.r/12.92,
        (c.g>.04045)?pow((c.g+.055)/1.055,2.4):c.g/12.92,
        (c.b>.04045)?pow((c.b+.055)/1.055,2.4):c.b/12.92
    );
 
    mat3 mat = mat3(
        vec3(0),
        vec3(0.2126,0.7152,0.0722),
        vec3(0)
    );
 
    vec3 xyz = 100.*(tmp*mat);
    vec3 n = xyz/vec3(95.047,100.,108.883),
 
    v = vec3(0, (n.y>.008856)?pow(n.y,1./3.):(7.787*n.y)+(16./116.), 0);
    return ((116.*v.y)-16.)/100.0;
}
 
void vertex() {
    palette_size = float(textureSize(palette_texture, 0).y);
 
    vec3 c;
    for (int i = 0; i < int(palette_size); i++) {
        c = texelFetch(palette_texture, ivec2(0, i), 0).rgb;
        color_palette[i] = vec4(c, rgb2lightness(c)); // pack colors from palette texture, and pre-calculate their lightnesses
    }
}
 
float square_magnitude(vec3 color) {
    return pow(color.x, 2) + pow(color.y, 2) + pow(color.z, 2);
}
 
float distance_with_hue_consideration(vec3 col_a, vec3 col_b) {
    float a = square_magnitude((col_a - col_b));
    float b = square_magnitude(((col_a - vec3(1.0, 0, 0)) - col_b));
    float c = square_magnitude(((col_a + vec3(1.0, 0, 0)) - col_b));
 
    a = min(a, b);
    return min(a, c);
}
 
float find_weighted_distance(vec4 color_a, vec3 color_b) {
    vec3 a_as_hsv = rgb2hsv(color_a.rgb);
    vec3 b_as_hsv = rgb2hsv(color_b);
    float a_lightness = color_a.a;
    float b_lightness = rgb2lightness(color_b);
 
    vec3 col1 = vec3(a_as_hsv.x, a_as_hsv.y * a_as_hsv.z, a_lightness);
    vec3 col2 = vec3(b_as_hsv.x, b_as_hsv.y * b_as_hsv.z, b_lightness);
 
    return distance_with_hue_consideration(
        col1 * bias,
        col2 * bias
    );
}
 
 
void fragment() {
    COLOR = texture(TEXTURE, UV);
 
    int index_of_closest;
    float distance_to_closest = 666.0;
    vec3 c = COLOR.rgb;
 
    for (int i = 0; i < int(palette_size); i++) {
        float d = find_weighted_distance(color_palette[i], c);
        if (d < distance_to_closest) {
            index_of_closest = i;
            distance_to_closest = d;
        }
    }
 
    COLOR.rgb = color_palette[index_of_closest].rgb;
}