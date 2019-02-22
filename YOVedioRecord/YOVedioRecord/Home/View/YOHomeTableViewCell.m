//
//  YOHomeTableViewCell.m
//  YOVedioRecord
//
//  Created by yangou on 2019/2/15.
//  Copyright © 2019 hello. All rights reserved.
//

#import "YOHomeTableViewCell.h"

@interface YOHomeTableViewCell ()

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIView *lineView;

@end

@implementation YOHomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identify = @"homeCell";
    YOHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[YOHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return cell;
    
    
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = XTColorWithFloat(0x00cdcd);
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, ScreenWidth -20, 50)];
        _titleLabel.textColor = XTColorWithFloat(0xffffff);
        _titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_titleLabel];
        
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 59, ScreenWidth, 1)];
        _lineView.backgroundColor = XTColorWithFloat(0xf2f2f2);
        [self.contentView addSubview:_lineView];
      
        
    }
    
    return self;

    
}

-(void)initCellDataAccordingToTHeIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            _titleLabel.text = @"UIImagePickerController";
            break;
        case 1:
            _titleLabel.text = @"AVCaptureSession+AVCaptureMovieFileOutput";
            break;
        case 2:
            _titleLabel.text = @"AVCaptureSession+AVAssetWriter";
            break;
            
        default:
            break;
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
