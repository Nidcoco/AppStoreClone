//
//  CardView.m
//  AppStoreClone
//

#import "CardView.h"
#import "CardTitleView.h"
#import "CardAppListView.h"
#import "CardAppCollectView.h"

#import <Masonry/Masonry.h>
#import "YYModel.h"

@interface CardView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) CardTitleView *titleView;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) CardAppListView *appListView;

@property (nonatomic, strong) CardAppCollectView *appCollectView;

@property (nonatomic, strong) UIButton *shareBtn;

@end

@implementation CardView
{
    UIView *_contentFirstView;
}

- (instancetype)initWithCardModel:(CardModel *)cardModel
{
    self = [super init];
    if (self) {
        _cardModel = cardModel;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self setupCommonView];

    switch (_cardModel.viewType) {
        case CardViewOne:
        {
            [self setupTypeOne];
        }
            break;

        case CardViewTwo:
        {
            [self setupTypeTwo];
        }
            break;
        case CardViewThree:
        {
            [self setupTypeThree];
        }
            break;
        default:
            break;
    }
}

- (void)setupCommonView
{
    if (_cardModel.viewMode == CardViewModeCard && !_cardModel.isTransition) { // today页面的卡片, 不包括转场
        [self addSubview:self.shadowView];
        [self addCardShadow];
        self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, [_cardModel getCardSize].width - 40, [_cardModel getCardSize].height - 29)].CGPath;
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.left.offset(20.f);
            make.right.offset(-20.f);
            make.height.offset([self.cardModel getCardSize].height - 29.f);
        }];
    } else {
        [self addBgShadow];
        [self addSubview:self.bgView];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.shadowView];
        [self.scrollView addSubview:self.containerView]; // 先加到self.scrollView, dismiss的时候加到coverView, 用来遮罩上方

        [self addSubview:self.closeButton];
        
        if (_cardModel.viewMode == CardViewModeCard) { // today转详情页的过渡页面
            
            self.bgView.layer.cornerRadius = 16.f;
            
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.left.offset(20.f);
                make.right.offset(-20.f);
                make.bottom.offset(-29.f);
            }];
            
            [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.centerX.offset(0);
                make.height.offset([self.cardModel getCardSize].height - 29.f);
                make.top.offset(0);
            }];
            
        } else {
            
            [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.offset(0);
            }];
            
            [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.centerX.offset(0);
                make.height.offset([self.cardModel getFullSize].height);
                make.top.offset(0);
                make.top.mas_lessThanOrEqualTo(self).offset(0); // 由于scrollView弹性可以浮动在顶部
            }];
        }
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView.mas_right).offset(-20.f);
            make.top.offset(20.f);
            make.height.width.offset(30.f);
        }];
        
        [self addContentView]; // 内容
    }
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    if (_cardModel.viewMode == CardViewModeCard) {
        self.containerView.layer.cornerRadius = 16.0f;
    } else {
        self.containerView.layer.cornerRadius = 0;
    }
    
}

- (void)updateLayout:(CardViewMode)viewMode
{
    if (viewMode == CardViewModeCard) { // 详情页dismiss的布局改变
        
        [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) { // 下面尽量不遮罩, 所以高度尽量长点
            make.left.offset(20.f);
            make.right.offset(-20.f);
        }];
        
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.height.offset([self.cardModel getCardSize].height - 29.f);
        }];
        
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(30.f);
            make.left.offset(20.f);
            make.right.offset(-20.f);
            make.bottom.offset(-29.f); // 弹性使会有内容露出来, 顶部0修改为30, 底下其实也有内容露出来一点, 因为app store的dismiss转场回来的位置是原来位置下来一点的位置, 然后再回到原来的位置, 刚好可以遮挡住那点位置, 但这个动画我还不会实现
        }];
        
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(30.f);
            make.left.offset(20.f);
            make.right.offset(-20.f);
            make.bottom.offset(-29.f);
        }];
        
        [_contentFirstView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset([self.cardModel getCardSize].height);
        }];

        [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(16.f);
        }];
        
        if (_cardModel.viewType == CardViewTwo && _cardModel.apps.count > 4) {
            self.appListView.listArray = [_cardModel.apps subarrayWithRange:NSMakeRange(0, 4)];
        }
        
    } else {
        
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.offset(0);
        }];
        
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.offset([self.cardModel getFullSize].height);
        }];
        
        [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.offset(kStatusBarHeight);
        }];
    }
}

