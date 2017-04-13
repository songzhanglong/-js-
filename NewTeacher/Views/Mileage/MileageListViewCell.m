//
//  MileageListViewCell.m
//  NewTeacher
//
//  Created by szl on 15/12/3.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageListViewCell.h"
#import "MileageModel.h"
#import "UIImage+Caption.h"
#import "NSString+Common.h"
#import "DataBaseOperation.h"
#import "DJTGlobalManager.h"

@implementation MileageListViewCell
{
    UIView *_leftView,*_rightView;
    UILabel *_nameLab;
    UIImageView *_trangleImg;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        CGFloat wei = (winSize.width - 30) / 3;
        
        //left
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, wei, self.contentView.frameHeight)];
        [_leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_leftView];
        
        _topLeft = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 2, 14)];
        [self.contentView addSubview:_topLeft];
        
        _fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 5, 50, 14)];
        [_fromLabel setFont:[UIFont systemFontOfSize:12]];
        [_fromLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_fromLabel];
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn = editBtn;
        [editBtn setFrame:CGRectMake(_leftView.frameRight - 5 - 20, 5, 20, 20)];
        [editBtn setBackgroundColor:[UIColor clearColor]];
        [editBtn setImage:CREATE_IMG(@"mileageEdit") forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editThemeName:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
        
        //name
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(15, self.contentView.frameHeight - 20, _leftView.frameWidth - 10, 18)];
        [_nameLab setFont:[UIFont systemFontOfSize:14]];
        [_nameLab setBackgroundColor:[UIColor clearColor]];
        [_nameLab setTextColor:[UIColor whiteColor]];
        [_nameLab setNumberOfLines:2];
        [self.contentView addSubview:_nameLab];
        
        //trangle
        _trangleImg = [[UIImageView alloc] initWithFrame:CGRectMake(_leftView.frameRight, 0, 4, 7.5)];
        [_trangleImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_trangleImg];
        
        //right
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(_leftView.frameRight + 10, 0, wei * 2, self.contentView.frameHeight)];
        [_rightView setBackgroundColor:[UIColor whiteColor]];
        [_rightView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:_rightView];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:_rightView.bounds];
        [lineImgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        lineImgView.image = CREATE_IMG(@"mileage_lne");
        [_rightView addSubview:lineImgView];
        
        //images
        NSArray *tips1 = @[@"暂无里程内容",@"您可以添加照片、小视频，记录宝贝成长每一步"];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size1 = [NSString calculeteSizeBy:tips1[1] Font:font MaxWei:_rightView.frameWidth - 20];
        for (int i = 0; i < 2; i++) {
            UIImageView *tmpImg = [[UIImageView alloc] initWithFrame:CGRectMake(_rightView.frameX + wei * i, 0, wei, self.contentView.frameHeight)];
            [tmpImg setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [tmpImg setTag:i + 1];
            [tmpImg setUserInteractionEnabled:YES];
            [tmpImg setContentMode:UIViewContentModeScaleAspectFill];
            [tmpImg setClipsToBounds:YES];
            [tmpImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)]];
            [tmpImg setBackgroundColor:BACKGROUND_COLOR];
            [self.contentView addSubview:tmpImg];
            
            //video
            UIImageView *video = [[UIImageView alloc] initWithFrame:CGRectMake((wei - 30) / 2, (wei - 30) / 2, 30, 30)];
            [video setImage:CREATE_IMG(@"mileageVideo")];
            [video setTag:10];
            [tmpImg addSubview:video];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, (70 - 16 - size1.height) / 2 + 16 * i, size1.width, (i == 0) ? 16 : size1.height)];
            [label1 setTextColor:[UIColor darkGrayColor]];
            [label1 setFont:font];
            [label1 setTextAlignment:1];
            [label1 setNumberOfLines:0];
            [label1 setText:tips1[i]];
            [_rightView addSubview:label1];
        }
        
        _tipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_rightView.frameX + 5, self.contentView.frameHeight - 45, 180, 53)];
        [_tipImgView setImage:CREATE_IMG(@"mileageTip")];
        [_tipImgView setTag:101];
        [_tipImgView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.contentView addSubview:_tipImgView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 170, 30)];
        [tipLabel setFont:font];
        [tipLabel setBackgroundColor:[UIColor clearColor]];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [tipLabel setTextColor:[UIColor whiteColor]];
        [tipLabel setText:@"学生有更新哦！去看看！"];
        [_tipImgView addSubview:tipLabel];
    }
    
    return self;
}

