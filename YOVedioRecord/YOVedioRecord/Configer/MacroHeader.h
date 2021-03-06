//
//  MacroHeader.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/15.
//  Copyright © 2019 hello. All rights reserved.
//

#ifndef MacroHeader_h
#define MacroHeader_h

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ColorWithFloat(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

// 获得十六进制颜色
#define XTColorWithFloat(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]


#endif /* MacroHeader_h */
