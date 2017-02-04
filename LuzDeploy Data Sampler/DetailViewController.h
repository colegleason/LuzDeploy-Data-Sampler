//
//  DetailViewController.h
//  LuzDeploy Data Sampler
//
//  Created by Cole Gleason on 2/4/17.
//  Copyright © 2017 Cole Gleason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

