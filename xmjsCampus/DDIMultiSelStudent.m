//
//  DDIMultiSelLinkMan.m
//  掌上校园
//
//  Created by yons on 14-2-19.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIMultiSelStudent.h"
extern Boolean kIOS7;
extern int kSchoolId;
@interface DDIMultiSelStudent ()

@end

@implementation DDIMultiSelStudent


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectImage=[UIImage imageNamed:@"Selected"];
    unselectImage=[UIImage imageNamed:@"Unselected"];
    float height=self.view.bounds.size.height-40;
    if([UIApplication sharedApplication].statusBarFrame.size.height==44)
        height=height-88-20;
    else
        height=height-64;
    [self.mTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.mTableView.bounds.size.height, self.view.bounds.size.width, 40)];
    sv  =[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width-80,40)];
    
    sv.backgroundColor =[UIColor clearColor];
    sv.pagingEnabled = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = YES;
    sv.delegate = Nil;
    [bottomView addSubview:sv];
    finishBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-75,4,70,32)];
    finishBtn.backgroundColor=[[UIColor alloc]initWithRed:24/255.0 green:156/255.0 blue:208/255.0 alpha:1];
    [finishBtn.layer setMasksToBounds:YES];
    [finishBtn.layer setCornerRadius:5.0];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(submitSelected) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:finishBtn];
    [self.view addSubview:bottomView];
    if(selectedArray==nil)
        selectedArray=[[NSMutableArray alloc]init];
    else
    {
        NSMutableArray *needupdategroup=[NSMutableArray array];
        for(NSString *userid in selectedArray)
        {
            NSDictionary *linkman=[duizhaoDic objectForKey:userid];
            NSString *group=[linkman objectForKey:@"group"];
            if(![needupdategroup containsObject:group])
                [needupdategroup addObject:group];
        }
        for(NSString *group in needupdategroup)
        {
            NSInteger section=[groupArray indexOfObject:group];
            [self updateHeadSelImage:section];
        }
    }
    
}
- (void)setAllStudentArray:(NSDictionary *)allStudent
{
    friendDic=[[NSMutableDictionary alloc] initWithDictionary:allStudent];
}
- (void)setGroupArray:(NSArray *)grouparray
{
    NSMutableArray *temparray=[NSMutableArray array];
    for(NSString *item in grouparray)
    {
        if([item isEqualToString:@"请选择"])
            continue;
        [temparray addObject:item];
    }
    groupArray=temparray;
}
- (void)setSelectedArray:(NSArray *)selectedarray
{
    selectedArray=[NSMutableArray array];
    for(NSDictionary *item in selectedarray)
    {
        if([item objectForKey:@"id"]!=nil)
            [selectedArray addObject:[item objectForKey:@"id"]];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=@"请选择";
    [super viewWillAppear:animated];
    
}
-(void)loadLinkMansFromDic
{
    @try
    {
        if(duizhaoDic==nil)
            duizhaoDic=[NSMutableDictionary dictionary];
        //NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"拼音" ascending:YES]];
        for(int i=0;i<groupArray.count;i++)
        {
            NSString *groupName=[groupArray objectAtIndex:i];
            NSMutableArray *studentArray=[[NSMutableArray alloc] initWithArray:[friendDic objectForKey:groupName]];
            for(int j=0;j<studentArray.count;j++)
            {
                NSMutableDictionary *student=[[NSMutableDictionary alloc] initWithDictionary:[studentArray objectAtIndex:j]];
                if([student objectForKey:@"id"]==nil)
                    continue;
                NSString *userName=[student objectForKey:@"name"];
                NSString *Pinyin=@"";
                for(int m=0;m<userName.length;m++)
                {
                    NSString *letter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([userName characterAtIndex:m])]uppercaseString];
                    Pinyin=[Pinyin stringByAppendingString:letter];
                }
                Pinyin=[Pinyin stringByAppendingString:userName];
                [student setObject:Pinyin forKey:@"XingMing"];
                [student setObject:groupName forKey:@"group"];
                [duizhaoDic setObject:student forKey:[student objectForKey:@"id"]];
                [studentArray replaceObjectAtIndex:j withObject:student];
            }
            [friendDic setObject:studentArray forKey:groupName];
        }
    }
    @catch(NSException * e)
    {
        NSLog(@"Exception: %@", e);
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TQMultistageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        if(kIOS7)
            cell.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
        
        UIButton *action = [[UIButton alloc] initWithFrame:CGRectMake(320, 0, 60, 44)];
        
        [action addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView=action;
        
        [cell.imageView.layer setMasksToBounds:YES];
        [cell.imageView.layer setCornerRadius:5.0];
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPic:)];
        UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
        [cell.imageView addGestureRecognizer:gesture1];
        [cell.imageView addGestureRecognizer:gesture2];
        [cell.imageView setUserInteractionEnabled:true];
        
    }
    NSDictionary *linkman=nil;
    if(tableView==self.mTableView.tableView)
    {
        NSArray *linkManOfGroup=[self->friendDic objectForKey:self->groupArray[indexPath.section]];
        linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    }
    else
        linkman=[self->filteredMessages objectAtIndex:indexPath.row];
    
    
    NSString *userid=[linkman objectForKey:@"id"];
    NSString *userName=[linkman objectForKey:@"name"];
    NSString *sex=[linkman objectForKey:@"sex"];
    NSString *picUrl=[linkman objectForKey:@"icon"];
    NSString *usertype=[linkman objectForKey:@"usertype"];
    if(usertype==nil || usertype.length==0)
        usertype=@"学生";
    NSString *group =[linkman objectForKey:@"group"];
    NSString *weiyima=[NSString stringWithFormat:@"用户_%@_%@____%d",usertype,userid,kSchoolId];
    if(tableView==self.mTableView.tableView)
        cell.textLabel.text=userName;
    else
        cell.textLabel.text=[NSString stringWithFormat:@"%@[%@]", userName,group];
    
    UIImage *img;
    if (img==Nil)
    {
        NSString *userPic=[CommonFunc getImageSavePath:weiyima ifexist:YES];
        
        if(userPic)
        {
            UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
            CGSize newSize=CGSizeMake(40, 40);
            headImage=[headImage scaleToSize1:newSize];
            headImage=[headImage cutFromImage:CGRectMake(0, 0, 40, 40)];
            cell.imageView.image=headImage;
        }
        else
        {
            if(picUrl && picUrl.length>0)
            {
                NSURL *url = [NSURL URLWithString:picUrl];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=weiyima;
                NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
                [indexDic setObject:indexPath forKey:@"indexPath"];
                request.userInfo=indexDic;
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
            }
            if([sex isEqualToString:@"女"])
                cell.imageView.image=imageWoman;
            else
                cell.imageView.image=imageMan;
        }
        
    }
    else
    {
        cell.imageView.image=img;
        
    }
    
    UIButton *btn=(UIButton *)cell.accessoryView;
    btn.titleLabel.text=userid;
    btn.titleLabel.tag=indexPath.section;
    
    if([selectedArray containsObject:userid])
        [btn setImage:selectImage forState:UIControlStateNormal];
    else
        [btn setImage:unselectImage forState:UIControlStateNormal];
    
    return cell;
    
}
-(void)detailButtonClicked:(UIButton *)sender
{
    
    NSString *userid=sender.titleLabel.text;
    if([selectedArray containsObject:userid])
    {
        [selectedArray removeObject:userid];
        [sender setImage:unselectImage forState:UIControlStateNormal];
    }
    else
    {
        [selectedArray addObject:userid];
        [sender setImage:selectImage forState:UIControlStateNormal];
    }
    [self updateHeadSelImage:sender.titleLabel.tag];
    
}
- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[super mTableView:tableView viewForHeaderInSection:section];
    UIButton *selBtn=(UIButton *)[headView viewWithTag:1003];
    if(!selBtn)
    {
        selBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 0, 44, 44)];
        selBtn.tag=1003;
        selBtn.titleLabel.tag=section;
        [selBtn setImage:unselectImage forState:UIControlStateNormal];
        [selBtn addTarget:self action:@selector(headSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:selBtn];
        UILabel *lblCount=(UILabel *)[headView viewWithTag:1002];
        NSString *lblText=lblCount.text;
        lblText=[lblText stringByReplacingOccurrencesOfString:@"人" withString:@""];
        lblCount.text=[NSString stringWithFormat:@"%d/%@",0,lblText];
    }
    return headView;
}
-(void)updateHeadSelImage:(NSInteger)section
{
    BOOL flag=true;
    NSArray *linkManOfGroup=[self->friendDic objectForKey:[self->groupArray objectAtIndex:section]];
    int hasSelNum=0;
    for(int i=0;i<linkManOfGroup.count;i++)
    {
        NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
        NSString *userid=[linkman objectForKey:@"id"];
        if(![selectedArray containsObject:userid])
            flag=false;
        else
            hasSelNum++;
    }
    UIView *headView=[self mTableView:self.mTableView viewForHeaderInSection:section];
    UIButton *selBtn=(UIButton *)[headView viewWithTag:1003];
    if(flag)
        [selBtn setImage:selectImage forState:UIControlStateNormal];
    else
        [selBtn setImage:unselectImage forState:UIControlStateNormal];
    UILabel *lblCount=(UILabel *)[headView viewWithTag:1002];
    lblCount.text=[NSString stringWithFormat:@"%d/%lu",hasSelNum,(unsigned long)linkManOfGroup.count];
    [self reloadScrollViewContent];
}

