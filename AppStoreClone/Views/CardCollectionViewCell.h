//
//  CardCollectionViewCell.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/16.
//

#import "BaseCollectionViewCell.h"
#import "CardModel.h"
#import "CardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardCollectionViewCell : BaseCollectionViewCell

@property (nonatomic, weak) CardView *cellView;

@property (nonatomic, strong) CardModel *model;

@end

NS_ASSUME_NONNULL_END
