//
//  CTImageSmearViewController.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <UIKit/UIKit.h>

@protocol CTImageSmearViewControllerDelegate <NSObject>

@optional
- (void)didSmearPhotoWithResultImage:(UIImage * _Nonnull)image;

@end

@interface CTImageSmearViewController : UIViewController

@property (nonatomic, weak) id<CTImageSmearViewControllerDelegate> delegate;

- (instancetype _Nonnull)initWithImage:(UIImage * _Nonnull)image;

@end
