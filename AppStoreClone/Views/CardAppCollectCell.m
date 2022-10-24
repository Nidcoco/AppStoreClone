//
//  CardAppCollectCell.m
//  AppStoreClone
//

#import "CardAppCollectCell.h"

#import <Masonry/Masonry.h>

@interface CardAppCollectCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CardAppCollectCell

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
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}


- (void)configWithModel:(id)model {
    
    if ([model isKindOfClass:[CardAppModel class]]) {
        CardAppModel *m = model;
        _imageView.image = [UIImage imageNamed:m.appIcon];
    }
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 20;
    }
    return _imageView;
}

@end
