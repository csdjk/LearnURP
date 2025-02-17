#version 450

layout(constant_id = 4) const uint _2 = 0u;

struct _112
{
    float _m0;
    float _m1;
    float _m2;
    float _m3;
};

const float _1431[4] = float[](-0.01171875, 0.00390625, 0.01171875, -0.00390625);

layout(set = 3, binding = 0, std140) uniform _6_8
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec3 _m4;
    vec4 _m5;
    vec4 _m6;
    vec4 _m7;
    vec4 _m8;
} _8;

layout(set = 3, binding = 3, std140) uniform _13_15
{
    vec4 _m0[6];
    vec4 _m1[4];
    vec4 _m2[4];
    vec4 _m3[4];
    vec4 _m4[4];
} _15;

layout(set = 3, binding = 4, std140) uniform _18_20
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    vec4 _m6;
    vec4 _m7[8];
    vec4 _m8[8];
    vec4 _m9[8];
    vec4 _m10[8];
    vec4 _m11;
    vec4 _m12;
    vec4 _m13;
    vec4 _m14;
    vec4 _m15;
    vec4 _m16;
    vec4 _m17;
    vec4 _m18;
    vec4 _m19;
} _20;

layout(set = 3, binding = 2, std140) uniform _22_24
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5[4];
    vec4 _m6[4];
    vec4 _m7[4];
    vec4 _m8[4];
    int _m9;
    vec4 _m10;
    vec4 _m11;
} _24;

layout(set = 1, binding = 1, std140) uniform _107_109
{
    float _m0;
    float _m1;
    float _m2;
    float _m3;
    float _m4;
    float _m5;
    float _m6;
    float _m7;
    vec3 _m8;
    vec3 _m9;
    vec3 _m10;
    vec3 _m11;
    vec3 _m12;
    vec3 _m13;
    float _m14;
    vec4 _m15[4];
    vec4 _m16[4];
    vec4 _m17;
} _109;

layout(set = 0, binding = 0, std140) uniform _113_115
{
    vec4 _m0;
    uint _m1;
    uint _m2;
    int _m3;
    int _m4;
    ivec4 _m5;
    uvec4 _m6;
    _112 _m7;
} _115;

layout(set = 2, binding = 0) uniform sampler2D _28;
layout(set = 2, binding = 1) uniform sampler2D _29;
layout(set = 2, binding = 2) uniform sampler3D _33;
layout(set = 2, binding = 3) uniform sampler3D _34;
layout(set = 2, binding = 4) uniform sampler2D _35;

layout(location = 0) in vec4 _37;
layout(location = 1) in vec3 _39;
layout(location = 0) out vec4 _41;
vec3 _43;
bool _46;
vec4 _48;
float _50;
vec4 _51;
bvec3 _54;
vec4 _55;
bvec3 _56;
vec3 _57;
float _58;
float _59;
vec4 _60;
vec2 _63;
vec4 _64;
bool _65;
vec3 _66;
bool _67;
vec3 _68;
float _69;
bool _70;
float _71;
bool _72;
float _73;
vec2 _74;
float _75;
float _76;
vec3 _77;
float _78;
vec3 _79;
vec3 _80;
vec3 _81;
bool _82;
float _83;
bool _84;
vec2 _85;
bool _86;
float _87;
float _88;
vec2 _89;
float _90;
bool _91;
float _92;
bool _93;
float _94;
float _95;
bool _96;
bool _97;
float _98;
float _99;
float _100;
float _101;
bool _102;
float _103;
bool _104;
float _105;
bool _106;
float _1449;
uint _1453;
vec3 _1459 = vec3(255.0);

