//
//  TodayViewController.m
//  AppStoreClone
//

#import "TodayViewController.h"
#import "DetailViewController.h"

// Models
#import "CardModel.h"

// Views
#import "CardCollectionViewCell.h"
#import "CardSectionHeaderView.h"

// Framework
#import "YYModel.h"

#import "CardMaCro.h"
#import "CardTransitionManager.h"


@interface TodayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, BaseCollectionViewCellDelegate>

@property (nonatomic, strong) UIVisualEffectView *navigationStatusView;

@property (nonatomic, strong) UICollectionView *collectionView; // 我这里当初因为考虑到了iPad端, 所以用了UICollectionView, 用UITableView就可以

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UICollectionViewCell *selectCell;

@property (nonatomic, strong) CardTransitionManager *transitionManger;

@end

@implementation TodayViewController

#pragma mark - LifeCicle(生命周期)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getData];
    [self setupViews];
 
    _transitionManger = [[CardTransitionManager alloc] init];
}

#pragma mark - Private Methods(私有方法)

- (void)enlargeCellAction:(UICollectionViewCell *)cell
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        cell.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
    _selectCell = nil;
}

- (void)getData
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"CardsData.json" withExtension:nil];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.dataArray =  [NSArray yy_modelArrayWithClass:[CardModel class] json:dict[@"data"]];
}

#pragma mark - Public Methods(公有方法)

- (CardView *)selectedCellCardView
{
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].firstObject;
    CardCollectionViewCell *cell = (CardCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.cellView;
}

#pragma mark - Delegate(代理)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > -kStatusBarHeight) {
        self.navigationStatusView.hidden = NO;
    }else {
        self.navigationStatusView.hidden = YES;
    }
    
    if (_selectCell) {
        [self enlargeCellAction:_selectCell];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CardCollectionViewCell class]) forIndexPath:indexPath];
    cell.zoomDelegate = self;
    CardModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardModel *model = self.dataArray[indexPath.row];
    return [model getCardSize];
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeMake(kScreenWidth, 64.0f);
    return size;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        CardSectionHeaderView *headerV = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CardSectionHeaderView class]) forIndexPath:indexPath];
        reusableview = headerV;
    }
    return reusableview;
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
    
    CardCollectionViewCell *cardCell = (CardCollectionViewCell *)cell;
    CardModel *model = [cardCell.model yy_modelCopy];

    DetailViewController *detailVC = [[DetailViewController alloc] initWithCardModel:model];
    detailVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    detailVC.transitioningDelegate = self.transitionManger;
    
    [self presentViewController:detailVC animated:YES completion:^{
        if (self.selectCell) {
            [self enlargeCellAction:self.selectCell];
        }
    }];
}

#pragma mark - UI(UI创建)

- (void)setupViews {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.navigationStatusView];
}

#pragma mark - Setter & Getter

- (UIVisualEffectView *)navigationStatusView {
    if (_navigationStatusView == nil) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial];
        _navigationStatusView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _navigationStatusView.frame = CGRectMake(0, 0, kScreenWidth, kStatusBarHeight);
        _navigationStatusView.hidden = YES;
    }
    return _navigationStatusView;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(kStatusBarHeight + 28, 0, 0, 0);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delaysContentTouches = NO;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
        [_collectionView registerClass:[CardSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CardSectionHeaderView class])];
        [_collectionView registerClass:[CardCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CardCollectionViewCell class])];
    }
    return _collectionView;
}

@end
