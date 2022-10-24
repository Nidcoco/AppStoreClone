//
//  CardAppListView.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/17.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardAppListView : UIView

// 是否是内容里面的App列表
@property (nonatomic, assign) BOOL isContent;
// 除卡片页之外(卡片过渡页也为true)
@property (nonatomic, assign) BOOL notCard;
@property (nonatomic, strong) NSArray *listArray;

@end

NS_ASSUME_NONNULL_END
