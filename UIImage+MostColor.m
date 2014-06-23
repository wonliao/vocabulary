//
//  UIImage+MostColor.m
//  Modo
//
//  Created by Travis on 13-5-30.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "UIImage+MostColor.h"

@implementation UIImage(MostColor)

-(UIColor*)mostColor{
    
    //第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
    CGSize thumbSize=CGSizeMake(50 , 50);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbSize.width,
                                                 thumbSize.height,
                                                 8,//bits per component
                                                 thumbSize.width*4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
	CGContextDrawImage(context, drawRect, self.CGImage);
	CGColorSpaceRelease(colorSpace);

    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
    
	if (data == NULL) return nil;
    
    int rangeX = thumbSize.width * 0.3; // 捨棄左右邊界
    int rangeY = thumbSize.height * 0.35; // 捨棄上下邊界
    
    int redAvg = 0;
    int greenAvg = 0;
    int blueAvg = 0;
    int alphaAvg = 0;

    for (int x=rangeX; x<thumbSize.width-rangeX; x++) {
        for (int y=rangeY; y<thumbSize.height-rangeY; y++) {
            
            int offset = 4*(x*y);
            
            int red = data[offset];
            int green = data[offset+1];
            int blue = data[offset+2];
            int alpha =  data[offset+3];
            
            redAvg = (int)((redAvg + red) / 2);
            greenAvg = (int)((greenAvg + green) / 2);
            blueAvg = (int)((blueAvg + blue) / 2);
            alphaAvg = (int)((alphaAvg + alpha) / 2);
        }
    }
    CGContextRelease(context);
    
    //NSLog(@"redAvg(%d) greenAvg(%d) blueAvg(%d)", redAvg, greenAvg, blueAvg);
    return [UIColor colorWithRed:(redAvg/255.0f) green:(greenAvg/255.0f) blue:(blueAvg/255.0f) alpha:(alphaAvg/255.0f)];
}


@end
