//
//  CTImageEditUtil.m
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import "CTImageEditUtil.h"
#import "UIImage+EditImageWithColor.h"

@implementation CTImageEditUtil


/*
 全图模糊  高斯模糊
 */
+ (UIImage*)filterForGaussianBlur:(UIImage*)image{
    CGFloat blur = 10 * image.size.width / [UIScreen mainScreen].bounds.size.width;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    CIImage *outputImage = filter.outputImage;
    return [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:CGRectMake(0, 0, image.size.width, image.size.height)]];
}

+ (CGRect)getViewBoundWith:(UIImage*)image{
    
    CGSize toSize = image.size;
    CGSize size = CTImageEditPreviewFrame.size;
    
    if (size.width>= toSize.width && size.height >= toSize.height) {//宽度大于要显示的区域
        return CGRectMake(0, 0, toSize.width, toSize.height);
    }else if (size.width < toSize.width && size.height >= toSize.height) {//宽度小于要显示区域，,太长截取
        CGSize resultSize = CGSizeMake(size.width, toSize.height * size.width / toSize.width);
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }else if (size.width >= toSize.width && size.height < toSize.height){
        CGSize resultSize = CGSizeMake( toSize.width * size.height / toSize.height , size.height);
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }else{
        CGFloat scaleW = toSize.width / size.width;
        CGFloat scaleH = toSize.height / size.height;
        CGSize resultSize;
        if (scaleW > scaleH) {
            resultSize = CGSizeMake(size.width, toSize.height / scaleW);
        }else{
            resultSize = CGSizeMake( toSize.width / scaleH , size.height);
        }
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }
}

+ (UIImage*)getImageWithOldImage:(UIImage*)image{
    CGSize resultSize = image.size;
    UIGraphicsBeginImageContext(resultSize);
    [image drawInRect:CGRectMake(0, 0, resultSize.width,resultSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = scaledImage;
    
    return scaledImage;
}
+ (UIImage*)getScaleImageWith:(UIImage*)image{
    
    CGSize toSize = image.size;
    CGSize size = CTImageEditPreviewFrame.size;
    size.width = size.width * [UIScreen mainScreen].scale;
    size.height = size.height * [UIScreen mainScreen].scale;
    
    if (size.width>= toSize.width && size.height >= toSize.height) {//宽度大于要显示的区域
        return image;
    }else if (size.width < toSize.width && size.height >= toSize.height) {//宽度小于要显示区域，,太长截取
        CGSize resultSize = CGSizeMake(size.width, toSize.height * size.width / toSize.width);
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width,resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = scaledImage;
        
        return scaledImage;
    }else if (size.width >= toSize.width && size.height < toSize.height){
        
        CGSize resultSize = CGSizeMake( toSize.width * size.height / toSize.height , size.height);
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width,resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = scaledImage;
        
        return scaledImage;
    }else{
        CGFloat scaleW = toSize.width / size.width;
        CGFloat scaleH = toSize.height / size.height;
        CGSize resultSize;
        if (scaleW > scaleH) {
            resultSize = CGSizeMake(size.width, toSize.height / scaleW);
        }else{
            resultSize = CGSizeMake( toSize.width / scaleH , size.height);
        }
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width,resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = scaledImage;
        
        return scaledImage;
    }
}

+ (UIImage *)getRotationWithImage:(UIImage *)image withOrientation:(UIDeviceOrientation)orientation{
    UIImage *newImage;
    
    switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
            case UIDeviceOrientationLandscapeRight:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
            case UIDeviceOrientationPortraitUpsideDown:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
        default:
            newImage = image;
            break;
    }
    
    return newImage;
}

+ (UIImage *)getUnrotationWithImage:(UIImage *)image withOrientation:(UIDeviceOrientation)orientation{
    
    UIImage *newImage;
    
    switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
            break;
            case UIDeviceOrientationLandscapeRight:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
            case UIDeviceOrientationPortraitUpsideDown:
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationDown];
            break;
        default:
            newImage = image;
            break;
    }
    
    return newImage;
}

static inline CGFloat DegreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

+ (UIImage *)rotatedByDegrees:(CGFloat)degrees withImage:(UIImage*)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 2.0f);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
    
}

+ (UIImage *)rotatedWithImage:(UIImage*)image{
    
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(90));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, image.scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(90));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGSize)getCutViewSizeWith:(CGSize)bSize{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat scaleW = screenSize.width / bSize.width;
    CGFloat scaleH = screenSize.height / bSize.height;
    if (scaleH < scaleW && scaleH < 1) {
        return CGSizeMake(bSize.width * scaleH, screenSize.height);
    }else if (scaleW <= scaleH && scaleW < 1){
        return CGSizeMake(screenSize.width, bSize.height * scaleW);
    }else{
        return bSize;
    }
}

+ (CGSize)getCutImageViewSizeWith:(CGSize)bSize cutViewSize:(CGSize)cSize{
    
    CGFloat scaleW = cSize.width / bSize.width;
    CGFloat scaleH = cSize.height / bSize.height;
    
    if (scaleH > scaleW) {
        return CGSizeMake(bSize.width * scaleH, cSize.height);
    }else{
        return CGSizeMake(cSize.width, bSize.height * scaleW);
    }
    
}

@end
