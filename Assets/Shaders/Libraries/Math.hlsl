#ifndef MATH
#define MATH

#define PI 3.14159265359
#define PI2 6.28318530718
#define Deg2Radius PI / 180.
#define Radius2Deg 180. / PI

#define clamp01(a) clamp(a, 0.0, 1.0)

float length2(float2 p)
{
    return sqrt(p.x * p.x + p.y * p.y);
}

float length6(float2 p)
{
    p = p * p * p; p = p * p;
    return pow(p.x + p.y, 1.0 / 6.0);
}

float length8(float2 p)
{
    p = p * p; p = p * p; p = p * p;
    return pow(p.x + p.y, 1.0 / 8.0);
}


float smin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return lerp(b, a, h) - k * h * (1.0 - h);
}
#define _m2 (float2x2(0.8, -0.6, 0.6, 0.8))
#define _m3 (float3x3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64))

float2x2 Rot2D(float a)
{
    a *= Radius2Deg;
    float ca, sa;
    sincos(a, sa, ca);
    return float2x2(ca, -sa, sa, ca);
}
float2x2 Rot2DRad(float a)
{
    float ca, sa;
    sincos(a, sa, ca);
    return float2x2(ca, -sa, sa, ca);
}


float3x3 Rotx(float a)
{
    a *= Radius2Deg;
    float ca, sa;
    sincos(a, sa, ca);
    return float3x3(1., .0, .0, .0, ca, sa, .0, -sa, ca);
}
float3x3 Roty(float a)
{
    a *= Radius2Deg;
    float ca, sa;
    sincos(a, sa, ca);
    return float3x3(ca, .0, sa, .0, 1., .0, -sa, .0, ca);
}
float3x3 Rotz(float a)
{
    a *= Radius2Deg;
    float ca, sa;
    sincos(a, sa, ca);
    return float3x3(ca, sa, .0, -sa, ca, .0, .0, .0, 1.);
}

float3x3 RotEuler(float3 ang)
{
    ang = ang * Radius2Deg;
    float2 a1 = float2(sin(ang.x), cos(ang.x));
    float2 a2 = float2(sin(ang.y), cos(ang.y));
    float2 a3 = float2(sin(ang.z), cos(ang.z));
    float3x3 m;
    m[0] = float3(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x);
    m[1] = float3(-a2.y * a1.x, a1.y * a2.y, a2.x);
    m[2] = float3(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y);
    return m;
}

float Remap(float oa, float ob, float na, float nb, float val)
{
    return (val - oa) / (ob - oa) * (nb - na) + na;
}


float3 rotate_x(const float3 v, float angle)
{
    angle *= Radius2Deg;
    float c, s;
    sincos(angle, s, c);
    return float3(v.x, v.y * c - v.z * s, v.y * s + v.z * c);
}

float3 rotate_y(const float3 v, float angle)
{
    angle *= Radius2Deg;
    float c, s;
    sincos(angle, s, c);
    return float3(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}


float3 rotate_z(const float3 v, float angle)
{
    angle *= Radius2Deg;
    float c, s;
    sincos(angle, s, c);
    return float3(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}

float2x2 inverse(float2x2 M)
{
    float2x2 inv;
    float invdet = 1.0f / determinant(M);
    inv[0][0] = M[1][1] * invdet;
    inv[1][1] = M[0][0] * invdet;
    inv[0][1] = -M[0][1] * invdet;
    inv[1][0] = -M[1][0] * invdet;
    return inv;
}


float2x3 inverse(float2x3 M)
{
    float2x2 N = float2x2(M._m00, M._m01, M._m10, M._m11);
    float2x2 Ni = inverse(N);
    float2 t = -mul(Ni, float2(M._m02, M._m12));
    float2x3 Mi = float2x3(Ni._m00, Ni._m01, t.x, Ni._m10, Ni._m11, t.y);
    return Mi;
}

float3x3 inverse(float3x3 M)
{
    float3x3 inv;
    float invdet = 1.0f / determinant(M);
    inv[0][0] = (M[1][1] * M[2][2] - M[2][1] * M[1][2]) * invdet;
    inv[0][1] = (M[0][2] * M[2][1] - M[0][1] * M[2][2]) * invdet;
    inv[0][2] = (M[0][1] * M[1][2] - M[0][2] * M[1][1]) * invdet;
    inv[1][0] = (M[1][2] * M[2][0] - M[1][0] * M[2][2]) * invdet;
    inv[1][1] = (M[0][0] * M[2][2] - M[0][2] * M[2][0]) * invdet;
    inv[1][2] = (M[1][0] * M[0][2] - M[0][0] * M[1][2]) * invdet;
    inv[2][0] = (M[1][0] * M[2][1] - M[2][0] * M[1][1]) * invdet;
    inv[2][1] = (M[2][0] * M[0][1] - M[0][0] * M[2][1]) * invdet;
    inv[2][2] = (M[0][0] * M[1][1] - M[1][0] * M[0][1]) * invdet;
    return inv;
}


float3x3 InverseTransposeMatrix(float3x3 mat)
{
    return transpose(inverse(mat));
}
#endif
