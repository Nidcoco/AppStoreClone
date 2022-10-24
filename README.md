
![演示](https://upload-images.jianshu.io/upload_images/12618366-be312f3ed6a4216a.gif?imageMogr2/auto-orient/strip)
> 之前就想试做下这页面玩的，然后工程创建了很久太懒一直没去做，国庆前辞职了，然后就想着花个两个星期搞完再去找工作，结果一发不可收拾，为了快点找工作草草结束了，最后的效果虽然看似和App Store差不多，但细看转场那里还是有点区别的，代码写的也比较乱，离屏渲染，以下我只说下列表页cell点击缩放效果、转场、详情页手势dismiss的实现。

# 一、cell点击缩放
之前我看很多人是在tableView的`shouldHighlightRowAtIndexPath:`方法缩小，`didUnhighlightRowAtIndexPath:`恢复正常，然后自己试了下，感觉会有一点点延时，而且如果你上滑都顶部，松开手让tableView回弹的瞬间按下cell的时候，cell会瞬间缩小并恢复了正常，而我的手指并没有松开，应该是UITableView的弹性和手势的冲突问题导致`didUnhighlightRowAtIndexPath:`方法触发了，我看App Store里面回弹的瞬间，如果按下，cell依旧是缩小状态，并没有恢复正常。
所以这里我用的是这位老哥的方法：[iOS 仿AppStore首页Today列表Cell触碰或按下效果](https://blog.csdn.net/wnnvv/article/details/102085784 "Title")

就是定义了个TableViewCell的基类，在里面响应手势

```
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BaseCollectionViewCell;

@protocol BaseCollectionViewCellDelegate <NSObject>

@optional

- (void)touchesBeganWithCell:(UICollectionViewCell *)cell;

- (void)touchesEndedWithCell:(UICollectionViewCell *)cell;

@end

@interface BaseCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) id<BaseCollectionViewCellDelegate> zoomDelegate;

@end

NS_ASSUME_NONNULL_END

#import "BaseCollectionViewCell.h"

@implementation BaseCollectionViewCell

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.zoomDelegate respondsToSelector:@selector(touchesBeganWithCell:)]) {
        [self.zoomDelegate touchesBeganWithCell:self];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self.zoomDelegate respondsToSelector:@selector(touchesEndedWithCell:)]) {
        [self.zoomDelegate touchesEndedWithCell:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    if ([view isKindOfClass:[UIButton class]]) {
        return view;
    }

    if ([view isDescendantOfView:self]) {
        return self;
    }
    return view;
}


@end


```
手势开始的方法实现缩小，手势结束的方法实现跳转详情页，而cell恢复正常的操作只需在`scrollViewDidScroll:`里面做。

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_selectCell) {
        [self enlargeCellAction:_selectCell];
    }
}


- (void)touchesBeganWithCell:(UICollectionViewCell *)cell
{
    if (_selectCell) { // 多个cell同时点击会触发多次, 只响应第一个触发的cell
        return;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96);
    } completion:^(BOOL finished) {
    }];
    _selectCell = cell;
}

