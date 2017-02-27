//
//  CTImageSmearBottom.m
//  Pods
//
//  Created by huang cheng on 2017/2/24.
//
//

#import "CTImageSmearBottom.h"
#import "UIImage+EditImageWithColor.h"

@interface CTImageSmearBottom ()

@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *lastBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UIButton *commitBtn;

@end

@implementation CTImageSmearBottom

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cancelBtn];
        [self addSubview:self.lastBtn];
        [self addSubview:self.nextBtn];
        [self addSubview:self.commitBtn];
        self.backgroundColor = CTImageEditRGBColor(0x333333, 0.3);
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height;
    CGFloat centerX = self.bounds.size.width / 2;
    self.nextBtn.frame = CGRectMake(centerX + 16, (height - 24)/2, 24 , 24);
    self.lastBtn.frame = CGRectMake(centerX - 16 - 24 , (height - 24)/2, 24 , 24);
    
    self.cancelBtn.frame = CGRectMake(16, ( height - 30 )/ 2, 50, 30);
    self.commitBtn.frame = CGRectMake(self.bounds.size.width - 75 - 16, (height - 30 ) / 2, 70, 30);
    [self changeState];
}

/**
 *  改变前进后退按钮的颜色
 */
- (void)changeState{
    if ([self.delegate respondsToSelector:@selector(hasLastMosaicOperation)]) {
        if ([self.delegate hasLastMosaicOperation]) {
            [self.lastBtn setImage:[[UIImage imageWithName:@"Image.bundle/sccphoto_smear_last"]  tintImageWithColor:CTImageEditRGBColor(0xffffff, 1)] forState:UIControlStateNormal];
        }else{
            [self.lastBtn setImage:[[UIImage imageWithName:@"Image.bundle/sccphoto_smear_last"]   tintImageWithColor:CTImageEditRGBColor(0x999999, 1)] forState:UIControlStateNormal];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(hasNextMosaicOperation)]) {
        if ([self.delegate hasNextMosaicOperation]) {
            [self.nextBtn setImage:[[UIImage imageWithName:@"Image.bundle/sccphoto_smear_next"]  tintImageWithColor:CTImageEditRGBColor(0xffffff, 1)]  forState:UIControlStateNormal];
        }else{
            [self.nextBtn setImage:[[UIImage imageWithName:@"Image.bundle/sccphoto_smear_next"]tintImageWithColor:CTImageEditRGBColor(0x999999, 1)]  forState:UIControlStateNormal];
        }
    }
}

- (void)reLastStep{
    if ([self.delegate respondsToSelector:@selector(hasLastMosaicOperation)]) {
        if ([self.delegate hasLastMosaicOperation] && [self.delegate respondsToSelector:@selector(lastMosaicOperation)]) {
            [self.delegate lastMosaicOperation];
        }
    }
    [self changeState];
}

- (void)nextStep{
    if ([self.delegate respondsToSelector:@selector(hasNextMosaicOperation)]) {
        if ([self.delegate hasNextMosaicOperation] && [self.delegate respondsToSelector:@selector(nextMosaicOperation)]) {
            [self.delegate nextMosaicOperation];
        }
    }
    [self changeState];
}

- (void)commitClick{
    if ([self.delegate respondsToSelector:@selector(commitMosaic)]) {
        [self.delegate commitMosaic];
    }
}

- (void)cancelClick{
    if ([self.delegate respondsToSelector:@selector(closeMosaic)]) {
        [self.delegate closeMosaic];
    }
}

- (UIButton *)lastBtn{
    if (!_lastBtn) {
        _lastBtn = [[UIButton alloc]init];
        [_lastBtn setImage:[[UIImage imageWithName:@"sccphoto_smear_last"] tintImageWithColor:CTImageEditRGBColor(0x999999, 1)] forState:UIControlStateNormal];
        [_lastBtn addTarget:self action:@selector(reLastStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastBtn;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc]init];
        [_nextBtn setImage:[[UIImage imageWithName:@"sccphoto_smear_next"] tintImageWithColor:CTImageEditRGBColor(0xffffff, 1)]  forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:CTTextFontSize];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)commitBtn{
    if (!_commitBtn) {
        _commitBtn = [[UIButton alloc]init];
        [_commitBtn setTitle:@"应用" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _commitBtn.titleLabel.font = [UIFont systemFontOfSize:CTTextFontSize];
        [_commitBtn addTarget:self action:@selector(commitClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
}


@end
