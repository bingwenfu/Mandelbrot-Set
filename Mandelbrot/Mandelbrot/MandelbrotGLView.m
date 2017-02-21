//
//  MandelbrotGLView.h
//  Mandelbrot
//
//  Created by Bingwen Fu on 10/11/15.
//  Copyright © 2015 Bingwen. All rights reserved.
//

#import "MandelbrotGLView.h"
#import "OpenGL/gl3.h"
#import "mandelbrot_utility.h"
#import "ImageManager.h"

@implementation MandelbrotGLView

#pragma mark Override Parent Method

- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        (NSOpenGLPixelFormatAttribute)0
    };
    NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    [self setPixelFormat:pf];
    [self initParametersWithDisplayType:MANDELBROT_SET];
}

- (void)prepareOpenGL
{
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    shaderPrograms = prepareForSharderAndVertex();
}

- (void)reshape
{
    CGFloat viewWidth, viewHeight;
    if((viewHeight != self.bounds.size.height) || (viewWidth != self.bounds.size.width)) {
        viewHeight = self.bounds.size.height;
        viewWidth = self.bounds.size.width;
        glViewport(0, 0, viewWidth, viewHeight);
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self prepareForTexture];
    [self redrawMandelbrotWithCalculation:YES];
}

#pragma mark OpenGL Method

const GLchar* vertexSource =
"#version 150 core\n"
"in vec2 position;"\
"in vec3 color;"
"in vec2 texcoord;"
"out vec3 Color;"
"out vec2 Texcoord;"
"void main() {"
"   Color = color;"
"   Texcoord = texcoord;"
"   gl_Position = vec4(position, 0.0, 1.0);"
"}";

const GLchar* fragmentSource =
"#version 150 core\n"
"in vec3 Color;"
"in vec2 Texcoord;"
"out vec4 outColor;"
"uniform sampler2D uMandelbrot;"
"void main() {"
"   outColor = texture(uMandelbrot, Texcoord);"
"}";

GLuint prepareForSharderAndVertex()
{
    // Create Vertex Array Object
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    
    // Create a Vertex Buffer Object and copy the vertex data to it
    GLuint vbo;
    glGenBuffers(1, &vbo);
    
    GLfloat vertices[] = {
        //  Position     Color            Texcoords
        -1.0f,  1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, // Top-left
        1.0f,  1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, // Top-right
        1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, // Bottom-right
        -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f  // Bottom-left
    };
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // Create an element array
    GLuint ebo;
    glGenBuffers(1, &ebo);
    
    GLuint elements[] = {
        0, 1, 2,
        2, 3, 0
    };
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW);
    
    // Create and compile the vertex shader
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexSource, NULL);
    glCompileShader(vertexShader);
    
    // Create and compile the fragment shader
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
    glCompileShader(fragmentShader);
    
    // Link the vertex and fragment shader into a shader program
    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glBindFragDataLocation(shaderProgram, 0, "outColor");
    glLinkProgram(shaderProgram);
    glUseProgram(shaderProgram);
    
    // Specify the layout of the vertex data
    GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
    glEnableVertexAttribArray(posAttrib);
    glVertexAttribPointer(posAttrib, 2, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), 0);
    
    GLint colAttrib = glGetAttribLocation(shaderProgram, "color");
    glEnableVertexAttribArray(colAttrib);
    glVertexAttribPointer(colAttrib, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), (void*)(2 * sizeof(GLfloat)));
    
    GLint texAttrib = glGetAttribLocation(shaderProgram, "texcoord");
    glEnableVertexAttribArray(texAttrib);
    glVertexAttribPointer(texAttrib, 2, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), (void*)(5 * sizeof(GLfloat)));
    
    return shaderProgram;
}