-(void)headSelectClick:(UIButton *)sender
{
    NSInteger section=sender.titleLabel.tag;
    NSString *groupName=[self->groupArray objectAtIndex:section];
    NSArray *linkManOfGroup=[self->friendDic objectForKey:groupName];
    
    if([sender.imageView.image isEqual:selectImage])
    {
        
        for(int i=0;i<linkManOfGroup.count;i++)
        {
            NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
            NSString *userid=[linkman objectForKey:@"id"];
            if(userid && [selectedArray containsObject:userid])
                [selectedArray removeObject:userid];
        }
        
    }
    else
    {
        
        for(int i=0;i<linkManOfGroup.count;i++)
        {
            NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
            NSString *userid=[linkman objectForKey:@"id"];
            if(userid && ![selectedArray containsObject:userid])
                [selectedArray addObject:userid];
        }
        
    }
    NSLog(@"%@",selectedArray);
    [self updateHeadSelImage:section];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:section];
    [self.mTableView.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}
-(void)reloadScrollViewContent
{
    NSArray *subviews=[sv.subviews copy];
    for(int i=0;i<subviews.count;i++)
    {
        [[subviews objectAtIndex:i] removeFromSuperview];
    }
    for(int i=0;i<selectedArray.count;i++)
    {
        UIButton *imgv=[[UIButton alloc]initWithFrame:CGRectMake(5+i*37, 4, 32, 32)];
        [imgv.layer setMasksToBounds:YES];
        [imgv.layer setCornerRadius:5.0];
        NSString *userid=[selectedArray objectAtIndex:i];
        NSDictionary *linkman=[duizhaoDic objectForKey:userid];
        NSString *usertype=[linkman objectForKey:@"usertype"];
        NSString *weiyima=[NSString stringWithFormat:@"用户_%@_%@____%d",usertype,userid,kSchoolId];
        UIImage *img;
        if(!img)
        {
            NSString *userPic=[CommonFunc getImageSavePath:weiyima ifexist:YES];
            if(userPic)
            {
                UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
                CGSize newSize=CGSizeMake(32, 32);
                headImage=[headImage scaleToSize1:newSize];
                headImage=[headImage cutFromImage:CGRectMake(0, 0, 32, 32)];
                img=headImage;
            }
            else
            {
                if([[linkman objectForKey:@"sex"] isEqualToString:@"女"])
                    img=imageWoman;
                else
                    img=imageMan;
            }
            
        }
        [imgv setImage:img forState:UIControlStateNormal];
        imgv.titleLabel.text=userid;
        [imgv addTarget:self action:@selector(removeFromSelected:) forControlEvents:UIControlEventTouchUpInside];
        [sv addSubview:imgv];
    }
    CGSize newSize = CGSizeMake(selectedArray.count*37+10, sv.frame.size.height);
    [sv setContentSize:newSize];
    [finishBtn setTitle:[NSString stringWithFormat:@"确定(%d)",(int)selectedArray.count] forState:UIControlStateNormal];
    
}
-(void)removeFromSelected:(UIButton *)sender
{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         sender.alpha = 0;
                         [sender setFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y-36, sender.frame.size.width, sender.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         
                         NSString *userid=sender.titleLabel.text;
                         if([self->selectedArray containsObject:userid])
                         {
                             [self->selectedArray removeObject:userid];
                             [self reloadScrollViewContent];
                             [self.mTableView.tableView reloadData];
                             NSDictionary *linkman=[self->duizhaoDic objectForKey:userid];
                             NSString *groupName=[linkman objectForKey:@"group"];
                             int section=(int)[self->groupArray indexOfObject:groupName];
                             if(section>=0)
                                 [self updateHeadSelImage:section];
                         }
                         
                     }];
    
    
}
-(void)submitSelected
{
    NSMutableArray *resultarray=[NSMutableArray array];
    for(NSString *userid in selectedArray)
    {
        if(userid!=nil && userid.length>0)
        {
            NSDictionary *linkman=[duizhaoDic objectForKey:userid];
            [resultarray addObject:linkman];
        }
    }
    [_delegate setListValue:resultarray];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    UIButton *action =(UIButton *)cell.accessoryView;
    [self detailButtonClicked:action];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    filteredMessages=duizhaoDic.allValues;
    
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [super searchDisplayControllerDidEndSearch:controller];
    for(int i=0;i<groupArray.count;i++)
        [self updateHeadSelImage:i];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    filteredMessages=duizhaoDic.allValues;
    filteredMessages = [filteredMessages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.XingMing contains[cd] %@", searchString]];
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showBigPic:(UITapGestureRecognizer *)sender
{
    UIImageView *imageview=(UIImageView *)sender.view;
    UIImage *img=imageview.image;
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    lastPoint=[sender locationInView:self.view];
    imageView.center =lastPoint;
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = img;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    }];
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = self->lastPoint;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

@end
