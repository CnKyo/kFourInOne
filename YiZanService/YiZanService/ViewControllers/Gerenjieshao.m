//
//  Gerenjieshao.m
//  YiZanService
//
//  Created by 密码为空！ on 15/5/25.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "Gerenjieshao.h"

@implementation Gerenjieshao

+ (Gerenjieshao *)shareView{
    
    Gerenjieshao *view = [[[NSBundle mainBundle]loadNibNamed:@"GerenjieshaoView" owner:self options:nil]objectAtIndex:0];
    
    view.CamraImg1.layer.masksToBounds = YES;
    view.CamraImg1.layer.cornerRadius = 3;
    view.CamraImg1.canClick = YES;
    view.CamraImg1.tag = 1;
    
    
    view.CamraImg2.layer.masksToBounds = YES;
    view.CamraImg2.layer.cornerRadius = 3;
    view.CamraImg2.canClick = YES;
    view.CamraImg1.tag = 2;


    view.CamraImg3.layer.masksToBounds = YES;
    view.CamraImg3.layer.cornerRadius = 3;
    view.CamraImg3.canClick = YES;
    view.CamraImg1.tag = 3;


    view.CamraImg4.layer.masksToBounds = YES;
    view.CamraImg4.layer.cornerRadius = 3;
    view.CamraImg4.canClick = YES;
    view.CamraImg1.tag = 4;

    
    
    return view;

}

@end
