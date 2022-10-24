//
//  DetailViewController.m
//  AppStoreClone
//

#import "DetailViewController.h"

#import <Masonry/Masonry.h>

typedef enum : NSUInteger {
    DetailDimissTypeNone,
    DetailDimissTypeRight, // 侧滑
    DetailDimissTypeUp, // 下滑
    DetailDimissTypeScroll, // 拖动滚动条
} DetailDimissType;

@interface DetailViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) CardModel *cardModel;

@end

@implementation DetailViewController
{
    double _ratio;
    CGPoint _touchPoint;
    CGFloat _touchY;
    DetailDimissType _dissType;
}

#pragma mark - LifeCicle(生命周期)

- (instancetype)initWithCardModel:(CardModel *)cardModel
{
    self = [super init];
    if (self) {
        _cardModel = cardModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

#pragma mark - Target Mehtods(事件方法)

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGFloat upSlide = [recognizer translationInView:self.view].y;
    CGFloat rightSlide = [recognizer translationInView:self.view].x;
    
    CGFloat y = [recognizer velocityInView:self.view].y;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _touchPoint = [recognizer locationInView:recognizer.view];
        _ratio = 1.f;
        _dissType = DetailDimissTypeNone;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat progress = 0;
        if (_dissType == DetailDimissTypeRight || (_touchPoint.x < 50 && rightSlide > 0 && _dissType != DetailDimissTypeUp && _dissType != DetailDimissTypeScroll)) { // 侧滑dismiss必须要靠近屏幕左侧
            _dissType = DetailDimissTypeRight;
            progress = rightSlide / kScreenWidth;
            progress = fminf(fmaxf(progress, 0.0), 1.0) * 0.5;
        } else if (_dissType == DetailDimissTypeUp || (self.cardView.scrollView.contentOffset.y <= 0 && upSlide > 0 && _dissType != DetailDimissTypeRight && _dissType != DetailDimissTypeScroll)) { // 下滑
            _dissType = DetailDimissTypeUp;
            progress = upSlide / kScreenHeight;
            progress = fminf(fmaxf(progress, 0.0), 1.0);
        } else if (_dissType == DetailDimissTypeScroll || (self.cardView.scrollView.contentOffset.y < 0 && y > 0 && _dissType != DetailDimissTypeRight && _dissType != DetailDimissTypeUp)) { //滚动条
            // 记录第一次触发的坐标
            CGFloat y = [recognizer locationInView:recognizer.view].y;
            if (_dissType != DetailDimissTypeScroll) {
                _touchY = y;
            }
            _dissType = DetailDimissTypeScroll;
            progress = (y - _touchY) / kScreenHeight;
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
        
        [self.cardView zoomAction:progress * 16.f / 0.18];
        self.cardView.transform = CGAffineTransformMakeScale(_ratio, _ratio);
        
        
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

#pragma mark - Delegate(代理)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - UI(UI创建)

// 页面UI
- (void)setupViews {
    CardModel *cardModel = self.cardModel;
    cardModel.viewMode = CardViewModeFull;
    self.cardView = [[CardView alloc] initWithCardModel:cardModel];
    self.cardView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    __weak typeof(self) weakSelf = self;
    self.cardView.closeBlock = ^{
        [weakSelf close];
    };
    [self.view addSubview:self.cardView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pan.delegate = self;
    [self.cardView addGestureRecognizer:pan];
}

#pragma mark - Setter & Getter

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
