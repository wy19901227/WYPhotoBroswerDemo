# WYPhotoBroswerDemo
演示项目介绍
==============
查看并运行 `WYPhotoBroswerDemo/WYPhotoBroswer.xcodeproj`
基于我偶像YYkit(https://github.com/ibireme/YYKit) - 的图片浏览器（效果和facebook的一样）
![image](https://github.com/wy19901227/WYPhotoBroswerDemo/raw/master/snapshort/a.gif)

实例用法
============
        
        WYPhotoItem* item=[WYPhotoItem new];
        item.thumbView=imgView;
        item.orignalImageUrl=meta.url;
        [items addObject:item];
        
    
    WYPhotoBrowser* browser=[[WYPhotoBrowser alloc]initWithPhotos:items animatedFromView:fromView];
    browser.animator.behindViewScale=1;
    browser.animator.transitionDuration=.28;
    [self presentViewController:browser animated:YES completion:nil];
