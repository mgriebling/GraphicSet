//
//  SetCardView.m
//  GraphicSet
//
//  Created by Mike Griebling on 17.2.2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

#define SHAPE_HEIGHT    0.65
#define SHAPE_WIDTH     0.30
#define OUTLINE_WIDTH   3.0
#define SQUIGGLE_HEIGHT (0.2/65.0)
#define SQUIGGLE_WIDTH  (0.2/98.0)

- (void)drawOvalWithHorizontalOffset:(CGFloat)hoffset verticalOffset:(CGFloat)voffset {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint origin = CGPointMake(width/2-hoffset*width, height/2-voffset*height);
    CGRect rect = CGRectMake(origin.x, origin.y, height*SHAPE_WIDTH, height*SHAPE_HEIGHT);
    UIBezierPath *oval = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width/2];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextAddPath(context, oval.CGPath);
    CGContextClosePath(context);
    CGContextSaveGState(context);
    if (self.fill == FILL_STRIPED) [self setPatternFill:context];
    CGContextSetLineWidth(context, OUTLINE_WIDTH);
    if (self.fill == FILL_OPEN) CGContextDrawPath(context, kCGPathStroke);
    else CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
}

- (void)drawDiamondWithHorizontalOffset:(CGFloat)hoffset verticalOffset:(CGFloat)voffset {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint origin = CGPointMake(width/2-hoffset*width, height/2);
    CGRect rect = CGRectMake(origin.x, origin.y, height*SHAPE_WIDTH, height*SHAPE_HEIGHT);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, origin.x, origin.y);
    CGContextAddLineToPoint(context, origin.x+rect.size.width/2, origin.y-rect.size.height/2);
    CGContextAddLineToPoint(context, origin.x+rect.size.width, origin.y);
    CGContextAddLineToPoint(context, origin.x+rect.size.width/2, origin.y+rect.size.height/2);
    CGContextClosePath(context);
    CGContextSaveGState(context);
    if (self.fill == FILL_STRIPED) [self setPatternFill:context];
    CGContextSetLineWidth(context, OUTLINE_WIDTH);
    if (self.fill == FILL_OPEN) CGContextDrawPath(context, kCGPathStroke);
    else CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
}

static UIColor *drawColour;

void MyDrawPattern (void *info, CGContextRef context) {
    CGContextBeginPath(context);
    for (int i=0; i<24; i+=4) {
        CGContextMoveToPoint(context, 0, i);
        CGContextAddLineToPoint(context, 24, i);
    }
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, drawColour.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)setPatternFill:(CGContextRef)context {
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    CGFloat alpha = 1.0;
    static const CGPatternCallbacks callbacks = {0, &MyDrawPattern, NULL};
    CGPatternRef pattern = CGPatternCreate(NULL, self.bounds, CGAffineTransformIdentity, 24, 24, kCGPatternTilingConstantSpacing, true, &callbacks);
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
}

static struct point {
    CGFloat x; CGFloat y;
} points[] = {
    // squiggle shape definition
    {166.75, 236.75}, {170.75, 218.25}, {166.75, 193.75}, {149.75, 164.75}, {148.75, 149.75}, {163.25, 141.25},
    {190.75, 140.75}, {214.75, 154.25}, {227.25, 165.75}, {235.75, 181.25}, {241.25, 206.25}, {239.25, 227.25},
    {228.75, 255.25}, {227.25, 276.75}, {234.75, 298.25}, {248.25, 316.75}, {249.25, 328.25}, {240.75, 338.25},
    {218.75, 344.75}, {197.75, 343.25}, {179.75, 336.75}, {159.25, 318.75}, {151.75, 283.75}
};

- (void)drawSquiggleWithHorizontalOffset:(CGFloat)hoffset verticalOffset:(CGFloat)voffset {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    hoffset -= 0.05;        // squiggle adjustment
    CGPoint origin = CGPointMake(width/2-hoffset*width, height/2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, origin.x, origin.y);
    int numOfPoints = sizeof(points)/(sizeof(CGFloat)*2);
    for (int i=0; i<numOfPoints; i++) {
        CGContextAddLineToPoint(context, origin.x+(points[i].x-166.75)*width*SQUIGGLE_WIDTH, origin.y+(points[i].y-236.75)*height*SQUIGGLE_HEIGHT);
    }
    CGContextClosePath(context);
    CGContextSaveGState(context);
    if (self.fill == FILL_STRIPED) [self setPatternFill:context];
    CGContextSetLineWidth(context, OUTLINE_WIDTH);
    if (self.fill == FILL_OPEN) CGContextDrawPath(context, kCGPathStroke);
    else CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
}

#define START_1SHAPE    0.100
#define START_2SHAPES   0.225
#define START_3SHAPES   0.400
#define INCREMENT       0.300
#define VERTICAL        0.325

- (void)drawShapes {
    CGFloat x;
    NSUInteger maxShapes;
    UIColor *colour;
    
    switch (self.colour) {
        case COLOUR_GREEN: colour = [UIColor greenColor]; break;
        case COLOUR_RED: colour = [UIColor redColor];  break;
        case COLOUR_PURPLE: colour = [UIColor purpleColor];  break;
    }
    
    drawColour = colour;               // needed for striped fills
    [colour setFill];
    [colour setStroke];
    
    switch (self.number) {
        case ONE: maxShapes = 1; x = START_1SHAPE; break;
        case TWO: maxShapes = 2; x = START_2SHAPES; break;
        case THREE: maxShapes = 3; x = START_3SHAPES; break;
    }
    
    for (int i=0; i<maxShapes; i++) {
        switch (self.shape) {
            case SHAPE_DIAMOND: [self drawDiamondWithHorizontalOffset:x verticalOffset:VERTICAL]; break;
            case SHAPE_SQUIGGLE: [self drawSquiggleWithHorizontalOffset:x verticalOffset:VERTICAL]; break;
            case SHAPE_OVAL: [self drawOvalWithHorizontalOffset:x verticalOffset:VERTICAL]; break;
            default: break;
        }
        x -= INCREMENT;
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0];
    [roundedRect addClip]; //prevents filling corners, i.e. sharp corners not included in roundedRect
    
    if (self.faceUp) {
        [[UIColor yellowColor] setFill];
    } else {
        [[UIColor whiteColor] setFill];  
    }
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    if ([[SetCard validShapes] containsObject:@(self.shape)]) [self drawShapes];
}

#pragma mark - Setters

-(void)setColour:(ColourType)colour
{
    _colour = colour;
    [self setNeedsDisplay];
}

-(void)setFill:(FillType)fill
{
    _fill = fill;
    [self setNeedsDisplay];
}

-(void)setNumber:(NumberOfShapes)number {
    _number = number;
    [self setNeedsDisplay];
}

-(void)setShape:(ShapeType)shape {
    _shape = shape;
    [self setNeedsDisplay];
}

-(void)setFaceUp:(BOOL)faceUp
{
    _faceUp = faceUp;
    [self setNeedsDisplay];
}

# pragma mark - Initialization

-(void)setUp
{
    // inititalization that can't wait until viewDidLoad
}

-(void)awakeFromNib
{
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setUp];
    return self;
}

@end
