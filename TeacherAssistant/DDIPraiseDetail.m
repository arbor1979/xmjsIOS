//
//  DDIPraiseDetail.m
//  掌上校园
//
//  Created by Mac on 15/1/25.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIPraiseDetail.h"

@implementation DDIPraiseDetail

-(void)viewDidLoad
{
    requestArray=[NSMutableArray array];
    savepath=[CommonFunc createPath:@"/utils/"];
    [super viewDidLoad];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _praiseList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    
    AlbumMsg *item=[_praiseList objectAtIndex:indexPath.row];
    
    UIButton *headBtn=(UIButton *)[cell viewWithTag:101];
    headBtn.imageView.layer.cornerRadius = headBtn.frame.size.width / 2;
    headBtn.imageView.layer.masksToBounds = YES;
    
    NSString *userid=item.fromId;
    headBtn.titleLabel.text=userid;
    [headBtn addTarget:self action:@selector(openPersonalPage:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lbname=(UILabel *)[cell viewWithTag:102];
    UILabel *lbtime=(UILabel *)[cell viewWithTag:103];
    UIImageView *iv=(UIImageView *)[cell viewWithTag:104];
    DDIGifView *ev=(DDIGifView *)[cell viewWithTag:105];
    UIImageView *rightImage=(UIImageView *)[cell viewWithTag:106];
    rightImage.clipsToBounds=YES;
    if([item.type isEqualToString:@"评论"])
    {
        lbname.text=@"";
        iv.hidden=YES;
        ev.hidden=NO;
        ev.msgContent=[NSString stringWithFormat:@"%@:%@",item.fromName,item.msg];
    }
    else
    {
        lbname.text=[NSString stringWithFormat:@"%@:",item.fromName];
        [lbname sizeToFit];
        iv.hidden=NO;
        ev.hidden=YES;
    }
    UIImage *image;
    if(item.imageDic)
    {
        NSString *iconName=[item.imageDic objectForKey:@"文件名"];
        NSString *filename=[savepath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            image=[UIImage imageWithContentsOfFile:filename];
        }
        else
        {
            NSString *urlStr=[item.imageDic objectForKey:@"文件地址"];
            
            image=[UIImage imageNamed:@"empty_photo"];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"图片下载";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            
            [indexDic setObject:filename forKey:@"filename"];
            [indexDic setObject:rightImage forKey:@"imageview"];
            
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
        [rightImage setImage:image];
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        
    }
    lbtime.text=item.time;
    NSString *picUrl=item.fromHeadUrl;
    [self getImageByUserIdToButton:userid picUrl:picUrl imageview:headBtn];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumMsg *item=[_praiseList objectAtIndex:indexPath.row];
    NSMutableArray *imageArray=[NSMutableArray array];
    if(item.imageDic)
       [imageArray addObject:item.imageDic];
    if(imageArray.count>0)
    {
        DDIAlbumScrollPage *asp=[[DDIAlbumScrollPage alloc]init];
        asp.imageArray=imageArray;
        [self.navigationController pushViewController:asp animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumMsg *item=[_praiseList objectAtIndex:indexPath.row];
    if([item.type isEqualToString:@"评论"])
    {
        if(!tempview)
            tempview=[[DDIGifView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-117, 25)];
        tempview.msgContent=[NSString stringWithFormat:@"%@:%@",item.fromName,item.msg];
        CGFloat height=tempview.frame.size.height;
        height+=15+16;
        if(height<56)
            height=56;
        return height;
        
    }
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
-(void)getImageByUserIdToButton:(NSString *)userid picUrl:(NSString *)picUrl imageview:(UIButton *)headBtn
{
    NSString *userPic=[CommonFunc getImageSavePath:userid ifexist:YES];
    if(userPic)
    {
        UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];

        [headBtn setImage:headImage forState:UIControlStateNormal];
    }
    else
    {
        [headBtn setImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
        if(picUrl && picUrl.length>0)
        {
            NSURL *url = [NSURL URLWithString:picUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=userid;
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:headBtn forKey:@"btn"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
    }
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
-(void)openPersonalPage:(UIButton *)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DDIMyInforView *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"MyInforView"];
    itemController.userWeiYi=sender.titleLabel.text;
    if(sender.imageView.image)
        itemController.headImage=sender.imageView.image;
    [self.navigationController pushViewController:itemController animated:YES];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"图片下载"])
    {
        
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSDictionary *indexDic=request.userInfo;
            
            NSString *filename=[indexDic objectForKey:@"filename"];
            [datas writeToFile:filename atomically:YES];
            
            UIImageView *iv=[indexDic objectForKey:@"imageview"];
            if(iv)
            {
                iv.image=headImage;
            }
           
        }
    }
    else
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            NSDictionary *indexDic=request.userInfo;
            UIButton *btn=[indexDic objectForKey:@"btn"];
            if(btn)
            {
                [btn setImage:headImage forState:UIControlStateNormal];
            }
            
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView showInView:self.view];
}
@end
