//
//  ViewController.m
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/1/16.
//  Copyright © 2019 CAI. All rights reserved.
//

#import "ViewController.h"
#import "ThinkVerb.h"
#import "TextProgressView.h"

AnimationSection animationSections[] = {
    {.name = @"Base Animations",.unit = baseAnimations},
    {.name = @"Animation sets",.unit = animationSets},
    {.name = nil,.unit = NULL},
};

AnimationUnit baseAnimations[] = {
    {.key = @"Move", .selector = @"move"},
    {.key = @"Scale", .selector = @"scale"},
    {.key = @"Rotate", .selector = @"rotate"},
    {.key = @"Shadow", .selector = @"shadow"},
    {.key = @"Bounds", .selector = @"bounds"},
    {.key = @"Anchor", .selector = @"anchor"},
    {.key = @"Translate", .selector = @"translate"},
    {.key = @"Fade", .selector = @"fade"},
    {.key = @"Contents->draw", .selector = @"drawRange"},
    {.key = @"Contents->scale", .selector = @"contentsScale"},
    {.key = @"Contents->rect", .selector = @"contentsRect"},
    {.key = @"Contents->center", .selector = @"contentsCenter"},
    {.key = @"BackgroundColor", .selector = @"backgroundColor"},
    {.key = @"CornerRadius", .selector = @"cornerRadius"},
    {.key = @"Border", .selector = @"border"},
    {.key = @"Path", .selector = @"path"},
    {.key = nil, .selector = nil},
};
AnimationUnit animationSets[] = {
    {.key = @"Jump and Shake", .selector = @"jumpIcon"},
    {.key = @"Lyrics Animation", .selector = @"lyricsAnimation"},
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
    SEL prepareSEL = NSSelectorFromString([NSString stringWithFormat:@"p_%@",self.unit->selector]);
    if ([self respondsToSelector:prepareSEL]) {
        [self performSelectorOnMainThread:prepareSEL withObject:nil waitUntilDone:nil];
    }
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

#pragma mark - prepare
- (void)p_anchor {
    self.box.frame = CGRectMake(0, 0, 100, 20);
}
- (void)p_contentsScale {
    self.box.backgroundColor = [UIColor whiteColor];
    self.box.layer.contents = (__bridge id)[UIImage imageNamed:@"1"].CGImage;
    self.box.layer.contentsScale = [UIScreen mainScreen].scale;
    self.box.layer.contentsGravity = kCAGravityCenter;
}
- (void)p_contentsRect {
    self.box.backgroundColor = [UIColor whiteColor];
    self.box.layer.contents = (__bridge id)[UIImage imageNamed:@"1"].CGImage;
}
- (void)p_contentsCenter {
    self.box.backgroundColor = [UIColor whiteColor];
    self.box.layer.contents = (__bridge id)[UIImage imageNamed:@"1"].CGImage;
    self.box.frame = CGRectMake(0, 0, 100, 50);
}
- (void)p_jumpIcon {
    self.box.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.box.layer.contents = (__bridge id)[UIImage imageNamed:@"1"].CGImage;
}
- (void)p_lyricsAnimation {
    [_box removeFromSuperview];
    TextProgressView *progressView = [[TextProgressView alloc] init];
    progressView.label.text = @"ONE PUNCH-MAN";
    _box = progressView;
    [self.view addSubview:self.box];
    [progressView.label sizeToFit];
    self.box.frame = progressView.label.frame;
    [self.box addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerAnimation)]];
}
#pragma mark - Animation
- (void)move {
    self.box.TVAnimation.move.offset(50,100,0).activate();
}
- (void)scale {
    self.box.TVAnimation.scale.to(2).activate();
}
- (void)rotate {
    self.box.TVAnimation.rotate.x.with.endAngle(M_PI * 2).repeat(-1).activate();
    self.box.TVAnimation.rotate.y.with.endAngle(M_PI * 2).repeat(-1).activate();
    self.box.TVAnimation.rotate.z.with.endAngle(M_PI * 2).repeat(-1).activate();
}
- (void)shadow {
    self.box.TVAnimation.shadow
    .offset(CGSizeMake(0, 0),CGSizeMake(-3, -3))
    .opacityTo(1)
    .colorTo([UIColor blueColor])
    .radiusTo(8.0)
    .activate();
}
- (void)bounds {
    self.box.TVAnimation.bounds.widthTo(10).heightTo(10).didStop(^{
        self.box.TVAnimation.bounds.widthTo(100).heightTo(100).activate();
    }).activate();
}
- (void)anchor {
    if (self.box.TVAnimation.sprites.count >= 1) {
        CGFloat x = (arc4random() % 10) / 10.0,y = (arc4random() % 10) / 10.0;
        self.box.TVAnimation.anchor.xTo(x).yTo(y).didStop(^{
            self.box.layer.anchorPoint = CGPointMake(x, y);
        }).keepAlive(NO).timing(TVTiming.linear).duration(0.5).activate();
    }else {
        self.box.TVAnimation.rotate.z.with.endAngle(M_PI * 2).repeat(-1).duration(1).timing(TVTiming.linear).activate();
    }
}
- (void)translate {
    self.box.TVAnimation.translate.xBy(100).yBy(100).activate();
}
- (void)fade {
    self.box.TVAnimation.fade.fadeOut.reverse.repeat(-1).duration(0.5).activate();
}
- (void)drawRange {
    self.box.backgroundColor = [UIColor whiteColor];
    self.box.TVAnimation.appearance.keepAlive(NO).end();
    self.box.TVAnimation.contents.drawRange(nil,[UIImage imageNamed:@"1"]).didStop(^{
        self.box.TVAnimation.contents.drawRange([UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"]).didStop(^{
            self.box.TVAnimation.contents.drawRange([UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"]).didStop(^{
                self.box.TVAnimation.contents.drawRange([UIImage imageNamed:@"3"],[UIImage imageNamed:@"2"]).activate();
            }).activate();
        }).activate();
    }).activate();
}