void _118()
{
    vec4 debug = vec4(0,0,0,1);
    _43 = (-_39) + _8._m4;
    _95 = dot(_43, _43);
    _95 = sqrt(_95);
    _43 = (-_43) / vec3(_95);
    vec2 _141 = _37.xy / _37.ww;
    _48 = vec4(_141.x, _141.y, _48.z, _48.w);
    vec3 _151 = _8._m0.zyx * vec3(0.100000001490116119384765625);
    _51 = vec4(_151.x, _151.y, _151.z, _51.w);
    vec3 _156 = fract(_51.xyz);
    _51 = vec4(_156.x, _156.y, _156.z, _51.w);
    _85 = _48.xy * _109._m17.zw;
    _95 = dot(_51.zyx, vec3(12.98980045318603515625, 78.233001708984375, 173.8899993896484375));
    _95 = sin(_95);
    _95 *= 43758.546875;
    _55.x = fract(_95);
    _95 = dot(_51.xyz, vec3(12.98980045318603515625, 78.233001708984375, 173.8899993896484375));
    _95 = sin(_95);
    _95 *= 43758.546875;
    _55.y = fract(_95);
    _85 = (_85 * vec2(0.03125)) + _55.xy;
    _51 = ((-_109._m17.xyxy) * vec4(0.5, 0.5, -0.5, 0.5)) + _48.xyxy;
    _51 = (_51 * _24._m11.xyxy) + _24._m11.zwzw;
    _95 = textureLod(_28, _51.xy, 0.0).x;
    _51.x = textureLod(_28, _51.zw, 0.0).x;
    _55 = ((-_109._m17.xyxy) * vec4(0.5, -0.5, -0.5, -0.5)) + _48.xyxy;
    _55 = (_55 * _24._m11.xyxy) + _24._m11.zwzw;
    _73 = textureLod(_28, _55.xy, 0.0).x;
    _87 = textureLod(_28, _55.zw, 0.0).x;
    vec2 _269 = (_48.xy * _24._m11.xy) + _24._m11.zw;
    _55 = vec4(_269.x, _269.y, _55.z, _55.w);
    _98 = textureLod(_28, _55.xy, 0.0).x;
    _55.x = max(_98, _87);
    _55.x = max(_73, _55.x);
    _55.x = max(_51.x, _55.x);
    _55.x = max(_95, _55.x);
    _55.x = (_8._m7.z * _55.x) + _8._m7.w;
    _55.x = 1.0 / _55.x;
    _74.x = dot(_15._m4[2u].xyz, _43);
    _55.x /= _74.x;
    _87 = min(_98, _87);
    _73 = min(_87, _73);
    _51.x = min(_73, _51.x);
    _95 = min(_95, _51.x);
    _95 = (_8._m7.z * _95) + _8._m7.w;
    _95 = 1.0 / _95;
    _95 /= _74.x;
    _51 = vec4(1.0) / _109._m8.yxyz;
    _74 = (_51.xx * vec2(0.984375, 0.015625)) + (-_109._m9.yy);
    _54.x = 0.00999999977648258209228515625 < _43.y;
    _74 += (-_8._m4.yy);
    _74 /= _43.yy;
    _74.x = min(_74.x, _55.x);
    _51.x = _54.x ? _74.x : _55.x;
    _56.x = _43.y < (-0.00999999977648258209228515625);
    _74.x = min(_74.y, _51.x);
    _51.x = _56.x ? _74.x : _51.x;
    _51.x = max(_51.x, 0.0);
    _51.x = min(_51.x, _109._m1);
    _50 = texture(_29, _48.xy).x;
    _50 = max(_50, 8.0);
    _71 = dot(_20._m0.xyz, _43);
    _55.x = ((-_109._m5) * _109._m5) + 1.0;
    _74.x = (_109._m5 * _109._m5) + 1.0;
    _71 = dot(vec2(_71), vec2(_109._m5));
    _71 = (-_71) + _74.x;
    _71 = log2(_71);
    _71 *= 1.5;
    _71 = exp2(_71);
    _71 = _55.x / _71;
    _71 *= 0.78537499904632568359375;
    vec3 _490 = _109._m8.xzy * _109._m9.xzy;
    _55 = vec4(_490.x, _490.y, _490.z, _55.w);
    _99 = _109._m3 * 64.0;
    _57 = _109._m11;
    _100 = 1.0;
    _58 = 1.0;
    _75 = 0.0;
    _89 = vec2(_50);
    _59 = _50;
    _76 = 0.0;
    
    _73 = _109._m14 * 0.300000011920928955078125;
    _87 = _100;
    _60.w = _58;
    _98 = _75;
    _57 = vec3(_89.x, _89.y, _57.z);
    _60.y = _59;
    _88 = _76;
    
    // _41 = vec4(_57.x*0.2,0,0,1);
    // return;
    while (true)
    {
        // 最大步进次数
        _91 = _88 < 96.0;

        _102 = _57.x < _51.x;
        _91 = _102 && _91;
        _102 = 0.001000000047497451305389404296875 < _60.w;
        _91 = _102 && _91;
        if (!_91)
        {
            // _41 = vec4(_60.w,0,0,1);
            // return;
            break;
        }
        _91 = _51.x < _57.y;
        _90 = _91 ? _51.x : _57.y;
        _63 = (vec2(_90) * _43.xy) + _8._m4.xy;
        _101 = (-_57.x) + _90;
        _101 = max(_101, 1.0);
        _101 = min(_87, _101);
        _63 = _85 * _63;
        _63.x = dot(_63, vec2(12.98980045318603515625, 78.233001708984375));
        _63.x = sin(_63.x);
        _63.x *= 43758.546875;
        _63.x = fract(_63.x);
        _79.x = (_63.x * (-_101)) + _90;
        _79 = (_79.xxx * _43.xzy) + _8._m4.xzy;
        _79 = (_79 * _109._m8.xzy) + _55.xyz;
        _80 = textureLod(_33, _79, 0.0).xyz;
        // x: debsity y: sdf
        _67 = 9.9999997473787516355514526367188e-05 < _80.x;
        // _73 和depth有关
        _66.x = _67 ? _73 : 0.0;
        _79.x = _80.x + (-_66.x);
        _79.x = clamp(_79.x, 0.0, 1.0);
        _67 = 0.00999999977648258209228515625 < _79.x;
        _79.x = _67 ? _79.x : 0.0;
        _79.x *= _109._m0;
        _94 = (_80.y * 64.0) + (-32.0);
        _67 = 8.0 < _94;
        _79.x = _67 ? 0.0 : _79.x;
        _67 = _109._m6 < _60.w;
        _66.x = _67 ? _90 : _60.y;
        _82 = 0.001000000047497451305389404296875 < _79.x;
        if (_82)
        {
            _82 = 8.0 < _87;
            if (_82)
            {
                _81.x = _88 + 1.0;
                _87 = 2.0;
                _57.y = _57.x;
                _60.y = _66.x;
                _88 = _81.x;
                continue;
            }
            _101 = (_63.x * (-_101)) + _101;
            _101 = max(_101, 1.0);
            _63.x = _99 * _80.z;
            _105 = _79.x * (-2.8853900432586669921875);
            _105 = exp2(_105);
            _105 = (-_105) + 1.0;
            _105 = _71 * _105;
            _63.x *= (-1.44269502162933349609375);
            _63.x = exp2(_63.x);
            _63.x *= _105;
            _101 *= (-_79.x);
            _101 *= 1.44269502162933349609375;
            _101 = exp2(_101);
            _63.x = ((-_63.x) * _101) + _63.x;
            _63.x /= _79.x;
            _98 = (_60.w * _63.x) + _98;
            _60.w = _101 * _60.w;
        }
        _101 = _87 * 1.10000002384185791015625;
        _87 = min(_101, 64.0);
        _101 = max(_87, abs(_94));
        _57.y = _101 + _90;
        _57.x = _90;
        _88 += 1.0;
        _60.y = _66.x;
    }
    _71 = log2(_98);
    _71 *= _109._m4;
    _71 = exp2(_71);
    _60.x = min(_71, 4.0);
    _72 = _109._m2 < _51.x;
    _71 = _72 ? 1023.0 : _51.x;
    _86 = _60.y < _95;
    _97 = 128.0 < _95;
    _95 = _97 ? 1023.0 : _95;
    _60.z = _86 ? _95 : _71;
    _95 = (-_50) + _57.y;
   
    _43 = _60.xyz + vec3(1.0);
    _43 = log2(_43);
    vec3 _1415 = _43 * vec3(0.5, 0.100000001490116119384765625, 0.100000001490116119384765625);
    _60 = vec4(_1415.x, _1415.y, _1415.z, _60.w);
    _41 = _60.xwyz;

    // _41 = debug;
}

void main()
{
    vec3 _1456 = vec3(0.0);
    _118();
    
}

