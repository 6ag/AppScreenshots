//
//  CTImageSmearViewController.m
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import "CTImageSmearViewController.h"
#import "CTImageSmearView.h"
#import "CTImageEditUtil.h"
#import "UIImage+EditImageWithColor.h"
#import "CTImageSmearTop.h"
#import "CTImageSmearBottom.h"

@interface CTImageSmearViewController () <CTImageSmearBottomDelegate,CTImageSmearViewDelegate>

@property (nonatomic, strong) CTImageSmearView *smearView;      // 中间视图
@property (nonatomic, strong) CTImageSmearTop *smearTop;        // 顶部视图
@property (nonatomic, strong) CTImageSmearBottom *smearBottom;  // 底部视图
@property (nonatomic, strong) UIImageView *bgImageView;        // 高斯模糊背景图片
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIImage *image;

@end

@implementation CTImageSmearViewController

- (instancetype _Nonnull)initWithImage:(UIImage * _Nonnull)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.smearTop];
    [self.view addSubview:self.smearBottom];
    [self.view addSubview:self.indicatorView];
    
    // 来个叼逼的加载动画 - 防止有些低端机器卡顿
    __weak typeof(self) weakSelf = self;
    [self.indicatorView startAnimating];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.smearView.bounds = [CTImageEditUtil getViewBoundWith:weakSelf.image];
            [weakSelf.smearView packageWithImage:weakSelf.image];
            [weakSelf.indicatorView stopAnimating];
            [weakSelf.view addSubview:weakSelf.smearView];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.smearTop.frame = CGRectMake(0, 0, CTImageEditPreviewFrame.size.width, CTImageEditPreviewFrame.origin.y);
        self.smearBottom.frame = CGRectMake(0, CGRectGetMaxY(CTImageEditPreviewFrame), CTImageEditPreviewFrame.size.width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(CTImageEditPreviewFrame));
    }completion:^(BOOL finished) {
        self.smearTop.frame = CGRectMake(0, 0, CTImageEditPreviewFrame.size.width, CTImageEditPreviewFrame.origin.y);
        self.smearBottom.frame = CGRectMake(0, CGRectGetMaxY(CTImageEditPreviewFrame), CTImageEditPreviewFrame.size.width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(CTImageEditPreviewFrame));
    }];
}

#pragma mark - 懒加载
- (CTImageSmearView *)smearView
{
    if (!_smearView) {
        _smearView = [[CTImageSmearView alloc]init];
        _smearView.center = CGPointMake(CGRectGetMidX(CTImageEditPreviewFrame), CGRectGetMidY(CTImageEditPreviewFrame));
        _smearView.delegate = self;
    }
    return _smearView;
}

- (CTImageSmearTop *)smearTop
{
    if (!_smearTop) {
        _smearTop = [[CTImageSmearTop alloc]initWithFrame:CGRectMake(0, -CTImageEditPreviewFrame.origin.y, CTImageEditPreviewFrame.size.width, CTImageEditPreviewFrame.origin.y)];
    }
    return _smearTop;
}

- (CTImageSmearBottom *)smearBottom
{
    if (!_smearBottom) {
        _smearBottom = [[CTImageSmearBottom alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds), CTImageEditPreviewFrame.size.width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(CTImageEditPreviewFrame))];
        _smearBottom.delegate = self;
    }
    return _smearBottom;
}

- (UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.frame = _bgImageView.bounds;
        _bgImageView.image = self.image;
        [_bgImageView addSubview:effectview];
    }
    return _bgImageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.center = self.view.center;
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

#pragma mark - SCCPhotoSmearBottom delegate

/**
 关闭
 */
- (void)closeMosaic
{
    // 关闭viewcontroller
    [UIView animateWithDuration:0.2 animations:^{
        self.smearTop.frame = CGRectMake(0, -CTImageEditPreviewFrame.origin.y, CTImageEditPreviewFrame.size.width, CTImageEditPreviewFrame.origin.y);
        self.smearBottom.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds), CTImageEditPreviewFrame.size.width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(CTImageEditPreviewFrame));
    } completion:^(BOOL finished) {
        self.smearTop.frame = CGRectMake(0, -CTImageEditPreviewFrame.origin.y, CTImageEditPreviewFrame.size.width, CTImageEditPreviewFrame.origin.y);
        self.smearBottom.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds), CTImageEditPreviewFrame.size.width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(CTImageEditPreviewFrame));
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

/**
 应用
 */
- (void)commitMosaic
{
    UIImage *image = [self.smearView finishSmear];
    if ([self.delegate respondsToSelector:@selector(didSmearPhotoWithResultImage:)]) {
        [self.delegate didSmearPhotoWithResultImage:image];
    }
    [self closeMosaic];
}

- (void)nextMosaicOperation
{
    [self.smearView nexStep];
}

- (void)lastMosaicOperation
{
    [self.smearView lastStep];
}

- (BOOL)hasNextMosaicOperation
{
    return [self.smearView hasNextStep];
}

- (BOOL)hasLastMosaicOperation
{
    return [self.smearView hasLastStep];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - SCCPhotoSmearView Delegate

- (void)hasUpdateSmear
{
    [self.smearBottom changeState];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
