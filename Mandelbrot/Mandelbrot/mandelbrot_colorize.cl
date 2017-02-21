//
//  mandelbrot_colorize.cl
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/9/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

const sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_FILTER_NEAREST;

kernel void mandelbrot_colorize(write_only image2d_t output, global uint *iterArr, global float* colorSet, int iterLimit, int width, int height)
{
    size_t x = get_global_id(1);
    size_t y = get_global_id(0);
    uint i = iterArr[x+y*height];
    
    float r, g, b;
    if (i >= iterLimit-1) {
        r = 0.0;
        g = 0.0;
        b = 0.0;
    } else {
        int j = i*3;
        r = colorSet[j];
        g = colorSet[j+1];
        b = colorSet[j+2];
    }
    write_imagef(output, (int2)(x,y), (float4)(r, g, b, 1.0));
}

kernel void mandelbrot_iterations(global uint* output, double width, double height, int iterLimit, double x1, double x2, double y1, double y2)
{
    size_t x = get_global_id(1);
    size_t y = get_global_id(0);
    
    double cr = (double)x1 + ((double)x/(double)width) *((double)x2-(double)x1);
    double ci = (double)y2 + ((double)y/(double)height)*((double)y1-(double)y2);
    
    double zr = 0.0;
    double zi = 0.0;
    double nzr = 0.0;
    double nzi = 0.0;
    
    int i;
    for (i=1; i<iterLimit; i++) {
        nzr = zr*zr - zi*zi + cr;
        nzi = zr*zi + zr*zi + ci;
        zr = nzr;
        zi = nzi;
        if (zr*zr+zi*zi > 4) {
            break;
        }
    }
    
    int k = (y*int(height)+x);
    output[k] = i;
}

kernel void mandelbrot_iteration_and_colorize(write_only image2d_t outImage, global uint* outIterArr, global float* colorSet, double width, double height, int iterLimit, double x1, double x2, double y1, double y2)
{
    size_t x = get_global_id(1);
    size_t y = get_global_id(0);
    
    double cr = (double)x1 + ((double)x/(double)width) *((double)x2-(double)x1);
    double ci = (double)y2 + ((double)y/(double)height)*((double)y1-(double)y2);
    
    double zr = 0.0;
    double zi = 0.0;
    double nzr = 0.0;
    double nzi = 0.0;
    
    int i;
    for (i=1; i<iterLimit; i++) {
        nzr = zr*zr - zi*zi + cr;
        nzi = zr*zi + zr*zi + ci;
        zr = nzr;
        zi = nzi;
        if (zr*zr+zi*zi > 4) {
            break;
        }
    }
    
    float r, g, b;
    if (i >= iterLimit-1) {
        r = 0.0;
        g = 0.0;
        b = 0.0;
    } else {
        int j = i*3;
        r = colorSet[j];
        g = colorSet[j+1];
        b = colorSet[j+2];
    }
    
    int k = (y*int(height)+x);
    outIterArr[k] = i;
    write_imagef(outImage, (int2)(x,y), (float4)(r, g, b, 1.0));
}

kernel void julia_iterations(global uint* output, double width, double height, int iterLimit, double x1, double x2, double y1, double y2, double seedr, double seedi)
{
    size_t x = get_global_id(1);
    size_t y = get_global_id(0);
    
    double zr = (double)x1 + ((double)x/(double)width) *((double)x2-(double)x1);
    double zi = (double)y2 + ((double)y/(double)height)*((double)y1-(double)y2);
    double nzr = 0.0;
    double nzi = 0.0;
    
    int i;
    for (i=1; i<iterLimit; i++) {
        nzr = zr*zr - zi*zi + seedr;
        nzi = zr*zi + zr*zi + seedi;
        zr = nzr;
        zi = nzi;
        if (zr*zr+zi*zi > 4) {
            break;
        }
    }
    
    int k = (y*int(height)+x);
    output[k] = i;
}

















// Increment U
uint4 inc128(uint4 u)
{
    // Compute all carries to add
    int4 h = (u == (uint4)(0xFFFFFFFF));
    // Note that == sets ALL bits if true [6.3.d]
    uint4 c = (uint4)(h.y&h.z&h.w&1,h.z&h.w&1,h.w&1,1);
    return u+c;
}


// Return -U
uint4 neg128(uint4 u)
{
    // (1 + ~U) is two's complement
    return inc128(u ^ (uint4)(0xFFFFFFFF));
}


// Return U+V
uint4 add128(uint4 u,uint4 v)
{
    uint4 s = u+v;
    uint4 h = (uint4)(s < u);
    // Carry from U+V
    uint4 c1 = h.yzwx & (uint4)(1,1,1,0);
    h = (uint4)(s == (uint4)(0xFFFFFFFF));
    // Propagated carry
    uint4 c2 = (uint4)((c1.y|(c1.z&h.z))&h.y,c1.z&h.z,0,0);
    return s+c1+c2;
}

