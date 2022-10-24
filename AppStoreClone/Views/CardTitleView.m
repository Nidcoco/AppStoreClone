//
//  CardTitleView.m
//  AppStoreClone
//

#import "CardTitleView.h"

#import <Masonry/Masonry.h>

@interface CardTitleView ()

/// Subtitle
@property (nonatomic, strong) UILabel *subtitleLabel;

/// Main title
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CardTitleView

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
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.titleLabel];
    [self setupLayout];
}

- (void)setupLayout
{
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20.f);
        make.right.offset(-20.f);
        make.top.offset(0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.subtitleLabel);
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(5.f);
        make.right.offset(-20.f);
        make.bottom.offset(0);
    }];
}

- (void)setModel:(CardModel *)model
{
    _model = model;
    self.subtitleLabel.text = model.cardTypeTitle;
    self.titleLabel.text = model.title;
    if (model.backgroundType.length) {
        if ([model.backgroundType isEqualToString:@"dark"]) {
            _titleLabel.textColor = [UIColor whiteColor];
        } else {
            _titleLabel.textColor = [UIColor blackColor];
        }
    }
}

//MARK: Lazy Load

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _subtitleLabel.numberOfLines = 1;
    }
    return _subtitleLabel;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor labelColor];
        _titleLabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

@end
