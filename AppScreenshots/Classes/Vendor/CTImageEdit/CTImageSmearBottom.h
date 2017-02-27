//
//  CTImageSmearBottom.h
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import <UIKit/UIKit.h>

@protocol CTImageSmearBottomDelegate <NSObject>

@optional
/**
 *  关闭
 */
- (void)closeMosaic;
/**
 *  完成
 */
- (void)commitMosaic;
/**
 *  下一步
 */
- (void)nextMosaicOperation;
/**
 *  上一步
 */
- (void)lastMosaicOperation;
/**
 *  是否有下一步
 *
 *  @return bool
 */
- (BOOL)hasNextMosaicOperation;
/**
 *  是否有上一步
 *
 *  @return bool
 */
- (BOOL)hasLastMosaicOperation;

@end

@interface CTImageSmearBottom : UIView

@property (nonatomic,weak) id<CTImageSmearBottomDelegate>delegate;

- (void)changeState;

@end
