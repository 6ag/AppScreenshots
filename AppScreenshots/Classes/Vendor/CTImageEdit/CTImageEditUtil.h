//
//  CTImageEditUtil.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTImageEditUtil : NSObject

+ (UIImage*)filterForGaussianBlur:(UIImage*)image;

+ (CGRect)getViewBoundWith:(UIImage*)image;

+ (UIImage*)getScaleImageWith:(UIImage*)image;

+ (UIImage*)getImageWithOldImage:(UIImage*)image;

+ (UIImage*)getRotationWithImage:(UIImage*)image withOrientation:(UIDeviceOrientation)orientation;

+ (UIImage*)getUnrotationWithImage:(UIImage*)image withOrientation:(UIDeviceOrientation)orientation;

+ (UIImage *)rotatedByDegrees:(CGFloat)degrees withImage:(UIImage*)image;

+ (UIImage *)rotatedWithImage:(UIImage*)image;

+ (CGSize)getCutViewSizeWith:(CGSize)bSize;

+ (CGSize)getCutImageViewSizeWith:(CGSize)bSize cutViewSize:(CGSize)cSize;


@end
