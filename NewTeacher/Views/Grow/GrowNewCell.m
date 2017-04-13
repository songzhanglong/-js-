//
//  GrowNewCell.m
//  NewTeacher
//
//  Created by szl on 16/5/4.
//  Copyright © 2016年 songzhanglong. All rights reserved.
//

#import "GrowNewCell.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "DJTGlobalManager.h"
#import "Toast+UIView.h"

@implementation GrowNewCell
{
    UIImageView *_coverImg;
    UILabel *_titleLab,*_nameLab,*_numLab,*_totalLab,*_tipLabel;
    TermGrowList *_termList;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //back
        _backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, self.contentView.bounds.size.height)];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [_backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        _backView.layer.cornerRadius = 2;
        _backView.layer.masksToBounds = YES;
        [self.contentView addSubview:_backView];
        
        //img
        _coverImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 65, 85)];
        [_coverImg setContentMode:UIViewContentModeScaleAspectFill];
        _coverImg.clipsToBounds = YES;
        [_coverImg setBackgroundColor:BACKGROUND_COLOR];
        [_backView addSubview:_coverImg];
        
        _makeBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_makeBut setFrame:CGRectMake(_coverImg.frameRight - 30, _coverImg.frameBottom - 17, 30, 17)];
        [_makeBut setBackgroundColor:[UIColor clearColor]];
        [_makeBut setBackgroundImage:CREATE_IMG(@"growMake") forState:UIControlStateNormal];
        [_makeBut setTitle:@"制作" forState:UIControlStateNormal];
        [_makeBut addTarget:self action:@selector(startMake:) forControlEvents:UIControlEventTouchUpInside];
        [_makeBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_makeBut setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_makeBut.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [_backView addSubview:_makeBut];
        
        //title
        CGFloat wei = _backView.frameWidth - _coverImg.frameRight - 30;
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(_coverImg.frameRight + 15, _coverImg.frameY, wei, 18)];
        [_titleLab setFont:[UIFont systemFontOfSize:14]];
        [_titleLab setTextColor:[UIColor blackColor]];
        [_backView addSubview:_titleLab];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_titleLab.frameX, (_coverImg.frameHeight - 20 - _titleLab.frameHeight - 2 - 32) / 2 + _titleLab.frameBottom, wei, 16)];
        [_nameLab setTextColor:[UIColor darkGrayColor]];
        [_nameLab setFont:[UIFont systemFontOfSize:12]];
        [_backView addSubview:_nameLab];
        
        _totalLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.frameX, _nameLab.frameBottom + 2, 90, _nameLab.frameHeight)];
        [_totalLab setTextColor:_nameLab.textColor];
        [_totalLab setFont:_nameLab.font];
        [_backView addSubview:_totalLab];
        //number
        _numLab = [[UILabel alloc] initWithFrame:CGRectMake(_totalLab.frameRight, _nameLab.frameBottom + 2, wei - 75, _nameLab.frameHeight)];
        [_numLab setTextColor:_nameLab.textColor];
        [_numLab setFont:_nameLab.font];
        [_backView addSubview:_numLab];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, -2, 10, 10)];
        [_tipLabel setBackgroundColor:CreateColor(236, 184, 7)];
        [_tipLabel setTextColor:[UIColor whiteColor]];
        [_tipLabel setFont:[UIFont boldSystemFontOfSize:8]];
        [_tipLabel setText:@"!"];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [_tipLabel.layer setMasksToBounds:YES];
        [_tipLabel.layer setCornerRadius:5];
        [_tipLabel.layer setBorderWidth:1];
        [_tipLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
        //buttons
        
        
        CGFloat butWei = 60,butHei = 20;
        NSArray *array = @[@"growSet",@"growOpen",@"growPrint"];
        for (NSInteger i = 0; i < array.count; i++) {
            CGFloat xOri = _totalLab.frameX + i * (butWei + 10);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(xOri, _coverImg.frameBottom - 20, butWei, butHei)];
            [button setImage:CREATE_IMG(array[i]) forState:UIControlStateNormal];
            [button setTag:i + 1];
            [button addTarget:self action:@selector(beginMake:) forControlEvents:UIControlEventTouchUpInside];
            [_backView addSubview:button];
            if (i == 2) {
                [button addSubview:_tipLabel];
            }else {
                UIImageView *_img = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 12, 12)];
                [_img setTag:10 + i];
                [_img setImage:CREATE_IMG((i == 0) ? @"printing" : @"icon_grow_kf")];
                [button addSubview:_img];
            }
        }
    }
    return self;
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)startMake:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(startToMake:)]) {
        [_delegate startToMake:self];
    }
}

