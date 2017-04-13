//
//  MileageStudentViewController.m
//  NewTeacher
//
//  Created by szl on 15/12/8.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "MileageStudentViewController.h"
#import "NSString+Common.h"
#import "MileageStudentModel.h"
#import "Toast+UIView.h"
#import "StudentMileageViewController.h"
#import "MileagePhotoViewController.h"
#import "BabyMileageViewController.h"

@interface MileageStudentViewController ()

@end

@implementation MileageStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *backColor = CreateColor(231, 231, 231);
    self.view.backgroundColor = backColor;
    
    self.useNewInterface = YES;
    
    DJTGlobalManager *manager = [DJTGlobalManager shareInstance];
    NSMutableDictionary *param = [manager requestinitParamsWith:@"getStudentMileagePhoto"];
    
    NSString *text = [NSString hmacSha1:SERCET_KEY dic:param];
    [param setObject:text forKey:@"signature"];
    [self createTableViewAndRequestAction:@"photo" Param:param Header:YES Foot:NO];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self beginRefresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ((BabyMileageViewController *)self.parentViewController).titleLable.text = @"班级里程";
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [_tableView setTableFooterView:[[UIView alloc] init]];
    }
    else{
        CGSize winSize = [UIScreen mainScreen].bounds.size;
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 100)];
        [footView setBackgroundColor:_tableView.backgroundColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, footView.frameBottom- 18, winSize.width - 80, 18)];
        [label setTextAlignment:1];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:CreateColor(84, 128, 215)];
        [label setText:@"你还没有学生哦!"];
        [footView addSubview:label];
        [_tableView setTableFooterView:footView];
    }
}

#pragma mark - 数据请求完毕
- (void)requestFinish:(BOOL)success Data:(id)result
{
    [super requestFinish:success Data:result];
    
    if (success) {
        id ret_data = [result valueForKey:@"ret_data"];
        if (!ret_data || [ret_data isKindOfClass:[NSNull class]]) {
            NSLog(@"数据错误");
        }
        
        NSMutableArray *array = [MileageStudentModel arrayOfModelsFromDictionaries:ret_data];
        self.dataSource = array;
        
        [_tableView reloadData];
        
    }
    else{
        NSString *ret_msg = [result valueForKey:@"ret_msg"];
        ret_msg = ret_msg ?: REQUEST_FAILE_TIP;
        [self.view makeToast:ret_msg duration:1.0 position:@"center"];
    }
    [self createTableFooterView];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sutdentCell = @"studentCellId";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:sutdentCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sutdentCell];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 7.5, 45, 45)];
        [imageView setTag:1];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 22.5;
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frameRight + imageView.frameX, imageView.frameY, 60, 17)];
        [nameLab setTextColor:[UIColor blackColor]];
        [nameLab setFont:[UIFont systemFontOfSize:14]];
        [nameLab setBackgroundColor:[UIColor whiteColor]];
        [nameLab setTag:2];
        [nameLab setHighlightedTextColor:[UIColor whiteColor]];
        [cell.contentView addSubview:nameLab];
        
        UILabel *sexLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.frameRight + 5, nameLab.frameY + 2, 200, 15)];
        [sexLab setTextColor:[UIColor lightGrayColor]];
        [sexLab setFont:[UIFont systemFontOfSize:12]];
        [sexLab setBackgroundColor:[UIColor whiteColor]];
        [sexLab setTag:3];
        [sexLab setHighlightedTextColor:[UIColor whiteColor]];
        [cell.contentView addSubview:sexLab];
        
        UILabel *picLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.frameX, nameLab.frameBottom, 200, 15)];
        [picLab setTextColor:[UIColor lightGrayColor]];
        [picLab setFont:[UIFont systemFontOfSize:12]];
        [picLab setBackgroundColor:[UIColor whiteColor]];
        [picLab setTag:4];
        [picLab setHighlightedTextColor:[UIColor whiteColor]];
        [cell.contentView addSubview:picLab];
        
        UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(picLab.frameX, picLab.frameBottom, picLab.frameWidth, 13)];
        [timeLab setTextColor:[UIColor lightGrayColor]];
        [timeLab setFont:[UIFont systemFontOfSize:10]];
        [timeLab setBackgroundColor:[UIColor whiteColor]];
        [timeLab setTag:5];
        [timeLab setHighlightedTextColor:[UIColor whiteColor]];
        [cell.contentView addSubview:timeLab];
    }
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *sexLab = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *picLab = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *timeLab = (UILabel *)[cell.contentView viewWithTag:5];
    MileageStudentModel *item = self.dataSource[indexPath.row];
    NSString *face = item.face_school;
    if (![face hasPrefix:@"http"]) {
        face = [G_IMAGE_ADDRESS stringByAppendingString:face ?: @""];
    }
    [imageView setImageWithURL:[NSURL URLWithString:face] placeholderImage:CREATE_IMG(@"s21@2x")];
    
    [nameLab setText:item.real_name];
    [nameLab sizeToFit];
    [sexLab setFrameX:nameLab.frameRight + 5];
    NSDate *dateBir = [NSString convertStringToDate:item.birthday];
    NSString *birthday = [NSString stringByDate:@"yyyy年MM月dd日" Date:dateBir];
    [sexLab setText:[NSString stringWithFormat:@"%@ %@",item.sex ?: @"",birthday ?: @""]];
    [picLab setText:[NSString stringWithFormat:@"宝宝里程  照片%@ / 视频%@",item.photo_num.stringValue,item.mp4_num.stringValue]];
    if ([item.create_time length] > 0) {
        NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:item.create_time.doubleValue];
        [timeLab setText:[NSString stringWithFormat:@"%@开启宝宝里程",[NSString stringByDate:@"yyyy年MM月dd日" Date:updateDate]]];
    }
    else{
        [timeLab setText:@""];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MileageStudentModel *model = self.dataSource[indexPath.row];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    StudentMileageViewController *student = [[StudentMileageViewController alloc] init];
    student.view.frame = CGRectMake(0, 155, winSize.width, winSize.height - 155 - 64);
    MileagePhotoViewController *mileage = [[MileagePhotoViewController alloc] init];
    mileage.disanableDelete = YES;
    mileage.view.frame = student.view.frame;
    
    BabyMileageViewController *baby = [[BabyMileageViewController alloc] initWithControls:@[student,mileage] Titles:@[@"里程",@"相册"] Frame:CGRectMake(0, 120, winSize.width, 35)];
    baby.mileageStu = model;
    [self.parentViewController.navigationController pushViewController:baby animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

@end
