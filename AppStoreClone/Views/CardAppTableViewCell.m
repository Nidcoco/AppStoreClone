//
//  CardAppTableViewCell.m
//  AppStoreClone
//

#import "CardAppTableViewCell.h"
#import "CardAccessoryView.h"
#import "CardModel.h"

#import <Masonry/Masonry.h>

@implementation CardAppTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    CardAccessoryView *accessoryView = [[CardAccessoryView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    self.accessoryView = accessoryView;
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10.f);
        make.bottom.offset(-10.f);
        make.left.offset(20.f);
        make.width.equalTo(self.imageView.mas_height);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(85.f);
        make.top.offset(15.5f);
        make.right.offset(-15.f);
    }];
    
    [self.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textLabel);
        make.top.equalTo(self.textLabel.mas_bottom).offset(2.5f);
        make.right.equalTo(self.textLabel);
    }];
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 12.f;
    
    self.detailTextLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:13];

}


- (void)setModel:(CardAppModel *)model
{
    _model = model;
    self.imageView.image = [UIImage imageNamed:model.appIcon];
    self.textLabel.text = model.appName;
    self.detailTextLabel.text = model.appDescribe;
    
    UIFont *nameFont = self.isContent ? [UIFont systemFontOfSize:16] : [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    UIFont *descFont = [UIFont systemFontOfSize:13];
    self.textLabel.font = nameFont;
    
    CGFloat oneRowNameHeight = [model.appName sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:nameFont, NSFontAttributeName, nil]].height;
    CGFloat oneRowDescHeight = [model.appDescribe sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:descFont, NSFontAttributeName, nil]].height;
    NSDictionary *nameAttribute = @{
        NSFontAttributeName:nameFont,
    };
    NSDictionary *descAttribute = @{
        NSFontAttributeName:descFont,
    };
    CGFloat width;
    if (self.isContent) {
        width = kScreenWidth - 195; // 多出5
        self.separatorInset = UIEdgeInsetsMake(0, 90, 0, 20);
    } else {
        width = self.notCard ? kScreenWidth - 190 : kScreenWidth - 230;
        self.separatorInset = UIEdgeInsetsMake(0, 85, 0, 20);
    }
    
    CGFloat nameHeight = [model.appName boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:nameAttribute context:nil].size.height;
    CGFloat descHeight = [model.appDescribe boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:descAttribute context:nil].size.height;
    
    // 有标题多行就先显示标题多行
    if (nameHeight > oneRowNameHeight) {
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.numberOfLines = 1;
        
        [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.isContent) {
                make.left.offset(90.f);
                make.top.offset(12.f);
            } else {
                make.top.offset(8.5f);
            }
        }];
    } else {
        
        if (descHeight > oneRowDescHeight) {
            self.textLabel.numberOfLines = 1;
            self.detailTextLabel.numberOfLines = 2;
            [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                if (self.isContent) {
                    make.left.offset(90.f);
                    make.top.offset(14.f);
                } else {
                    make.top.offset(8.5f);
                }
            }];
        } else {
            self.textLabel.numberOfLines = 1;
            self.detailTextLabel.numberOfLines = 1;
            [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                if (self.isContent) {
                    make.left.offset(90.f);
                    make.top.offset(20.f);
                } else {
                    make.top.offset(15.5f);
                }
            }];
        }
    }
}

- (void)setHiddenLine:(BOOL)hiddenLine
{
    _hiddenLine = hiddenLine;
    if (hiddenLine) {
        self.separatorInset = UIEdgeInsetsMake(0, kScreenWidth, 0, 0);
    } else {
        if (self.isContent) {
            self.separatorInset = UIEdgeInsetsMake(0, 90, 0, 20);
        } else {
            self.separatorInset = UIEdgeInsetsMake(0, 85, 0, 20);
        }
    }
}

@end
