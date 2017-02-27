//
//  CTImageSmearView.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <UIKit/UIKit.h>
@protocol CTImageSmearViewDelegate <NSObject>

@optional

- (void)hasUpdateSmear;

@end


@interface CTImageSmearView : UIView

@property (nonatomic,weak) id<CTImageSmearViewDelegate>delegate;

- (UIImage*)finishSmear;

- (BOOL)hasNextStep;
- (void)nexStep;

- (void)lastStep;
- (BOOL)hasLastStep;

- (void)packageWithImage:(UIImage*)image;

@end