- (void)touchesEndedWithCell:(UICollectionViewCell *)cell
{
    if (_selectCell != cell) {
        return;
    }
    
    // 跳转
    ...
}
```

# 二、转场
主要实现`UIViewControllerAnimatedTransitioning`的`animateTransition:`方法来实现转场动画，不管是Today跳到详情页，还是详情页回到Today也都是会调用这个方法，但具体实现不同。

* Today页跳到详情页
这个过程是先生成了一个和cell一样的视图当成中间视图，然后隐藏了cell，再把这个视图移动放大动画到详情页后再隐藏，然后显示详情页

* 详情页回到Today页
这里因为要考虑到，页面下滑了，页面的scrollView的contentOffset改变了，如果生成一个中间视图，生成的中间视图的scrollView的contentOffset刚开始为0，到时候要手动改变contentOffset，所以我直接用详情页的视图，将他添加到中转页上进行缩放移动成cell，然后显示之前隐藏的cell，中转页销毁了

```
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
    if (_transition == CardTransitionPresentation) { // Today页跳到详情页
        cardViewCopy = [self createCardViewCopy:cardView];
        [containerView addSubview:cardViewCopy];
        
        cardViewCopy.frame = _transition == CardTransitionPresentation ? absoluteCardViewFrame : containerView.frame;
        [cardViewCopy layoutIfNeeded];
        
        cardView.hidden = true;
        
        DetailViewController *detailVC = (DetailViewController *)toVC;
        [containerView addSubview:detailVC.view];
        detailVC.view.hidden = true;
        // 转场动画
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
        
        // 转场动画
        [self moveAndConvertToCardView:cardViewCopy containerView:containerView yOriginToMoveTo:absoluteCardViewFrame.origin.y completion:^{
            cardView.hidden = false;
            [transitionContext completeTransition:YES];
        }];
    }
    
}
```

转场动画太复杂了，阴影圆角约束变来变去，我代码写的也比较乱，自己隔段时间看，估计自己都看不懂，具体实现可以看代码，动画看不清的可以录屏然后一帧一帧地看

# 三、详情页手势dismiss
详情页回到Today页面主要有三种方式，点击关闭按钮，侧滑，下拉
点击关闭按钮就不说了，主要是侧滑、下拉。侧滑先判断手势开始的点的x要小于50，下拉的条件则是scrollView.contentOffset.y <= 0，然后视图的圆角和关闭按钮的透明度会随着手势的移动变化，手势移动过程中如果小于某个值就dismiss，手势结束或取消的时候判断如果移动不小于那个值就回复正常。
下拉其实还分两种情况，第一种就是正常的当scrollView.contentOffset.y <= 0，这时候下拉dismiss，还有一种就是滚动条拖拽到scrollView.contentOffset.y <= 0的时候，再下拉就会dismiss，具体可以运行代码手动试一下，也可以在App Store上试试，两种情况有点不同。
```
typedef enum : NSUInteger {
    DetailDimissTypeNone,
    DetailDimissTypeRight, // 侧滑
    DetailDimissTypeUp, // 下滑
    DetailDimissTypeScroll, // 拖动滚动条
} DetailDimissType;

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    
    // 移动的坐标
    CGFloat upSlide = [recognizer translationInView:self.view].y;
    CGFloat rightSlide = [recognizer translationInView:self.view].x;
    
    // 手指的y值
    CGFloat y = [recognizer velocityInView:self.view].y;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // 手势记录刚开始的坐标
        _touchPoint = [recognizer locationInView:recognizer.view];

        _ratio = 1.f;
        _dissType = DetailDimissTypeNone;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat progress = 0;
        if (_dissType == DetailDimissTypeRight || (_touchPoint.x < 50 && rightSlide > 0 && _dissType != DetailDimissTypeUp && _dissType != DetailDimissTypeScroll)) { // 侧滑dismiss必须要靠近屏幕左侧
            _dissType = DetailDimissTypeRight;
            progress = rightSlide / [UIScreen mainScreen].bounds.size.width;
            progress = fminf(fmaxf(progress, 0.0), 1.0) * 0.5;
        } else if (_dissType == DetailDimissTypeUp || (self.cardView.scrollView.contentOffset.y <= 0 && upSlide > 0 && _dissType != DetailDimissTypeRight && _dissType != DetailDimissTypeScroll)) { // 下滑
            _dissType = DetailDimissTypeUp;
            progress = upSlide / [UIScreen mainScreen].bounds.size.height;
            progress = fminf(fmaxf(progress, 0.0), 1.0);
        } else if (_dissType == DetailDimissTypeScroll || (self.cardView.scrollView.contentOffset.y < 0 && y > 0 && _dissType != DetailDimissTypeRight && _dissType != DetailDimissTypeUp)) { //滚动条
            // 记录第一次触发的坐标
            CGFloat y = [recognizer locationInView:recognizer.view].y;
            if (_dissType != DetailDimissTypeScroll) {
                _touchY = y;
            }
            _dissType = DetailDimissTypeScroll;
            progress = (y - _touchY) / [UIScreen mainScreen].bounds.size.height;
            progress = fminf(fmaxf(progress, 0.0), 1.0);
        }
        
        if (_dissType != DetailDimissTypeNone) {
            self.cardView.scrollView.scrollEnabled = NO;
        }
        
        // 很奇葩, AppStore侧滑是不用隐藏滚动条的
        if (_dissType == DetailDimissTypeUp || _dissType == DetailDimissTypeScroll) {
            self.cardView.scrollView.showsVerticalScrollIndicator = NO;
        }
        
        _ratio = 1.0f - progress;
        
        // 视图缩小，圆角，关闭按钮透明度变化
        [self.cardView zoomAction:progress * 16.f / 0.18];
        self.cardView.transform = CGAffineTransformMakeScale(_ratio, _ratio);
        
        // 达到条件，dismiss视图
        if (_ratio <= 0.82) {
            [self close];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        if (_ratio > 0.82) {
            [UIView animateWithDuration:0.1 animations:^{
                self.cardView.transform = CGAffineTransformIdentity;
                [self.cardView zoomAction:0];
            }];
            
            self.cardView.scrollView.scrollEnabled = YES;
            self.cardView.scrollView.showsVerticalScrollIndicator = YES;
        }
    }
    
}
```


# 最后

[Demo](https://github.com/Nidcoco/AppStoreClone.git)
最后真的是没什么耐心写了，后续有空卡片会多加点样式和优化下代码，代码写的比较烂，有好的建议可以发我邮箱2387356991@qq.com，Demo跪求星星，感激不尽





