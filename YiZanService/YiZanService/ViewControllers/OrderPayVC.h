//
//  OrderPayVC.h
//  YiZanService
//
//  Created by ljg on 15-3-26.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface OrderPayVC : BaseVC
@property (nonatomic,strong)SOrder *order;
@property (nonatomic,assign)int comfrom;


@property (nonatomic,strong)SGoods *goods;
@property (nonatomic,strong)SAddress *address;
@property (nonatomic,strong)SStaff* sstafff;
@end
