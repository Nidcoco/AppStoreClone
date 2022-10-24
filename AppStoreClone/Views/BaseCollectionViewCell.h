//
//  BaseCollectionViewCell.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BaseCollectionViewCell;

@protocol BaseCollectionViewCellDelegate <NSObject>

@optional

- (void)touchesBeganWithCell:(UICollectionViewCell *)cell;

- (void)touchesEndedWithCell:(UICollectionViewCell *)cell;

@end

@interface BaseCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) id<BaseCollectionViewCellDelegate> zoomDelegate;

@end

NS_ASSUME_NONNULL_END