- (void)prepareForTexture
{
    int width = [self imageWidth];
    int height = [self imageHeight];
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(glGetUniformLocation(shaderPrograms, "uMandelbrot"), 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    CGLContextObj cgl_context = CGLGetCurrentContext();
    CGLShareGroupObj sharegroup = CGLGetShareGroup(cgl_context);
    gcl_gl_set_sharegroup(sharegroup);
    
    if (shared_climage_buffer != NULL) {
        gcl_release_image(shared_climage_buffer);
    }
    shared_climage_buffer = gcl_gl_create_image_from_texture(GL_TEXTURE_2D, 0, texture);
    
    if (iterationImage != NULL) {
        gcl_free(iterationImage);
    }
    iterationImage = (cl_uint *)gcl_malloc(sizeof(cl_uint)*width*height, NULL, 0);
}


#pragma mark Mandelbrot Calculation

- (CGFloat)imageWidth
{
    return self.frame.size.width*2;
}

- (CGFloat)imageHeight
{
    return self.frame.size.height*2;
}

- (void)redrawMandelbrotWithCalculation:(BOOL)recalculation
{
    int width = [self imageWidth];
    int height = [self imageHeight];
    
    if (recalculation) {
        if (_displayType == MANDELBROT_SET) {
            cl_calculate_mandelbrot_iterations(_iterLimit, width, height, _p, iterationImage);
            [self computeHist:iterationImage width:width height:height numberOfBins:_histBins iterLimit:_iterLimit];
        } else if (_displayType == JULIA_SET) {
            cl_calculate_julia_iterations(_iterLimit, width, height, _p, iterationImage, juliaSeed);
        } else {
            NSLog(@"Unknow display type %s", __FUNCTION__);
            return;
        }
    }
    
    if (shared_climage_buffer == NULL) { return; }
    cl_float *colorSet = gen_cl_colorSet(_iterLimit, &_colorScheme, _clipColor);
    cl_colorize_iteration_Images(iterationImage, shared_climage_buffer, colorSet, _iterLimit, width, height);
    gcl_free(colorSet);
    
    [self redrawGLTexture];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mandelbrotGLViewFinishedDrawing" object:nil];
}

-(void)redrawGLTexture
{
    [[self openGLContext] makeCurrentContext];
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glFlush();
    
    CGLFlushDrawable([[self openGLContext] CGLContextObj]);
    CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void)initParametersWithDisplayType:(int)set
{
    _zoomRatio = 2.0;
    _histBins = 300;
    
    initColor(&_colorScheme.color1,       0.0,       0.0,       0.0);
    initColor(&_colorScheme.color2, 195/255.0,  38/255.0, 116/255.0);
    initColor(&_colorScheme.color3, 255/255.0, 253/255.0, 120/255.0);
    initColor(&_colorScheme.color4, 255/255.0, 255/255.0, 255/255.0);
    
    _colorScheme.a = 4.77;
    _colorScheme.colorLine1 = 0.095;
    _colorScheme.colorLine2 = 0.250;
    
    if (set == JULIA_SET) [self setJuliaParameters];
    if (set == MANDELBROT_SET) [self setMandelbrotParameters];

    _displayType = set;
    mouseDraged = FALSE;
}

- (void)setJuliaParameters
{
    initPlane(&_p, -2.0, 2.0, 2.0, -2.0);
    _iterLimit = 100;
    juliaSeed.r = 0.0;
    juliaSeed.i = 0.0;
}

- (void)setMandelbrotParameters
{
    initPlane(&_p, -2.4, 1.0, 1.7, -1.7);
    _iterLimit = 180;
}

- (void)setDisplayType:(int)displayType
{
    [self initParametersWithDisplayType:displayType];
    [self redrawMandelbrotWithCalculation:YES];
}

#pragma mark Handel Event

-(void)mouseUp:(NSEvent *)theEvent
{
    if (mouseDraged) {
        mouseDraged = FALSE;
        return;
    }
    
    NSPoint loc = theEvent.locationInWindow;
    ComplexPoint *point = [self viewCoordinatesToComplexCoordinates:loc.x y:loc.y rect:self.frame];
    
    // only for OpenCL -- flip the point vertially
    double center = (_p.y1 + _p.y2)/2.0;
    double i = 2.0*center - point->i;
    point->i = i;
    
    double halfWidth = ((_p.x2-_p.x1)/_zoomRatio)/2.0;
    _p.x1 = point->r-halfWidth;
    _p.x2 = point->r+halfWidth;
    _p.y1 = point->i+halfWidth;
    _p.y2 = point->i-halfWidth;
    
    free(point);
    _iterLimit = (_displayType == MANDELBROT_SET) ? _iterLimit + 50 : _iterLimit;
    [self redrawMandelbrotWithCalculation:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_displayType == MANDELBROT_SET) return;
    
    mouseDraged = true;
    [self setJuliaParameters];
    
    NSPoint loc = theEvent.locationInWindow;
    ComplexPoint *point = [self viewCoordinatesToComplexCoordinates:loc.x y:loc.y rect:self.frame];
    
    // only for OpenCL -- flip the point vertially
    double center = (_p.y1 + _p.y2)/2.0;
    double i = 2.0*center - point->i;
    point->i = i;
    
    juliaSeed = *point;
    free(point);
    [self redrawMandelbrotWithCalculation:YES];
}

- (void)zoomOut
{
    zoomPlaneByRatio(&_p, 1/_zoomRatio);
    if (_iterLimit > 200) {
        _iterLimit -= 100;
    }
    [self redrawMandelbrotWithCalculation:YES];
}

- (void)computeHist:(cl_uint*)cl_iterationsImage width:(int)width height:(int)height numberOfBins:(int)nbins iterLimit:(int)iterL
{
    int* c_iterImages = malloc(sizeof(int)*width*height);
    dispatch_sync(dispatch_get_cl_queue(), ^{
        gcl_memcpy(c_iterImages, cl_iterationsImage, sizeof(float)*width*height);
    });
    
    int* hist = calloc(sizeof(int), nbins);
    for (int i=0; i<width*height; i++) {
        float r = c_iterImages[i]/(float)iterL;
        int bin = (int)(r*(nbins-1));
        hist[bin]++;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=0; i<nbins; i++) {
        [arr addObject:@(hist[i])];
    }
    _histArr = arr;
    
    free(c_iterImages);
    free(hist);
}

- (ComplexPoint*)viewCoordinatesToComplexCoordinates:(double)x  y:(double)y rect:(CGRect)rect {
    double topX = _p.x1;
    double topY = _p.y1;
    double bottomX = _p.x2;
    double bottomY = _p.y2;
    double w = bottomX - topX;
    double h = topY - bottomY;
    
    ComplexPoint *point = malloc(sizeof(ComplexPoint));
    point->r = topX + (x/rect.size.width)*w;
    point->i = bottomY + (y/rect.size.height)*h;
    return point;
}

- (void)updateColor
{
    [self redrawMandelbrotWithCalculation:NO];
}

- (void)writeCurrentFrameAsImageToDisk
{
    ImageManager *im = [ImageManager sharedManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Desktop/md.png"];
    NSSize size = NSMakeSize([self imageWidth], [self imageHeight]);
    [im saveCLImageToFile:shared_climage_buffer size:size fileName:filePath blured:NO];
    
    
//    int nFrames = 3000;
//    float limt = _iterLimit;
//    for (int i=0; i<nFrames; i++) {
//        NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Desktop/frames/%05d.png", i];
//        zoomPlaneByRatio(&_p, 0.99);
//        
//        if (i<400) {
//            limt = limt - 2;
//        } else if (i<1000) {
//            limt = limt - 2;
//        } else {
//            limt = limt - 1.02;
//        }
//        if (limt > 200) {
//            _iterLimit = (int)limt;
//        } else {
//            _iterLimit = 200;
//        }
//        
//        if (i%100 == 0) {
//            NSLog(@"%@ %d", filePath, [im currentWrittingJobNumber]);
//            [self redrawMandelbrotWithCalculation:YES];
//            [im saveCLImageToFile:shared_climage_buffer size:size fileName:filePath blured:NO];
//            while ([im currentWrittingJobNumber] >= 6) {
//                sleep(1);
//            }
//        }
//    }
}

@end


