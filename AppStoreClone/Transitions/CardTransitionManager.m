//
//  CardTransitionManager.m
//  AppStoreClone
//

#import "CardTransitionManager.h"

#import "CardModel.h"
#import "CardView.h"

#import "TodayViewController.h"
#import "DetailViewController.h"

#import <Masonry/Masonry.h>
#import "YYModel.h"

typedef enum : NSUInteger {
    CardTransitionPresentation, // 跳转详情的动画
    CardTransitionDismissal,    // 退出详情的动画
} CardTransitionType;

@interface CardTransitionManager ()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, assign) CardTransitionType transition;

@end

@implementation CardTransitionManager
{
    NSTimeInterval _transitionDuration;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.85;
        _transition = CardTransitionPresentation;
    }
    return self;
}

#pragma mark - Private Methods(私有方法)

- (CGFloat)blurAlpha:(CardTransitionType)transition
{
    return transition == CardTransitionPresentation ? 1 : 0;
}

- (CardViewMode)cardMode:(CardTransitionType)transition
{
    return transition == CardTransitionPresentation ? CardViewModeCard : CardViewModeFull;
}

- (CardTransitionType)next
{
    return _transition == CardTransitionPresentation ? CardTransitionDismissal : CardTransitionPresentation;
}


- (void)addBackgroundViews:(UIView *)containerView
{
    self.blurEffectView.frame = containerView.frame;
    self.blurEffectView.alpha = [self blurAlpha:[self next]];
    [containerView addSubview:self.blurEffectView];
}

- (CardView *)createCardViewCopy:(CardView *)cardView
{
    CardModel *cardModel = [cardView.cardModel yy_modelCopy];
    cardModel.viewMode = [self cardMode:_transition];
    cardModel.transition = YES;
    CardView *cardViewCopy = [[CardView alloc] initWithCardModel:cardModel];
    return cardViewCopy;
}

- (void)moveAndConvertToCardView:(CardView *)cardView containerView:(UIView *)containerView yOriginToMoveTo:(CGFloat)yOriginToMoveTo completion:(void (^)(void))completion
{
    
    UIViewPropertyAnimator *expandContractAnimator = [self makeExpandContractAnimator:cardView containerView:containerView yOrigin:yOriginToMoveTo];
    
    [expandContractAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        completion();
    }];
    
    [expandContractAnimator startAnimation];
}

- (UIViewPropertyAnimator *)makeExpandContractAnimator:(CardView *)cardView containerView:(UIView *)containerView yOrigin:(CGFloat)yOrigin
{
    UISpringTimingParameters *springTiming = [[UISpringTimingParameters alloc] initWithDampingRatio:.7];
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:_transitionDuration timingParameters:springTiming];
    
    [animator addAnimations:^{
        cardView.transform = CGAffineTransformIdentity;
        
        [cardView updateLayout:[self cardMode:[self next]]];
        
        CGSize size = self.transition == CardTransitionPresentation ? CGSizeMake(kScreenWidth, kScreenHeight) : [cardView.cardModel getCardSize];
        CGRect frame = (CGRect){{0, yOrigin}, size}; // 点击缩放的时候x不为0, 手动赋值0
        cardView.frame = frame;
        
        [cardView animationsAction:[self cardMode:[self next]]];
        self.blurEffectView.alpha = [self blurAlpha:self.transition];
    }];
    
    return animator;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    _transition = CardTransitionPresentation;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    _transition = CardTransitionDismissal;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    
    for (UIView *subView in containerView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self addBackgroundViews:containerView];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    TodayViewController *vc;
    if (_transition == CardTransitionPresentation) {
        vc = (TodayViewController *)fromVC;
    } else {
        vc = (TodayViewController *)toVC;
    }
    CardView *cardView = vc.selectedCellCardView;
    if (!cardView) {
        return;
    }
    
    CardView *cardViewCopy;
    
    CGRect absoluteCardViewFrame = [cardView convertRect:cardView.frame toView:nil];
    if (_transition == CardTransitionPresentation) {
        cardViewCopy = [self createCardViewCopy:cardView];
        [containerView addSubview:cardViewCopy];
        
        cardViewCopy.frame = _transition == CardTransitionPresentation ? absoluteCardViewFrame : containerView.frame;
        [cardViewCopy layoutIfNeeded];
        
        cardView.hidden = true;
        
        DetailViewController *detailVC = (DetailViewController *)toVC;
        [containerView addSubview:detailVC.view];
        detailVC.view.hidden = true;
  
        [self moveAndConvertToCardView:cardViewCopy containerView:containerView yOriginToMoveTo:0 completion:^{
            detailVC.view.hidden = false;
            [cardViewCopy removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else {
        DetailViewController *detailVC = (DetailViewController *)fromVC;
        cardViewCopy = detailVC.cardView;
        [containerView addSubview:cardViewCopy];
        
        [cardViewCopy updateContainerViewLayout];
        [cardViewCopy layoutIfNeeded];
        
        [self moveAndConvertToCardView:cardViewCopy containerView:containerView yOriginToMoveTo:absoluteCardViewFrame.origin.y completion:^{
            cardView.hidden = false;
            [transitionContext completeTransition:YES];
        }];
    }
    
}

#pragma mark - Setter & Getter

- (UIVisualEffectView *)blurEffectView
{
    if (_blurEffectView == nil) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _blurEffectView;
}

@end
