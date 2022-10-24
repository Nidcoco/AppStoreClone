//
//  CardAppTableViewCell.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/19.
//

#import <UIKit/UIKit.h>

@class CardAppModel;

NS_ASSUME_NONNULL_BEGIN

@interface CardAppTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isContent;
@property (nonatomic, assign) BOOL notCard;
@property (nonatomic, strong) CardAppModel *model;
@property (nonatomic, assign) BOOL hiddenLine;

@end

NS_ASSUME_NONNULL_END
