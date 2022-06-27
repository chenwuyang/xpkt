//
//  NoticeView.m
//  MacApp
//
//  Created by lanshan on 2022/6/23.
//

#import "NoticeView.h"

@interface NoticeView()
@end

@implementation NoticeView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[[NSColor blackColor] colorWithAlphaComponent:0.7] set];
    NSRectFill([self bounds]);
}

- (void)viewWillMoveToSuperview:(nullable NSView *)newSuperview{
    [super viewWillMoveToSuperview:newSuperview];
    [self addTextField];
}

- (void)addTextField{
    [self.bgView removeFromSuperview];
    [self.title removeFromSuperview];
    [self.content removeFromSuperview];
    [self.button removeFromSuperview];
    
    self.bgView = [[NSView alloc] initWithFrame:CGRectMake((self.bounds.size.width-377)/2, (self.bounds.size.height-130)/2, 377, 130)];
    [self.bgView setWantsLayer:YES];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self addSubview:self.bgView];
    
    self.title = [[NSTextField alloc] initWithFrame:CGRectMake((self.bgView.frame.size.width-100)/2, 100, 100, 20)];
    self.title.alignment = NSTextAlignmentCenter;
    self.title.textColor = [NSColor blackColor];
    self.title.font = [NSFont systemFontOfSize:12];
    [self.title setStringValue:@"温馨提示"];
    [self.title setBezeled:NO];
    [self.title setDrawsBackground:NO];
    [self.title setEditable:NO];
    [self.title setSelectable:NO];
    [self.bgView addSubview:self.title];
    
    self.content = [[NSTextField alloc] initWithFrame:CGRectMake(30, 50, 317, 40)];
    self.title.alignment = NSTextAlignmentCenter;
    self.content.textColor = [NSColor grayColor];
    self.content.font = [NSFont systemFontOfSize:12];
    [self.content setStringValue:@"系统检测到您可能开启了录屏应用，为了不影响您正常使用，请关闭录屏应用!"];
    [self.content setBezeled:NO];
    [self.content setDrawsBackground:NO];
    [self.content setEditable:NO];
    [self.content setSelectable:NO];
    [self.bgView addSubview:self.content];
    
    self.button = [[NSButton alloc] initWithFrame:NSMakeRect((self.bgView.frame.size.width-100)/2, 10, 114, 20)];
    [self.button setTitle:@"知道了"];
    [self.button setWantsLayer:YES];
    self.button.layer.backgroundColor = [NSColor redColor].CGColor;
    [self.button setBezelStyle:NSBezelStyleInline];//设置边框样式为‘圆状曲线’
    [self.button setTarget:self];
    [self.button setAction:@selector(buttonAction)];
    self.button.layer.cornerRadius = 10;
    self.button.layer.masksToBounds = YES;
    [self setBtnTitleColorwithColor:[NSColor whiteColor] andStr:@"知道了" andBtn:self.button];

    [self.bgView addSubview:self.button];
}

- (void)buttonAction{
    if (self.block) {
        self.block();
    }
}

- (void)setBtnTitleColorwithColor:(NSColor*)color andStr:(NSString*)str andBtn:(NSButton*)btn{
    NSMutableParagraphStyle *pghStyle = [[NSMutableParagraphStyle alloc] init];
    pghStyle.alignment = NSTextAlignmentCenter;
    // 创建Attributes，设置颜色和段落样式
    NSDictionary *dicAtt = @{NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName: pghStyle};
    btn.title=@" ";
    NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc] initWithAttributedString:btn.attributedTitle];
    // 替换文字
    [attTitle replaceCharactersInRange:NSMakeRange(0, 1) withString:str];
    // 添加属性
    [attTitle addAttributes:dicAtt range:NSMakeRange(0, str.length)];
    btn.attributedTitle= attTitle;
}


@end
