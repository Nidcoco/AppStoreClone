//
//  DetailViewController.h
//  AppStoreClone
//
//  Created by Levi on 2022/9/23.
//

#import <UIKit/UIKit.h>

#import "CardView.h"
#import "CardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property (nonatomic, strong) CardView *cardView;

- (instancetype)initWithCardModel:(CardModel *)cardModel;

@end

NS_ASSUME_NONNULL_END
