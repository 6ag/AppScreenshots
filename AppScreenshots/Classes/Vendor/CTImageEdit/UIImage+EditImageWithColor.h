//
//  UIImage+EditImageWithColor.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <UIKit/UIKit.h>

#define CTImageEditRGBColor(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]


//#define CTImageEditPreviewFrame (CGRect){ 0, 60, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 167 }

#define CTImageEditPreviewFrame ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) ? (CGRect){ 0, 38, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 88 } : ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) ? (CGRect){ 0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 104 } : ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) ? (CGRect){ 0, 48, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 117 } : (CGRect){ 0, 60, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 137 })))

#define CTTextFontSize ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) ? 12 : ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) ? 14 : ([UIScreen instancesRespondToSelector:@selector(currentMode)] && CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) ? 15.5 : 16.5)))

@interface UIImage (EditImageWithColor)

- (UIImage*)tintImageWithColor:(UIColor*)tintColor;

+ (UIImage*)createImageWithColor:(UIColor*)color;

+ (UIImage*)imageWithName:(NSString*)str;
@end