- (void)touchImageView:(UITapGestureRecognizer *)tap{
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectMileageImage:At:)]) {
        NSInteger index = [[tap view] tag] - 1;
        [_delegate selectMileageImage:self At:index];
    }
        
}

- (void)editThemeName:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(beginEditMileageName:)]) {
        [_delegate beginEditMileageName:self];
    }
}

- (void)resetDataSource:(id)object
{
    MileageModel *mileage = (MileageModel *)object;
    NSInteger type = mileage.mileage_type.integerValue; //1（我的）  2（教师） 3（推荐）
    //_editBtn.hidden = (type != 2);
    BOOL isMe = (type == 1),isTeacher = (type == 2);
    UIColor *topColor = isMe ? CreateColor(33, 131, 131) : (isTeacher ? CreateColor(23, 72, 142) : CreateColor(91, 147, 45));
    [_topLeft setBackgroundColor:topColor];
    [_fromLabel setTextColor:topColor];
    NSString *from = isMe ? @"我" : (isTeacher ? @"班级" : @"推荐");
    [_fromLabel setText:from];
    
    UIColor *leftColor = isMe ? CreateColor(120, 205, 205) : (isTeacher ? CreateColor(81, 123, 184) : CreateColor(139, 203, 87));
    [_leftView setBackgroundColor:leftColor];
    
    NSInteger photoCount = [mileage.photo count];
    [_rightView setHidden:(photoCount > 0)];
    
    NSString *imgName = isMe ? @"mileageTrangleMe" : (isTeacher ? @"mileageTrangleTea" : @"mileageTrangleRec");
    [_trangleImg setImage:CREATE_IMG(imgName)];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    CGFloat wei = (winSize.width - 30) / 3;
    CGFloat hei = (photoCount > 0) ? wei : 70;
    [_trangleImg setFrameY:(hei - _trangleImg.frameHeight) / 2];
    [_nameLab setText:mileage.name];
    [_nameLab setFrame:CGRectMake(_nameLab.frameX, hei - 5 - mileage.nameHei, _nameLab.frameWidth, mileage.nameHei)];
    
    NSInteger stuPhotoCount = 0;
    for (int i = 0; i < 2; i++) {
        UIImageView *tmpImg = (UIImageView *)[self.contentView viewWithTag:i + 1];
        if (i < photoCount) {
            [tmpImg setHidden:NO];
            UIImageView *video = (UIImageView *)[tmpImg viewWithTag:10];
            
            MileagePhotoItem *item = mileage.photo[i];
            if (![item.is_teacher isEqualToString:@"1"]) {
                stuPhotoCount += 1;
            }
            NSString *str = item.thumb ?: item.path;
            
            if (![str hasPrefix:@"http"]) {
                str = [[G_IMAGE_ADDRESS stringByAppendingString:str ?: @""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            if (item.type.integerValue != 0){
                video.hidden = NO;
                BOOL mp4 = [[[[str lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"mp4"];
                if (mp4) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:str] atTime:1];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tmpImg setImage:image];
                        });
                    });
                }
                else
                {
                    [tmpImg setImageWithURL:[NSURL URLWithString:str]];
                }
            }
            else
            {
                video.hidden = YES;
                [tmpImg setImageWithURL:[NSURL URLWithString:str]];
            }
        }
        else{
            [tmpImg setHidden:YES];
        }
    }
    
    if (_tipImgView) {
        NSMutableArray *mileageList = [DJTGlobalManager shareInstance].mileageList;
        NSDictionary *curDic = nil;
        for (id subDic in mileageList) {
            if ([subDic[@"albumid"] isEqualToString:mileage.album_id]) {
                curDic = subDic;
                break;
                //@"id":mId,@"userid":userid ?: @"",@"albumid":albumId ?: @"",@"photoids":photoIds ?: @""
            }
        }
        DataBaseOperation *dataBase = [DataBaseOperation shareInstance];
        if (stuPhotoCount == 0) {
            _tipImgView.hidden = YES;
            [mileageList removeObject:curDic];
            if (curDic) {
                [dataBase deleteMileageBy:curDic[@"albumid"]];
            }
        }
        else{
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (MileagePhotoItem *item in mileage.photo) {
                [tmpArr addObject:item.batch_id];
            }
            NSString *photoIds = [tmpArr componentsJoinedByString:@"|"];
            if (curDic && [curDic[@"photoids"] isEqualToString:photoIds]) {
                _tipImgView.hidden = YES;
            }
            else{
                _tipImgView.hidden = NO;
            }
        }
    }
}

@end
