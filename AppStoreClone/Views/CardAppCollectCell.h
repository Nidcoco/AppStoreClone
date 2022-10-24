//
//  CardAppCollectCell.h
//  AppStoreClone
//
//  Created by Levi on 2021/2/4.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardAppCollectCell : UICollectionViewCell

- (void)configWithModel:(CardAppModel *)model;

@end

NS_ASSUME_NONNULL_END