- (void)contentsScale {
    self.box.TVAnimation.contents.scale(1).activate();
}
- (void)contentsRect {
    self.box.TVAnimation.contents.rect(CGRectMake(0.25, 0.25, 0.5, 0.5)).didStop(^{
        self.box.TVAnimation.contents.rect(CGRectMake(-0.25, -0.25, 1.5, 1.5)).activate();
    }).activate();
}
- (void)contentsCenter {
    self.box.TVAnimation.contents.centerRange(CGRectMake(0, 0, 1, 1),CGRectMake(0.4, 0.4, 0.2, 0.2)).activate();
}
- (void)backgroundColor {
    self.box.TVAnimation.backgroundColor.transitTo([UIColor blueColor]).didStop(^{
        self.box.TVAnimation.backgroundColor.transitTo([UIColor yellowColor]).didStop(^{
            self.box.TVAnimation.backgroundColor.transitTo([UIColor greenColor]).didStop(^{
                
            }).activate();
        }).activate();
    }).activate();
}
- (void)cornerRadius {
    self.box.TVAnimation.cornerRadius.transitTo(25).reverse.duration(0.5).repeat(-1).activate();
}
- (void)border {
    self.box.TVAnimation.border.widthTo(10).color([UIColor yellowColor],[UIColor blueColor]).duration(0.25).reverse.repeat(-1).activate();
}
- (void)path {
    self.box.TVAnimation.appearance.timing(TVTiming.linear).end();
    CGFloat width = [UIScreen mainScreen].bounds.size.width,height = [UIScreen mainScreen].bounds.size.height;
    self.box.TVAnimation.path.duration(10).mode(kCAAnimationLinear)
    .beginWith(self.box.center.x,self.box.center.y).endAtPercent(0)
    .lineTo(0,0).endAtPercent(25).timing(TVTiming.linear)
    .curveTo(width,height).cpt1(width, 0).cpt2(width, 0).endAtPercent(50).timing(TVTiming.extremeEaseOut)
    .lineTo(0,height).endAtPercent(75).timing(TVTiming.extremeEaseOut)
    .curveTo(width,0).cpt1(0, 0).cpt2(0, 0).endAtPercent(100).timing(TVTiming.extremeEaseIn)
    .didStop(^{
        self.box.TVAnimation.move.xTo(self.view.center.x).yTo(self.view.center.y).didStop(^{
            self.box.TVAnimation.clear();
        }).activate();
    }).activate();
}

#pragma mark -
- (void)jumpIcon {
    self.box.TVAnimation.translate.yBy(-100).timing(TVTiming.extremeEaseOut).repeat(-1).reverse.duration(0.5).activate();
    self.box.TVAnimation.translate.x(-3,3).timing(TVTiming.extremeEaseOut).repeat(-1).reverse.duration(0.05).activate();
}
- (void)lyricsAnimation {
    TextProgressLayer *layer = (TextProgressLayer *)self.box.layer;
    self.box.TVAnimation.basicCustom.property(@"progress").timing(TVTiming.extremeEaseOut).duration(2).to(@1.0).keepAlive(YES).didStop(^{
//        layer.progress = 0.5;
//        self.box.TVAnimation.clear();
//        self.box.TVAnimation.basicCustom.property(@"progress").timing(TVTiming.extremeEaseOut).duration(6).from(@0.5).to(@1.0).keepAlive(YES).didStop(^{
//            layer.progress = 1.0;
//            self.box.TVAnimation.clear();
//        }).activate();
    }).activate();
}

#pragma mark -
- (UIView *)box {
    if (!_box) {
        _box = [UIView new];
        _box.frame = CGRectMake(0, 0, 50, 50);
        _box.backgroundColor = [UIColor redColor];
        [_box addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerAnimation)]];
        _box.TVAnimation.appearance.duration(3).timing(TVTiming.extremeEaseOut).keepAlive(YES).end();
        [self.view addSubview:_box];
    }
    return _box;
}


@end
