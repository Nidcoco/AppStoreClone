//
//  CardMacro.h
//  AppStoreClone
//
//  Created by Levi on 2020/12/17.
//

#ifndef CardMacro_h
#define CardMacro_h

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define everyItem 4.2    ///< 一个屏幕占多少个item（未适配iPad）
#define itemSpace 10.0f ///< collectionViewCell的间隔
#define everySpace ((ceilf(everyItem) - floorf(everyItem) == 0) ? floorf(everyItem) - 1 : floorf(everyItem)) ///< 一个屏幕占多少个itemSpace
#define itemWidth (kScreenWidth - everySpace * itemSpace) / everyItem  ///< collectionViewCell的宽度

#define kStatusBarHeight [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height

#define kSafeAreaBottom [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom

#endif /* CardMacro_h */
