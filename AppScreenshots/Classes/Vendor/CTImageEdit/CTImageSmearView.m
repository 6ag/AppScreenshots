//
//  CTImageSmearView.m
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import "CTImageSmearView.h"
#import "CTImageEditUtil.h"

@interface CTImageSmearView ()

@property (nonatomic,strong) NSMutableArray *lineArray;
@property (nonatomic,strong) NSMutableArray *removeLineArray;

@property (nonatomic,strong) NSMutableArray *nowPointArray;

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImage *nowImage;
@property (nonatomic,strong) UIImage *filterGaussan;

@end

@implementation CTImageSmearView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)packageWithImage:(UIImage*)image{
    self.image = image;
    
    UIImage *realImage = [CTImageEditUtil getImageWithOldImage:image];
    self.filterGaussan = [CTImageEditUtil filterForGaussianBlur:realImage];
    [self.nowPointArray removeAllObjects];
    [self.lineArray removeAllObjects];
    [self.removeLineArray removeAllObjects];
    [self drawSmearView];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    
    self.nowPointArray = [[NSMutableArray alloc]init];
    [self.removeLineArray removeAllObjects];
    [self.lineArray addObject:self.nowPointArray];
    [self addPoint:p];
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesCancelled:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    [self addPoint:p];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    [self addPoint:p];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    [self addPoint:p];
    
}

- (void)addPoint:(CGPoint)p{
    NSValue *point = [NSValue valueWithCGPoint:p];
    [self.nowPointArray addObject:point];
    
    [self drawSmearView];
    if ([self.delegate respondsToSelector:@selector(hasUpdateSmear)]) {
        [self.delegate hasUpdateSmear];
    }
}

- (void)drawSmearView{
    UIGraphicsBeginImageContextWithOptions(self.image.size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    [self.image drawInRect:CGRectMake(0, 0,self.image.size.width,self.image.size.height)];
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithPatternImage:self.filterGaussan].CGColor);
    
    CGContextSetLineWidth(context, 10 * self.image.size.width / self.bounds.size.width);
    for (int i = 0 ; i < self.lineArray.count ; i ++ ) {
        NSMutableArray *array = [self.lineArray objectAtIndex:i];
        
        for (int i = 0 ; i < array.count ; i ++ ) {
            NSValue *value = [array objectAtIndex:i];
            CGPoint p = [value CGPointValue];
            p.x = p.x * self.image.size.width / self.bounds.size.width;
            p.y = p.y * self.image.size.height / self.bounds.size.height;
            if (i == 0) {
                CGContextMoveToPoint(context, p.x, p.y);
                CGContextAddLineToPoint(context, p.x, p.y);
            }else{
                CGContextAddLineToPoint(context, p.x, p.y);
            }
        }
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    // 将绘制的结果存储在内存中
    self.nowImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束绘制
    UIGraphicsEndImageContext();
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    [self.nowImage drawInRect:rect];
    
}

- (NSMutableArray *)nowPointArray{
    if (!_nowPointArray) {
        _nowPointArray = [[NSMutableArray alloc]init];
    }
    return _nowPointArray;
}

- (NSMutableArray *)lineArray{
    if (!_lineArray) {
        _lineArray = [[NSMutableArray alloc]init];
    }
    return _lineArray;
}

- (NSMutableArray *)removeLineArray{
    if (!_removeLineArray) {
        _removeLineArray = [[NSMutableArray alloc]init];
    }
    return _removeLineArray;
}

- (UIImage*)finishSmear{
    return self.nowImage;
}

- (BOOL)hasNextStep{
    if (self.removeLineArray && self.removeLineArray.count >= 1) {
        return YES;
    }
    return NO;
}
- (void)nexStep{
    if (self.removeLineArray && self.removeLineArray.count >= 1) {
        NSMutableArray *next = [self.removeLineArray lastObject];
        [self.removeLineArray removeLastObject];
        [self.lineArray addObject:next];
        [self drawSmearView];
    }
}

- (void)lastStep{
    if (self.lineArray && self.lineArray.count >= 1) {
        NSMutableArray *last = [self.lineArray lastObject];
        [self.lineArray removeLastObject];
        [self.removeLineArray addObject:last];
        [self drawSmearView];
    }
}
- (BOOL)hasLastStep{
    if (self.lineArray && self.lineArray.count >= 1) {
        return YES;
    }
    return NO;
}


@end