- (void)beginMake:(id)sender
{
    NSInteger index = [sender tag] - 1;
    if (_termList.tpl_edit_flag.integerValue == 0) {
        if (index == 1) {
            if ([QQApiInterface isQQInstalled]){
                QQApiWPAObject *wpaObj = [QQApiWPAObject objectWithUin:[DJTGlobalManager shareInstance].qqInfo];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                [self handleSendResult:sent];
            }
            else {
                [self.window makeToast:@"您还没有安装QQ哦" duration:1.0 position:@"center"];
            }
            return;
        }else if (index == 0) {
            return;
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(selectNewCell:At:)]) {
        [_delegate selectNewCell:self At:index];
    }
}

- (void)resetDataSource:(TermGrowList *)termGrow
{
    _termList = termGrow;
    if ([termGrow.tpl_count integerValue] % 2 == 0 && [termGrow.tpl_count integerValue] >= 20 && [termGrow.tpl_count integerValue] <= 30) {
        [_totalLab setTextColor:_nameLab.textColor];
        [_tipLabel setHidden:YES];
    }else {
        if (termGrow.print_flag.integerValue == 0) {
            [_totalLab setTextColor:_nameLab.textColor];
        }else {
            [_totalLab setTextColor:[UIColor redColor]];
        }
        [_tipLabel setHidden:NO];
    }
    
    NSString *url = termGrow.cover_url;
    if (![url hasPrefix:@"http"]) {
        url = [G_IMAGE_ADDRESS stringByAppendingString:url ?: @""];
    }
    [_coverImg setImageWithURL:[NSURL URLWithString:url]];

    [_titleLab setText:termGrow.term_name];
    [_nameLab setText:[NSString stringWithFormat:@"模板名称:%@",termGrow.templist_name]];
    [_totalLab setText:[NSString stringWithFormat:@"模板页数:%@页",termGrow.tpl_count.stringValue]];
    [_numLab setText:[NSString stringWithFormat:@"完成数/学生数:%@/%@",termGrow.finish_count.stringValue,termGrow.total_count.stringValue]];
    
    if (termGrow.tpl_edit_flag.integerValue == 0) {
        for (int i = 0; i < 3; i++) {
            UIButton *view = [_backView viewWithTag:i + 1];
            if (i != 2) {
                [view setBackgroundColor:(i == 0) ? CreateColor(81, 171, 223) : CreateColor(229, 145, 1)];
                [view setTitle:(i == 0) ? @"     收货中" : @"    联系客服" forState:UIControlStateNormal];
                [view.layer setMasksToBounds:YES];
                [view.layer setCornerRadius:2];
                [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [view.titleLabel setFont:[UIFont systemFontOfSize:9.5]];
                [view setImage:nil forState:UIControlStateNormal];
                
                UIImageView *img = (UIImageView *)[view viewWithTag:10 + i];
                img.hidden = NO;
            }
            else {
                [view setHidden:(termGrow.print_flag.integerValue == 0)];
            }
        }
    }else {
        
        NSArray *array = @[@"growSet",@"growOpen",@"growPrint"];
        for (int i = 0; i < 3; i++) {
            UIButton *view = [_backView viewWithTag:i + 1];
            if (i == 2) {
                [view setHidden:(termGrow.print_flag.integerValue == 0)];
            }else {
                UIImageView *img = (UIImageView *)[view viewWithTag:10 + i];
                img.hidden = YES;
                [view setImage:CREATE_IMG(array[i]) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [_backView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_backView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_backView setBackgroundColor:CreateColor(226, 226, 231)];
    }
    else{
        [_backView setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
