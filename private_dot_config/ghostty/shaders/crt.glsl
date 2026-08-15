// CRT monitor emulation: barrel-curved glass with soft scanlines.

const float TAU = 6.28318530718;

// Curvature per axis, bowing more vertically like real CRT glass. At
// these values a corner samples at most 1.25% past the texture edge, so
// with any window padding the overrun is plain background and no border
// masking is needed.
const vec2 CURVATURE = vec2(0.075, 0.100);

// Distance in physical pixels between scanline centers. Three keeps the
// lines visible on HiDPI displays without swallowing glyph strokes.
const float SCANLINE_PERIOD = 3.0;

// Peak darkening between scanlines. Shaders run in linear light, so
// this scales luminance directly.
const float SCANLINE_DEPTH = 0.16;

// A raised-cosine mask transmits 1 - DEPTH/2 on average; dividing that
// back out keeps overall luminance unchanged.
const float SCANLINE_GAIN = 1.0 / (1.0 - SCANLINE_DEPTH * 0.5);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // Barrel distortion: each axis stretches with the squared distance
    // from center along the opposite axis.
    vec2 centered = uv - 0.5;
    vec2 sq = centered * centered;
    uv = 0.5 + centered * (1.0 + CURVATURE * sq.yx);

    // Clamp explicitly so corners match across the OpenGL and Metal
    // backends regardless of sampler address mode.
    vec4 texel = texture(iChannel0, clamp(uv, 0.0, 1.0));

    // Raised-cosine scanlines in pixel space, so pitch is independent
    // of window size and font.
    float scanline = SCANLINE_GAIN * (1.0 - SCANLINE_DEPTH * 0.5
        * (1.0 - cos(fragCoord.y * (TAU / SCANLINE_PERIOD))));

    // iChannel0 is premultiplied: capping at alpha keeps the boosted
    // color valid over transparent backgrounds.
    fragColor = vec4(min(texel.rgb * scanline, texel.a), texel.a);
}
