//
//  CardView.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/16.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardView : UIView

@property (nonatomic, strong) CardModel *cardModel;
- (instancetype)initWithCardModel:(CardModel *)cardModel;

@property (nonatomic, copy) void (^closeBlock) (void);
@property (nonatomic, strong) UIScrollView *scrollView;

// 布局改变动画
- (void)updateLayout:(CardViewMode)viewMode;
- (void)animationsAction:(CardViewMode)viewMode;

// 解决containerView滑动离屏幕越远, dismiss的时候弹性越大的问题和内容视图containerView上面要遮罩, 该方法dismiss动画前调用
- (void)updateContainerViewLayout;

// 下拉和侧滑dismiss视图, 需要实时调用该方法控制部分控件的圆角的关闭按钮的透明度
- (void)zoomAction:(CGFloat)cornerRadius;


@end

NS_ASSUME_NONNULL_END
