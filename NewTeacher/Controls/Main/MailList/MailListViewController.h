//
//  MailListViewController.h
//  NewTeacher
//
//  Created by mac on 15/7/28.
//  Copyright (c) 2015年 songzhanglong. All rights reserved.
//

#import "DJTTableViewController.h"

@interface MailListViewController : DJTTableViewController<UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    int lastIndexTag;
    UISearchDisplayController *searchDisplayController;
    
    UISearchBar *_searchBar;
    
    NSMutableArray *_dataArray;
    NSMutableArray *_resultsData;
    int indexBootm;
}
@end
