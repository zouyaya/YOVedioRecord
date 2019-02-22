//
//  YOHomeTableViewCell.h
//  YOVedioRecord
//
//  Created by yangou on 2019/2/15.
//  Copyright © 2019 hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YOHomeTableViewCell : UITableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView;

-(void)initCellDataAccordingToTHeIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
