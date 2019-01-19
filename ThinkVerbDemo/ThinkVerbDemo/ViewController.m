//
//  ViewController.m
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/1/16.
//  Copyright © 2019 CAI. All rights reserved.
//

#import "ViewController.h"
#import "ThinkVerb.h"

AnimationUnit animationUnits[] = {
    {.key = @"Move", .selector = @"move"},
    {.key = @"Scale", .selector = @"scale"},
    {.key = @"Rotate", .selector = @"rotate"},
    {.key = nil, .selector = nil},
};

@interface ViewController ()
@property (nonatomic,strong) UIView *box;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = self.unit->key;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.box.center = self.view.center;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.box.TVAnimation.clear();
}

- (void)triggerAnimation {
    [self performSelectorOnMainThread:NSSelectorFromString(self.unit->selector) withObject:nil waitUntilDone:nil];
}

- (void)move {
    self.box.TVAnimation.move.offset(50,100,0).activate();
}
- (void)scale {
    self.box.TVAnimation.scale.to(2).activate();
}
- (void)rotate {
    self.box.TVAnimation.rotate.x().with.endAngle(M_PI * 2).repeat(-1).activate();
    self.box.TVAnimation.rotate.y().with.endAngle(M_PI * 2).repeat(-1).activate();
    self.box.TVAnimation.rotate.z().with.endAngle(M_PI * 2).repeat(-1).activate();
}
- (UIView *)box {
    if (!_box) {
        _box = [UIView new];
        _box.frame = CGRectMake(0, 0, 50, 50);
        _box.backgroundColor = [UIColor redColor];
        [_box addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerAnimation)]];
        _box.TVAnimation.appearance.duration(3)
        .timing(TVTiming.extremeEaseOut).keepAliveAtEnd.end();
        [self.view addSubview:_box];
    }
    return _box;
}


@end
