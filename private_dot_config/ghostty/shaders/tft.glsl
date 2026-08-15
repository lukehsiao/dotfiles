// TFT panel emulation: a dark one-pixel gap between square cells, like
// the visible pixel grid of an early laptop LCD.

// Edge length in pixels of one emulated LCD cell, gap included.
const float CELL_SIZE = 4.0;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // No coordinate warping here, so fetch the exact texel and skip
    // sampler normalization and filtering.
    vec4 texel = texelFetch(iChannel0, ivec2(fragCoord), 0);

    // step() is zero on the first pixel of each cell, so lit.x * lit.y
    // masks off one-pixel gridlines on both axes. Black gaps cost 44%
    // of the light (7 of every 16 pixels), but compensating with a
    // 1.78x gain would clip everything above 56% brightness.
    vec2 lit = step(1.0, mod(fragCoord, CELL_SIZE));

    // The mask only attenuates, so premultiplied alpha stays valid.
    fragColor = vec4(texel.rgb * (lit.x * lit.y), texel.a);
}
