//
//  SRLicenseTableViewCell.h
//  Screen Ruler
//
//  Created by IEMacBook01 on 16/10/16.
//  Copyright © 2016 InfoEnum Software Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRLicenseTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonLink;
@property (strong, nonatomic) IBOutlet UILabel *labelLicenseType;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;

@end