- (void)animationsAction:(CardViewMode)viewMode
{
    if (viewMode == CardViewModeCard) {
        self.containerView.layer.cornerRadius = 16.f;
        self.bgView.layer.cornerRadius = 16.f;
        self.scrollView.layer.cornerRadius = 16.f;
        
        self.coverView.layer.cornerRadius = 16.f;
        
        self.closeButton.alpha = 0;
        
        if (_cardModel.viewType != CardViewTwo) {
            [self addCardShadow];
        }
        
    } else {
        self.containerView.layer.cornerRadius = 0;
        self.bgView.layer.cornerRadius = 0;
        self.scrollView.layer.cornerRadius = 0;
    }
}

- (void)updateContainerViewLayout
{
    [self addSubview:self.coverView];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(0.f);
        make.right.offset(0.f);
        make.height.offset([self.cardModel getFullSize].height);
    }];
    
    CGFloat y;
    if (self.scrollView.contentOffset.y > [self.cardModel getFullSize].height) {
        y = - [self.cardModel getFullSize].height; // y越大弹性太大, 手动改变y值, 减少dismiss的弹性
    } else {
        CGRect cardFrame = [self.containerView convertRect:self.containerView.frame toView:self];
        y = cardFrame.origin.y;
    }
    
    [self.coverView addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(y);
        make.left.offset(0.f);
        make.right.offset(0.f);
        make.height.offset([self.cardModel getFullSize].height);
    }];
    
    [self.shadowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
}

- (void)zoomAction:(CGFloat)cornerRadius
{
    self.scrollView.layer.cornerRadius = cornerRadius;
    self.bgView.layer.cornerRadius = cornerRadius;
    
    self.closeButton.alpha = 1 - cornerRadius / 16.f;
}

- (void)addContentView
{
    // 这里感觉可以将图片视频或者其他类型也搞成富文本, 搞一个CTRunDelegateRef，通过runDelegate确定那些类型区域的大小, 具体实现可以参考YYLabel, 我不会
    UIView *next;
    for (NSInteger i = 0; i < self.cardModel.contents.count; i ++) {
        CardContentModel *model = self.cardModel.contents[i];
        
        UIView *view;
        CGFloat height = 0;
        
        switch (model.contentType) {
            case CardViewText:
            {
                NSArray *texts = [NSArray yy_modelArrayWithClass:[CardTextContentModel class] json:model.content];
                
                UILabel *label = [[UILabel alloc] init];
                label.numberOfLines = 0;
                label.preferredMaxLayoutWidth = kScreenWidth - 40;
                NSMutableAttributedString *attributeds = [[NSMutableAttributedString alloc] init];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 10;
                
                for (CardTextContentModel *text in texts) {
                    
                    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:text.text];
                    
                    [attributed addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text.text length])];
                    [attributed addAttribute:NSForegroundColorAttributeName value:[text.color isEqualToString:@"GrayColor"] ? [UIColor grayColor] : [UIColor labelColor] range:NSMakeRange(0, [text.text length])];
                    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:text.font weight:[text.weight isEqualToString:@"Regular"] ? UIFontWeightRegular : UIFontWeightBold] range:NSMakeRange(0, [text.text length])];
                    
                    [attributeds appendAttributedString:attributed];
                }
                label.attributedText = attributeds;
                view = label;
            }
                break;
            case CardViewImage:
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                UIImage *image = [UIImage imageNamed:model.content];
                height = image.size.height / image.size.width * (kScreenWidth - 40);
                imageView.image = image;
                view = imageView;
            }
                break;
                
            case CardViewApps:
            {
                CardAppListView *appView = [[CardAppListView alloc] init];
                appView.isContent = YES;
                appView.listArray = [NSArray yy_modelArrayWithClass:[CardAppModel class] json:model.content];
                view = appView;
                height = appView.listArray.count * 81 - 1;
            }
                break;
            case CardViewLine:
            {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = [UIColor grayColor];
                view = line;
                height = 0.5f;
            }
        }
        
        [self.scrollView insertSubview:view belowSubview:self.containerView];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                if (self.cardModel.viewType == CardViewThree) {
                    if (self.cardModel.viewMode == CardViewModeCard) {
                        make.top.equalTo(self.containerView.mas_bottom).offset(20);
                    } else {
                        make.top.offset([self.cardModel getFullSize].height + 20);
                    }
                } else {
                    if (self.cardModel.viewMode == CardViewModeCard) {
                        make.top.equalTo(self.containerView.mas_bottom).offset(40);
                    } else {
                        make.top.offset([self.cardModel getFullSize].height + 40);
                    }
                }
            } else {
                make.top.equalTo(next.mas_bottom).offset(40);
            }
            
            make.centerX.offset(0);
            
            if (model.contentType != CardViewText) {
                make.height.offset(height);
            }
            
            if (model.contentType == CardViewThree) {
                make.left.right.offset(0);
            } else {
                make.left.offset(20);
                make.right.offset(-20);
            }
        }];
        
        next = view;
        if (i == 0) {
            _contentFirstView = view;
        }
    }
    
    [self setupShareButton:next];
}


