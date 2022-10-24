//
//  CardAccessoryView.m
//  AppStoreClone
//

#import "CardAccessoryView.h"

#import <Masonry/Masonry.h>

@interface CardAccessoryView ()

/// get botton
@property (nonatomic, strong) UIButton *getButton;
/// In app purchase
@property (nonatomic, strong) UILabel *purchaseLabel;

@end


@implementation CardAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.getButton];
    [self addSubview:self.purchaseLabel];
    
    [self.getButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(28.f);
        make.width.offset(70.f);
        make.left.right.centerY.offset(0);
    }];
    
    [self.purchaseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.getButton);
        make.top.equalTo(self.getButton.mas_bottom).offset(5.f);
    }];
    
}

- (UIButton *)getButton {
    if (_getButton == nil) {
        _getButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getButton setTitle:@"获取" forState:UIControlStateNormal];
        [_getButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        _getButton.titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
        _getButton.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.9];
            } else {
                return [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.1];
            }
        }];
        _getButton.layer.cornerRadius = 14.f;
    }
    return _getButton;
}

- (UILabel *)purchaseLabel {
    if (_purchaseLabel == nil) {
        _purchaseLabel = [UILabel new];
        _purchaseLabel.text = @"App内购买";
        _purchaseLabel.textColor = [UIColor grayColor];
        _purchaseLabel.font = [UIFont systemFontOfSize:8.0f];
    }
    return _purchaseLabel;
}

@end
