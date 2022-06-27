//
//  NoticeView.h
//  MacApp
//
//  Created by lanshan on 2022/6/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ButtonActionBlock)(void);

@interface NoticeView : NSView
@property (nonatomic,strong)NSView *bgView;
@property (nonatomic,strong)NSTextField *title;
@property (nonatomic,strong)NSTextField *content;
@property (nonatomic,strong)NSButton *button;
@property (nonatomic,copy)ButtonActionBlock block;
@end

NS_ASSUME_NONNULL_END
