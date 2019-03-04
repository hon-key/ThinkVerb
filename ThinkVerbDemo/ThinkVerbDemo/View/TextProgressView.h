//
//  GithubTextProgressView.h
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/3/4.
//  Copyright © 2019 CAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextProgressLayer : CALayer
@property (nonatomic,assign) CGFloat progress;

@end


@interface TextProgressView : UIView
@property (nonatomic,strong) UILabel *label;
@end
