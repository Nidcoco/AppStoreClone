//
//  BaseCollectionViewCell.m
//  AppStoreClone
//

#import "BaseCollectionViewCell.h"

@implementation BaseCollectionViewCell

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.zoomDelegate respondsToSelector:@selector(touchesBeganWithCell:)]) {
        [self.zoomDelegate touchesBeganWithCell:self];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if ([self.zoomDelegate respondsToSelector:@selector(touchesEndedWithCell:)]) {
        [self.zoomDelegate touchesEndedWithCell:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    if ([view isKindOfClass:[UIButton class]]) {
        return view;
    }

    if ([view isDescendantOfView:self]) {
        return self;
    }
    return view;
}


@end
