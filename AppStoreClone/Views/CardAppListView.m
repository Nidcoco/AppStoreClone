//
//  CardAppListView.m
//  AppStoreClone
//

#import "CardAppListView.h"
#import "CardMacro.h"
#import "CardAccessoryView.h"
#import "CardAppTableViewCell.h"

#import <Masonry/Masonry.h>

@interface CardAppListView ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation CardAppListView

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
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardAppTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CardAppTableViewCell class])];
    cell.isContent = self.isContent;
    cell.notCard = self.notCard;
    CardAppModel *model = self.listArray[indexPath.row];
    cell.model = model;
    cell.hiddenLine = (self.listArray.count - 1 == indexPath.row);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isContent) {
        return 81.f;
    } else {
        return 70.f;
    }
}

#pragma mark - set/get


- (void)setListArray:(NSArray *)listArray
{
    _listArray = listArray;
    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.scrollEnabled = NO;
        [_tableView registerClass:[CardAppTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CardAppTableViewCell class])];
    }
    return _tableView;
}


@end