- (void)setupTypeOne
{
    [self.containerView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.containerView addSubview:self.descriptionLabel];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20.f);
        make.bottom.offset(-17.f);
        make.right.offset(-20.f);
    }];
    
    [self setupTitleView];
    
    self.bgImageView.image = [UIImage imageNamed:_cardModel.imageName];
    self.descriptionLabel.text = _cardModel.describe;
    if (_cardModel.backgroundType.length) {
        if ([_cardModel.backgroundType isEqual:@"dark"]) {
            self.descriptionLabel.textColor = [UIColor whiteColor];
        } else {
            self.descriptionLabel.textColor = [UIColor grayColor];
        }
    } else {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.descriptionLabel.textColor = [UIColor whiteColor];
        } else {
            self.descriptionLabel.textColor = [UIColor grayColor];
        }
    }
}

- (void)setupTypeTwo
{
    [self setupTitleView];
    
    self.appListView.notCard = !(_cardModel.viewMode == CardViewModeCard && !_cardModel.isTransition);
    if (self.cardModel.viewMode == CardViewModeCard && !_cardModel.isTransition && _cardModel.apps.count > 4) {
        self.appListView.listArray = [_cardModel.apps subarrayWithRange:NSMakeRange(0, 4)];
    } else {
        self.appListView.listArray = _cardModel.apps;
    }
    [self.containerView addSubview:self.appListView];
    [self.appListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(self.appListView.listArray.count * 70);
        if (self.cardModel.isTitleOver) {
            make.top.equalTo(self.titleView.mas_bottom).offset(15.f);
        } else {
            make.top.equalTo(self.titleView.mas_bottom).offset(25.f);
        }
    }];
}

- (void)setupTypeThree
{
    [self setupTitleView];
    
    [self.containerView addSubview:self.appCollectView];
    [self.appCollectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        if (self.cardModel.isTitleOver) {
            make.bottom.offset(-7.f);
        } else {
            make.bottom.offset(-12.f);
        }
        make.height.offset(3 * (itemWidth + itemSpace));
    }];
}

- (void)setupTitleView
{
    CGFloat topOffset = _cardModel.viewMode == CardViewModeCard ? 16.0f : kStatusBarHeight;
    [self.containerView addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.offset(topOffset);
    }];
    
    self.titleView.model = _cardModel;
}

- (void)setupShareButton:(UIView *)last
{
    [self.scrollView insertSubview:self.shareBtn belowSubview:self.containerView];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (last) {
            make.top.equalTo(last.mas_bottom).offset(80);
        } else {
            if (self.cardModel.viewMode == CardViewModeCard) {
                make.top.equalTo(self.containerView.mas_bottom).offset(40);
            } else {
                make.top.offset([self.cardModel getFullSize].height + 40);
            }
        }
        make.centerX.offset(0);
        make.bottom.offset(-40.f - kSafeAreaBottom);
        make.width.offset(120.f);
        make.height.offset(50.f);
    }];
}

