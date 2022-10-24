//
//  CardAppCollectView.m
//  AppStoreClone
//

#import "CardAppCollectView.h"

#import "CardAppCollectCell.h"
#import "CardMacro.h"

#define dataCount [_model sortDataArray:0].count

@interface CardAppCollectView ()<UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation CardAppCollectView
{
    CardModel *_model;
    NSTimeInterval _startTime;
}

- (instancetype)initWithCardModel:(CardModel *)model
{
    self = [super init];
    if (self) {
        _model = model;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.collectionView];
    [self setAnimation];
}

- (void)setAnimation
{
    CGFloat xOffset = 0; // 偏移x值
    if (_model.startTime != 0) {
        NSTimeInterval time = CFAbsoluteTimeGetCurrent() - _model.startTime;
        float point = time - floor(time);
        NSInteger remainder = (NSInteger)floor(time) % (_model.apps.count * 15);
        float differ = point + remainder;
        xOffset = _model.apps.count * (itemWidth + itemSpace) * (differ / (_model.apps.count * 15));
    } else {
        _model.startTime = CFAbsoluteTimeGetCurrent();
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(ceilf(dataCount * itemWidth + (dataCount - 1) * itemSpace)/2 - xOffset, (3 * itemWidth + 2 * itemSpace) / 2)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(ceilf((dataCount * itemWidth + (dataCount - 1) * itemSpace)/2 - xOffset - (_model.apps.count * (itemWidth + itemSpace))), (3 * itemWidth + 2 * itemSpace) / 2)];
    animation.values = @[value1,value2];
    animation.repeatCount = MAXFLOAT;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    animation.duration = _model.apps.count * 15;// 不管数量多少都可以速度一样
    animation.delegate = self;
    [self.collectionView.layer addAnimation:animation forKey:_model.ID];
    
}

- (CGFloat)xOffset
{
    return self.collectionView.layer.presentationLayer.frame.origin.x;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CardAppCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CardAppCollectCell class]) forIndexPath:indexPath];
    CardAppModel *appModel = [_model sortDataArray:indexPath.section][indexPath.row];
    [cell configWithModel:appModel];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section % 2 == 0) {
        return UIEdgeInsetsMake(0, 0, itemSpace, 0);
    } else {
        return UIEdgeInsetsMake(0, - (itemWidth + itemSpace) / 2, itemSpace, (itemWidth + itemSpace) / 2);
    }
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *_layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = itemSpace;
        _layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        // 不用ceilf,12 Pro Max机型,当有时候collectionView的布局会乱
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ceilf(dataCount * itemWidth + (dataCount - 1) * itemSpace), 3 * itemWidth + 2 * itemSpace) collectionViewLayout:_layout];
        _collectionView.dataSource = self;    
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CardAppCollectCell class] forCellWithReuseIdentifier:NSStringFromClass([CardAppCollectCell class])];
    }
    return _collectionView;
}


@end
