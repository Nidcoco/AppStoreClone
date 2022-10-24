//
//  CardCollectionViewCell.m
//  AppStoreClone
//

#import "CardCollectionViewCell.h"

#import <Masonry/Masonry.h>

@implementation CardCollectionViewCell

- (void)setModel:(CardModel *)model
{
    _model = model;
    
    [self.cellView removeFromSuperview];
    
    CardView *cardView = [[CardView alloc] initWithCardModel:model];
    [self.contentView addSubview:cardView];
    
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.cellView = cardView;
}


@end
