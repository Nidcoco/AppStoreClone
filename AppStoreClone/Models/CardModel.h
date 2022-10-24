//
//  CardModel.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CardMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CardViewOne, // 简单的图文样式
    CardViewTwo, // 应用列表下载样式
    CardViewThree, // 应用移动样式
} CardViewType;

typedef enum : NSUInteger {
    CardViewModeCard,
    CardViewModeFull,
} CardViewMode;

typedef enum : NSUInteger {
    CardViewText,
    CardViewImage,
    CardViewApps,
    CardViewLine,
} CardViewContentType;

@interface CardAppModel : NSObject

@property (nonatomic, copy) NSString *appIcon;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appDescribe;

@end

@interface CardTextContentModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGFloat font;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *weight;

@end

@interface CardContentModel : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) id content;

@property (nonatomic, assign) CardViewContentType contentType;

@end

@interface CardModel : NSObject

@property (nonatomic, assign) CardViewType viewType;

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cardTypeTitle;
@property (nonatomic, copy) NSString *describe;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *backgroundType; // dark or light, 只有CardViewOne需要, 没图片的样式随系统暗黑模式变化

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *apps;

///< 新增
- (CGSize)getCardSize;
- (CGSize)getFullSize;

@property (nonatomic, assign, getter=isTitleOver) BOOL titleOver; // 标题是否超两行
@property (nonatomic, assign, getter=isTransition) BOOL transition; // 只用来区分CardViewModeCard的过渡页面, CardViewModeFull因为是直接拿详情页的模型

@property (nonatomic, assign) CGFloat startTime; // 根据时间差计算偏移
- (NSArray *)sortDataArray:(NSInteger)section;  // 重新排列apps

@property (nonatomic, assign) CardViewMode viewMode;

@end

NS_ASSUME_NONNULL_END