// Return U<<1
uint4 shl128(uint4 u)
{
    // Bits to move up
    uint4 h = (u>>(uint4)(31)) & (uint4)(0,1,1,1);
    return (u<<(uint4)(1)) | h.yzwx;
}

// Return U>>1
uint4 shr128(uint4 u)
{
    // Bits to move down
    uint4 h = (u<<(uint4)(31)) & (uint4)(0x80000000,0x80000000,0x80000000,0);
    return (u>>(uint4)(1)) | h.wxyz;
}

// Return U*K.
// U MUST be positive.
uint4 mul128u(uint4 u, uint k)
{
    uint4 s1 = u * (uint4)(k);
    uint4 s2 = (uint4)(mul_hi(u.y,k),mul_hi(u.z,k),mul_hi(u.w,k),0);
    return add128(s1,s2);
}


// Return U*V truncated to keep the position of the decimal point.
// U and V MUST be positive.
uint4 mulfpu(uint4 u,uint4 v)
{
    // Diagonal coefficients
    uint4 s = (uint4)(u.x*v.x,mul_hi(u.y,v.y),u.y*v.y,mul_hi(u.z,v.z));
    // Off-diagonal
    uint4 t1 = (uint4)(mul_hi(u.x,v.y),u.x*v.y,mul_hi(u.x,v.w),u.x*v.w);
    uint4 t2 = (uint4)(mul_hi(v.x,u.y),v.x*u.y,mul_hi(v.x,u.w),v.x*u.w);
    s = add128(s,add128(t1,t2));
    t1 = (uint4)(0,mul_hi(u.x,v.z),u.x*v.z,mul_hi(u.y,v.w));
    t2 = (uint4)(0,mul_hi(v.x,u.z),v.x*u.z,mul_hi(v.y,u.w));
    s = add128(s,add128(t1,t2));
    t1 = (uint4)(0,0,mul_hi(u.y,v.z),u.y*v.z);
    t2 = (uint4)(0,0,mul_hi(v.y,u.z),v.y*u.z);
    s = add128(s,add128(t1,t2));
    // Add 3 to compensate truncation
    return add128(s,(uint4)(0,0,0,3));
}

// Return U*U truncated to keep the position of the decimal point.
// U MUST be positive.
uint4 sqrfpu(uint4 u)
{
    // Diagonal coefficients
    uint4 s = (uint4)(u.x*u.x,mul_hi(u.y,u.y),u.y*u.y,mul_hi(u.z,u.z));
    // Off-diagonal
    uint4 t = (uint4)(mul_hi(u.x,u.y),u.x*u.y,mul_hi(u.x,u.w),u.x*u.w);
    s = add128(s,shl128(t));
    t = (uint4)(0,mul_hi(u.x,u.z),u.x*u.z,mul_hi(u.y,u.w));
    s = add128(s,shl128(t));
    t = (uint4)(0,0,mul_hi(u.y,u.z),u.y*u.z);
    s = add128(s,shl128(t));
    // Add 3 to compensate truncation
    return add128(s,(uint4)(0,0,0,3));
}


kernel void compute_fp128(global uint * a,
                        global uint * colormap,
                        constant uint * coords,
                            int nx,int ny,
                            int offset,int lda,
                            int leftXSign,int topYSign,
                            int maxIt)
{
    // Convert inputs
    uint4 leftX = vload4(0,coords);
    uint4 topY  = vload4(1,coords);
    uint4 stepX = vload4(2,coords);
    uint4 stepY = vload4(3,coords);
    if (leftXSign < 0) leftX = neg128(leftX);
    if (topYSign < 0) topY = neg128(topY);
//
//    for (int iy=0;iy<ny;iy++) for (int ix=0;ix<nx;ix++)
//    {
//        int xpix = get_global_id(0)*nx + ix;
//        int ypix = get_global_id(1)*ny + iy;
//        uint4 xc = add128(leftX,mul128(stepX,xpix)); // xc = leftX + xpix * stepX;
//        uint4 yc = add128(topY,neg128(mul128(stepY,ypix))); // yc = topY - ypix * stepY;
//        
//        int it = 0;
//        uint4 x = set128(0);
//        uint4 y = set128(0);
//        for (it=0;it<maxIt;it++)
//        {
//            uint4 x2 = sqrfp(x); // x2 = x^2
//            uint4 y2 = sqrfp(y); // y2 = y^2
//            uint4 aux = add128(x2,y2); // x^2+y^2
//            if (aux.x >= 4) break; // Out!
//            uint4 twoxy = shl128(mulfp(x,y)); // 2*x*y
//            x = add128(xc,add128(x2,neg128(y2))); // x' = xc+x^2-y^2
//            y = add128(yc,twoxy); // y' = yc+2*x*y
//        }
//        uint color = (it < maxIt)?colormap[it]:0xFF000000;
//        a[offset+xpix+lda*ypix] = color;
//    }
}















