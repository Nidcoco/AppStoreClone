//
//  CardSectionHeaderView.m
//  AppStoreClone
//

#import "CardSectionHeaderView.h"

#import <Masonry/Masonry.h>

@interface CardSectionHeaderView ()

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *todayLabel;
@property (nonatomic, strong) UIImageView *mineImageView;

@end

@implementation CardSectionHeaderView

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
    [self addSubview:self.monthLabel];
    [self addSubview:self.todayLabel];
    [self addSubview:self.mineImageView];
    
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(20.f);
        make.top.offset(0);
    }];
    
    [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthLabel);
        make.top.equalTo(self.monthLabel.mas_bottom).offset(2.f);
    }];
    
    [self.mineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.offset(32.f);
        make.right.offset(-20.f);
        make.centerY.equalTo(self.todayLabel);
    }];
    
    
    [self setupDate];
    
}

- (void)setupDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM月dd日";
    NSString *str = [formatter stringFromDate:date];
    self.monthLabel.text = [NSString stringWithFormat:@"%@ %@",str,[self weekdayStringFromDate:date]];
}

#pragma mark getWeekday

- (NSString *)weekdayStringFromDate:(NSDate *)inputDate {
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekday objectAtIndex:theComponents.weekday];
}


- (UILabel *)monthLabel {
    if (_monthLabel == nil) {
        _monthLabel = [UILabel new];
        _monthLabel.textColor = [UIColor grayColor];
        _monthLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    }
    return _monthLabel;
}

- (UILabel *)todayLabel {
    if (_todayLabel == nil) {
        _todayLabel = [UILabel new];
        _todayLabel.text = @"Today";
        _todayLabel.textColor = [UIColor labelColor];
        _todayLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
    }
    return _todayLabel;
}

- (UIImageView *)mineImageView {
    if (_mineImageView == nil) {
        _mineImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mine"]];
        _mineImageView.layer.masksToBounds = YES;
        _mineImageView.layer.cornerRadius = 16.0f;
    }
    return _mineImageView;
}

@end
