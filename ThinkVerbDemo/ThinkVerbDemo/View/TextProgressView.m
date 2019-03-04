//
//  GithubTextProgressView.m
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/3/4.
//  Copyright © 2019 CAI. All rights reserved.
//

#import "TextProgressView.h"

@implementation TextProgressLayer
- (instancetype)init {
    if (self = [super init]) {
        self.progress = 0.3;
    }
    return self;
}
- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height));
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }else {
        return [super needsDisplayForKey:key];
    }
}

@end

@implementation TextProgressView
+ (Class)layerClass {
    return [TextProgressLayer class];
}
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor redColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer setNeedsDisplay];
        [self addObserver:self forKeyPath:@"frame" options:0 context:nil];
        self.layer.mask = self.label.layer;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.layer.mask.frame = self.bounds;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.font = [UIFont boldSystemFontOfSize:40];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.text = @"Github";
    }
    return _label;
}
@end
