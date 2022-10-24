//
//  CardModel.m
//  AppStoreClone
//

#import "CardModel.h"
#import "CardAppCollectView.h"

@implementation CardAppModel

@end

@implementation CardTextContentModel

@end

@implementation CardContentModel

- (CardViewContentType)contentType
{
    if ([_type isEqualToString:@"text"]) {
        return CardViewText;
    } else if ([_type isEqualToString:@"image"]) {
        return CardViewImage;
    } else if ([_type isEqualToString:@"app"]) {
        return CardViewApps;
    } else {
        return CardViewLine;
    }
}

@end

@implementation CardModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"apps": @"CardAppModel",
             @"contents": @"CardContentModel",
    };
}

- (CGSize)getCardSize
{
    switch (self.viewType) {
        case CardViewOne:
            return CGSizeMake(kScreenWidth, 460.0f + 29.f);
        case CardViewTwo:
        case CardViewThree:
            return CGSizeMake(kScreenWidth, 413.0f + 29.f);
        default:
            return CGSizeZero;
    }
}

- (CGSize)getFullSize
{
    switch (self.viewType) {
        case CardViewOne:
            return CGSizeMake(kScreenWidth, 548.0f);
        case CardViewTwo:
            return CGSizeMake(kScreenWidth, 413.f - 20 + kStatusBarHeight + (self.apps.count - 4) * 70.f);
        case CardViewThree:
            return CGSizeMake(kScreenWidth, 413.0f + 29.f);
        default:
            return CGSizeZero;
    }
}

- (BOOL)isTitleOver
{
    [self titleHeight];
    
    return _titleOver;
}

- (CGFloat)titleHeight
{
    UIFont *titleFont = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    CGFloat oneRowTitleHeight = [self.title sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, nil]].height;
    NSDictionary *nameAttribute = @{
        NSFontAttributeName:titleFont,
    };
    CGFloat width = self.viewMode == CardViewModeCard ? kScreenWidth - 80 : kScreenWidth - 40;
    CGFloat titleHeight = [self.title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:nameAttribute context:nil].size.height;
    
    if (titleHeight > oneRowTitleHeight) {
        _titleOver = YES;
        return oneRowTitleHeight * 2;
    }
    return oneRowTitleHeight;
}

- (NSArray *)sortDataArray:(NSInteger)section
{
    NSMutableArray *sort = [[NSMutableArray alloc] initWithArray:self.apps];
    [sort addObjectsFromArray:self.apps];
    while (sort.count < ceilf(2 * everyItem)) {
        [sort addObjectsFromArray:self.apps];
    }
    NSInteger changeLen = section * (self.apps.count / 3) + 1;// 3表示3行,collectionView一共3行, changLen表示移动的长度, 移动方式是从后面去changLen的数组插入前面
    NSRange chanegRange = NSMakeRange(sort.count - changeLen, changeLen);
    NSArray *array = [sort subarrayWithRange:chanegRange];
    [sort removeObjectsInRange:chanegRange];
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, changeLen)];
    [sort insertObjects:array atIndexes:set];
    return sort;
}

@end