- (void)addCardShadow
{
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(4, 15.0f);
    self.shadowView.layer.shadowRadius = 15.0f;
    self.shadowView.layer.shadowOpacity = 0.25f;
}

- (void)addBgShadow
{
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowOffset = CGSizeMake(4, 15.0f);
    self.bgView.layer.shadowRadius = 15.0f;
    self.bgView.layer.shadowOpacity = 0.25f;
}

- (void)closeAction
{
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)setCloseButtonImage
{
    if (_cardModel.backgroundType.length) {
        [self typeChangeButtonImage];
    } else {
        [self modeChangeButtonImage];
    }
}

- (void)typeChangeButtonImage
{
    if ([_cardModel.backgroundType isEqual:@"dark"]) {
        [_closeButton setImage:[UIImage imageNamed:@"lightOnDark"] forState:UIControlStateNormal];
    } else {
        [_closeButton setImage:[UIImage imageNamed:@"darkOnLight"] forState:UIControlStateNormal];
    }
}

- (void)modeChangeButtonImage
{
    if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        [_closeButton setImage:[UIImage imageNamed:@"lightOnDark"] forState:UIControlStateNormal];
    } else {
        [_closeButton setImage:[UIImage imageNamed:@"darkOnLight"] forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= [self.cardModel getFullSize].height - 30.f) {
        [self modeChangeButtonImage];
    } else {
        [self setCloseButtonImage];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self scrollViewDidScroll:self.scrollView];
}


//MARK: Lazy Load

- (CardTitleView *)titleView {
    if (_titleView == nil) {
        _titleView = [CardTitleView new];
    }
    return _titleView;
}

- (UIImageView *)bgImageView {
    if (_bgImageView == nil) {
        _bgImageView = [UIImageView new];
        _bgImageView.contentMode = UIViewContentModeCenter;
    }
    return _bgImageView;
}

- (UILabel *)descriptionLabel {
    if (_descriptionLabel == nil) {
        _descriptionLabel = [UILabel new];
        _descriptionLabel.font = [UIFont systemFontOfSize:15];
        _descriptionLabel.numberOfLines = 1;
    }
    return _descriptionLabel;
}

- (CardAppListView *)appListView {
    if (_appListView == nil) {
        _appListView = [[CardAppListView alloc] init];
    }
    return _appListView;
}

- (CardAppCollectView *)appCollectView {
    if (_appCollectView == nil) {
        _appCollectView = [[CardAppCollectView alloc] initWithCardModel:_cardModel];
    }
    return _appCollectView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setCloseButtonImage];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.verticalScrollIndicatorInsets = UIEdgeInsetsMake([self.cardModel getFullSize].height - kStatusBarHeight, 0, 0, 0);
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)containerView
{
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [self getBackgroundColor];
        _containerView.layer.masksToBounds = YES;
        _containerView.userInteractionEnabled = NO;
    }
    return _containerView;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.layer.masksToBounds = YES;
        _coverView.layer.cornerRadius = self.bgView.layer.cornerRadius;// 不是点击关闭按钮dismiss一开始就是16.f
    }
    return _coverView;
}

- (UIView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIView alloc] init];
        _shadowView.layer.cornerRadius = 16.f;
        _shadowView.userInteractionEnabled = NO;
        _shadowView.backgroundColor = [self getBackgroundColor];
    }
    return _shadowView;
}

- (UIView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [self getBackgroundColor];
    }
    return _bgView;
}

- (UIColor *)getBackgroundColor
{
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
        if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
            return [UIColor whiteColor];
        } else {
            return [UIColor systemGray6Color];
        }
    }];
}

- (UIButton *)shareBtn
{
    if (_shareBtn == nil) {
        _shareBtn = [[UIButton alloc] init];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightMedium];
        [_shareBtn setTitle:@"  分享" forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:9.f/255.0 green:132.f/255.0 blue:1.f alpha:1];
            } else {
                return [UIColor whiteColor];
            }
        }] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"Details_share"] forState:UIControlStateNormal];
        _shareBtn.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if ([traitCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor systemGray6Color];
            } else {
                return [UIColor systemGray5Color];
            }
        }];
        _shareBtn.layer.cornerRadius = 8.f;
    }
    return _shareBtn;
}

@end
