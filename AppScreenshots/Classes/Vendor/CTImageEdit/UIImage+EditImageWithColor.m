//
//  UIImage+EditImageWithColor.m
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import "UIImage+EditImageWithColor.h"

@implementation UIImage (EditImageWithColor)


- (UIImage *)tintImageWithColor:(UIColor *)tintColor{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

+ (UIImage*)createImageWithColor:(UIColor*)color{
    
    CGRect rect= CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithName:(NSString *)str{
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.cocoapods.CTImageEdit"];
    UIImage *image = [UIImage imageNamed:str inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}
@end
