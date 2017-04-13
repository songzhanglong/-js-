//
//  DJBaseColumn.h
//  NewTeacher
//
//  Created by yanghaibo on 15/2/5.
//  Copyright (c) 2015年 yanghaibo. All rights reserved.
//

#ifndef NewTeacher_DJBaseColumn_h
#define NewTeacher_DJBaseColumn_h
typedef enum
{
    kTableClass = 0,     //班级圈
    kTableActivity,       //活动
    kTableGrow,        //成长记录
    kTableNotUpload, //未提交数据上传
    KTableStudent //宝贝相册
}kTableTypeT;

//#define LOGIN_ACCOUNT @"login_account"

#pragma  班级圈
#define CLASS_TABLE @"class_table"

#define ALBUMS_ID  @"albums_id"
#define ALBUM_NAME @"album_name"
#define AUTHOR     @"author"
#define AUTHORID   @"authorid"
#define DATELINE   @"dateline"
#define DIGEST     @"digest"
#define ATTENTION  @"attention"

//#define DIGG_COUNT       @"digg_count"
#define DISPLAYORDER     @"displayorder"
#define FACE     @"face"
#define HAVE_DIGG @"have_digg"
#define IS_TEACHER @"is_teacher"
#define LASTPOST @"lastpost"
#define LASTPOSTER @"lastposter"
#define MESSAGE @"message"
#define NAME @"name"
#define PICTURE @"picture"
#define PICTURE_THUMB @"picture_thumb"
//#define REPLIES @"replies"
#define SUBJECT @"subject"
#define TAG @"tag"
#define TID @"tid"
#define VIEWS @"views"

#pragma  评论
#define REPLY_TABLE @"reply_table"
#define ALBUMS_ID  @"albums_id"
#define FACE @"face"
#define IS_TEACHER @"is_teacher"
#define NAME @"name"
#define REPLAY_MESSAGE @"replay_message"
#define REPLY_ID @"reply_id"
#define REPLY_IS_TEACHER @"reply_is_teacher"
#define REPLY_NAME @"reply_name"
#define SEND_ID @"send_id"
#define SEND_NAME @"send_name"
#define TID @"tid"

#pragma 点赞
#define DIGG_TABLE @"digg_table"
#define ALBUMS_ID  @"albums_id"
#define FACE @"face"
#define IS_TEACHER @"is_teacher"
#define NAME @"name"
#define USERID @"userid"


#pragma 班级活动
#define ACTIVITY_TABLE @"activity_table"
#define ID @"id"
#define ALBUM_ID @"album_id"
//#define ALBUM_NAME @"album_name";
#define PHOTOS_NUM @"photos_num"
#define THUMB @"thumb"
#define PHOTO @"photo"
#define UP_TIME @"up_time"
#define ITEMS @"items"

#pragma 班级活动图片地址
#define ACTIVITY_ITEM_TABLE @"activity_item_table"
#define ACTIVITY_ID @"activity_id"
#define PHOTO_DESC @"photo_desc"
#define PHOTO_ID @"photo_id"
#define PHOTO_PATH @"photo_path"
#define PHOTO_THUMB @"photo_thumb"
#define TYPE @"type"


#pragma 未提交上传数据
#define NOTUPLOAD_TABLE @"notupload_table"
#define IMGS @"imgs"
#define ISVIDEO @"isVideo"
#define UPLOADURL  @"uploadUrl"
#define PARAM @"param"
#define ENDURL @"endUrl"
#define ENDPARAM @"endParam"
#define DATASOURCE @"dataSource"
#define DATETIME @"dateTime"
#define ACCOUNT @"account"
#define MODEL @"model"

#pragma 宝贝相册
#define DJTSTUDENT_TABLE @"DJTStudent_table"
#define ADDRESS @"address"
//#define ALBUM_ID
#define BIRTHDAY @"birthday"
//#define FACE
#define GROW_ID @"grow_id"
#define GROWS_NUM @"grows_num"
#define MOBILE @"mobile"
#define PARENTS_NAME @"parents_name"
//#define PHOTOS_NUM
#define RELATION @"relation"
#define SEX @"sex"
#define STUDENT_ID @"student_id"
#define TEMPLIST_ID @"templist_id"
#define TEMPLIST_NUMS @"templist_nums"
#define TIMESTAMP @"timeStamp"
#define UNAME @"uname"
#endif
