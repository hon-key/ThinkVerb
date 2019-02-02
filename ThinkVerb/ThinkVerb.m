//  ThinkVerb.m
//  Copyright (c) 2019 HJ-Cai
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ThinkVerb.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"

static void tv_add_animation_for_group(CAAnimationGroup *group,CAAnimation *animation) {
    NSMutableArray *animations = [group.animations mutableCopy];
    if (!animations) animations = [NSMutableArray new];
    [animations addObject:animation];
    group.animations = animations;
}

static void tv_cache_animations_into_sprite(ThinkVerbSprite *sprite,id animations,SEL cmd) {
    objc_setAssociatedObject(sprite, cmd, animations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
static id tv_get_animations_from_sprite(ThinkVerbSprite *sprite,SEL cmd) {
    id animations = objc_getAssociatedObject(sprite, cmd);
    if (!animations) return nil;
    objc_setAssociatedObject(sprite, cmd, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return animations;
}

@implementation ThinkVerb
- (ThinkVerbSprite *(^)(NSString *))existSprite {
    return ^ ThinkVerbSprite * (NSString *identifier) {
        __block ThinkVerbSprite *sprite = nil;
        [self.sprites enumerateObjectsUsingBlock:^(ThinkVerbSprite * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:identifier]) {
                sprite = obj;
                *stop = YES;
            }
        }];
        return sprite ?: [[ThinkVerbSprite alloc] init];
    };
}
- (void (^)(void))clear {
    return ^ void (void) {
        NSSet<ThinkVerbSprite *> *sprites = [self.sprites copy];
        [sprites enumerateObjectsUsingBlock:^(ThinkVerbSprite * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.stop();
        }];
    };
}
- (ThinkVerbSpriteAppearance *)appearance {
    ThinkVerbSpriteAppearance *appearance = objc_getAssociatedObject(self, _cmd);
    if (!appearance) {
        appearance = [[ThinkVerbSpriteAppearance alloc] init];
        objc_setAssociatedObject(self, _cmd, appearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return appearance;
}
- (CALayer *)presentationLayer {
    return self.view.layer.presentationLayer ?: self.view.layer;
}

- (TVSpriteMove *)move {return [self createSprite:[TVSpriteMove class]];}
- (TVSpriteRotate *)rotate {return [self createSprite:[TVSpriteRotate class]];}
- (TVSpriteScale *)scale {return [self createSprite:[TVSpriteScale class]];}
- (TVSpriteShadow *)shadow {return [self createSprite:[TVSpriteShadow class]];}
- (TVSpriteBounds *)bounds {return [self createSprite:[TVSpriteBounds class]];}
- (TVSpriteAnchor *)anchor {return [self createSprite:[TVSpriteAnchor class]];}
- (TVSpriteTranslate *)translate {return [self createSprite:[TVSpriteTranslate class]];}
- (TVSpriteFade *)fade {return [self createSprite:[TVSpriteFade class]];}
- (TVSpriteContents *)contents {return [self createSprite:[TVSpriteContents class]];}
- (TVSpriteColor *)backgroundColor {return [self createSprite:[TVSpriteColor class]];}
- (TVSpriteCornerRadius *)cornerRadius {return [self createSprite:[TVSpriteCornerRadius class]];}
- (TVSpriteBorder *)border {return [self createSprite:[TVSpriteBorder class]];}
- (TVSpritePath *)path {return [self createSprite:[TVSpritePath class]];}
- (id)createSprite:(Class)cls {
    ThinkVerbSprite *sprite = [[cls alloc] init];
    sprite.thinkVerb = self;
    return sprite;
}

- (NSMutableSet<ThinkVerbSprite *> *)sprites {
    if (!_sprites) {
        _sprites = [NSMutableSet set];
    }
    return _sprites;
}
@end

@implementation UIView (ThinkVerb)
- (ThinkVerb *)TVAnimation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int methodCount = 0,classCount = 0;
        Method *methods = class_copyMethodList([ThinkVerbTransform3DTypeDefaultImplementation class], &methodCount);
        Class *clses = objc_copyClassList(&classCount);
        for (int i = 0; i < classCount; i++) {
            if (class_conformsToProtocol(clses[i], @protocol(ThinkVerbTransform3DType)) &&
                strcmp(class_getName(clses[i]), "ThinkVerbTransform3DTypeDefaultImplementation") != 0) {
                for (int j = 0; j < methodCount; j++) {
                    SEL mname = method_getName(methods[j]);
                    IMP imp = method_getImplementation(methods[j]);
                    const char *type = method_getTypeEncoding(methods[j]);
                    class_addMethod(clses[i], mname, imp, type);
                }
            }
        }
        free(methods);free(clses);
    });
    ThinkVerb *thinkverb = objc_getAssociatedObject(self, _cmd);
    if (!thinkverb) {
        thinkverb = [[ThinkVerb alloc] init];
        objc_setAssociatedObject(self, _cmd, thinkverb, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    thinkverb.view = self;
    return thinkverb;
}
@end

#pragma mark - TimingFunction
@implementation TVTiming
+ (id (^)(CGFloat, CGFloat, CGFloat, CGFloat))create {
    return ^ id (CGFloat startX,CGFloat startY,CGFloat endX,CGFloat endY) {
        TVTiming *timing = [self functionWithControlPoints:startX :startY :endX :endY];
        return timing;
    };
}
+ (id)extremeEaseOut {return [self functionWithControlPoints:0 :0 :0 :1];}
+ (id)extremeEaseIn {return [self functionWithControlPoints:1 :0 :1 :1];}
+ (id)linear {return [self functionWithControlPoints:0 :0 :0 :0];}

@end

#pragma mark - Sprite base
@interface ThinkVerbSprite ()
@property (nonatomic,strong) void(^didStopAction)(void);
@end
@implementation ThinkVerbSprite
- (instancetype)init {
    if (self = [super init]) {
        self.identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}
- (void)setThinkVerb:(ThinkVerb *)thinkVerb {
    _thinkVerb = thinkVerb;
    ThinkVerbSprite<ThinkVerbSprite *,CAAnimation *> *appearance = self.thinkVerb.appearance;
    self.animation.duration = appearance.animation.duration;
    self.animation.repeatCount = appearance.animation.repeatCount;
    self.animation.beginTime = appearance.animation.beginTime;
    self.animation.timingFunction = appearance.animation.timingFunction;
    self.animation.autoreverses = appearance.animation.autoreverses;
    self.animation.removedOnCompletion = appearance.animation.isRemovedOnCompletion;
    self.animation.fillMode = appearance.animation.fillMode;
}
- (id (^)(NSInteger))repeat {
    return ^ id (NSInteger count) {
        self.animation.repeatCount = count < 0 ? HUGE_VALF : count;
        return self;
    };
}
- (id (^)(CGFloat))duration {
    return ^ id (CGFloat duration) {
        self.animation.duration = duration;
        return self;
    };
}
- (id (^)(CGFloat))delay {
    return ^ id (CGFloat delay) {
        self.animation.beginTime = CACurrentMediaTime() + delay;
        return self;
    };
}
- (id (^)(TVTiming *))timing {
    return ^ id (TVTiming *timing) {
        self.animation.timingFunction = timing;
        return self;
    };
}
- (id)reverse {
    self.animation.autoreverses = YES;
    return self;
}
- (id (^)(BOOL))keepAlive {
    return ^ id (BOOL value) {
        self.animation.removedOnCompletion = !value;
        self.animation.fillMode = value ? kCAFillModeForwards : kCAFillModeRemoved;
        return self;
    };
}
- (NSString *(^)(void))activate {
    return ^ NSString * (void) {
        [self.thinkVerb.view.layer addAnimation:self.animation forKey:self.identifier];
        [self.thinkVerb.sprites addObject:self];
        return self.identifier;
    };
}
- (void (^)(NSString *))activateAs {
    return ^void (NSString *identifier) {
        for (ThinkVerbSprite *sprite in self.thinkVerb.sprites) {
            if ([sprite.identifier isEqualToString:identifier]) {
                self.animation.delegate = nil;
                return;
            }
        }
        self.identifier = identifier;
        [self.thinkVerb.view.layer addAnimation:self.animation forKey:identifier];
        [self.thinkVerb.sprites addObject:self];
    };
}
- (void (^)(void))stop {
    return ^ void (void) {
        [self.thinkVerb.view.layer removeAnimationForKey:self.identifier];
        self.animation.delegate = nil;
        [self.thinkVerb.sprites removeObject:self];
    };
}
- (id (^)(void (^)(void)))didStop {
    return ^ id (void (^didStopAction)(void)) {
        self.didStopAction = didStopAction;
        return self;
    };
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.didStopAction) self.didStopAction();
    if ([self.thinkVerb.sprites containsObject:self] && self.animation.isRemovedOnCompletion) {
        self.animation.delegate = nil;
        [self.thinkVerb.sprites removeObject:self];
    }
    self.didStopAction = nil;
}
- (id)with {return self;}
@end

@implementation ThinkVerbTransform3DTypeDefaultImplementation
- (instancetype)toSubLayer {
    objc_setAssociatedObject(self, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}
- (NSString *(^)(void))activate {
    if (((NSNumber *)objc_getAssociatedObject(self, @selector(toSubLayer))).boolValue == YES) {
        if ([self.animation isKindOfClass:[CAAnimationGroup class]]) {
            CAAnimationGroup *group = self.animation;
            for (CAPropertyAnimation *animation in group.animations) {
                if ([animation isKindOfClass:[CAPropertyAnimation class]]) {
                    animation.keyPath = [animation.keyPath stringByReplacingOccurrencesOfString:@"transform" withString:@"sublayerTransform"];
                }
            }
        }else if ([self.animation isKindOfClass:[CAPropertyAnimation class]]) {
            CAPropertyAnimation *animation = self.animation;
            animation.keyPath = [animation.keyPath stringByReplacingOccurrencesOfString:@"transform" withString:@"sublayerTransform"];
        }
    }
    return super.activate;
}
@end

@implementation ThinkVerbSpriteAppearance
- (instancetype)init {
    if (self = [super init]) {
        self.animation = [CAAnimation animation];
    }
    return self;
}
- (void(^)(void))end {return ^void(void){};}
@end

@implementation ThinkVerbSpriteBasic
- (instancetype)init {
    if (self = [super init]) {
        self.animation = [CABasicAnimation animationWithKeyPath:self.keyPath ?: @""];
        self.animation.delegate = self;
    }
    return self;
}
@end

@implementation ThinkVerbSpriteGroup
- (instancetype)init {
    if (self = [super init]) {
        self.animation = [CAAnimationGroup animation];
        self.animation.delegate = self;
    }
    return self;
}
@end

@implementation ThinkVerbSpriteKeyframe
- (instancetype)init {
    if (self = [super init]) {
        self.animation = [CAKeyframeAnimation animationWithKeyPath:self.keyPath ?: @""];
        self.animation.delegate = self;
    }
    return self;
}
- (id (^)(CAAnimationCalculationMode))mode {
    return ^ id (CAAnimationCalculationMode mode) {
        ((CAKeyframeAnimation *)self.animation).calculationMode = mode;
        return self;
    };
}
- (id (^)(TVTiming *))timing {
    return ^ id (TVTiming *timing) {
        CAKeyframeAnimation *animation = self.animation;
        NSAssert(animation.values.count >= 2, @"You must add at least two point into sprite");
        NSAssert(animation.timingFunctions.count < animation.values.count - 1, @"You can't add timing functions more than a count of the points - 1");
        NSMutableArray *timingFunctions = [animation.timingFunctions mutableCopy];
        if (!timingFunctions) timingFunctions = [NSMutableArray new];
        while (timingFunctions.count < animation.values.count - 2) {
            [timingFunctions addObject:[TVTiming functionWithName:kCAMediaTimingFunctionDefault]];
        }
        [timingFunctions addObject:timing];
        animation.timingFunctions = timingFunctions;
        return self;
    };
}
- (id (^)(NSInteger))endAtPercent {
    return ^ id (NSInteger percent) {
        CAKeyframeAnimation *animation = self.animation;
        NSAssert(animation.values.count > 0, @"You must add at least one point into sprite");
        NSAssert(percent >= 0 && percent <= 100 , @"the percent must be in range of [0-100]");
        if (animation.values.count == 1) {
            NSAssert(percent == 0, @"the percent must be 0 at the first point");
        }else {
            NSAssert((percent / 100.0) > animation.keyTimes.lastObject.floatValue, @"the percent must be larger than the previous percent");
        }
        NSMutableArray<NSNumber *> *keyTimes = [animation.keyTimes mutableCopy];
        if (!keyTimes) keyTimes = [NSMutableArray new];
        if (keyTimes.count == 0) [keyTimes addObject:@(0.0)];
        CGFloat lastKeyTime = keyTimes.lastObject.floatValue;
        NSInteger lackTimesCount = animation.values.count - keyTimes.count;
        CGFloat avrageOfLackTimes = ((percent / 100.0) - lastKeyTime) / lackTimesCount;
        for (int i = 1; i <= lackTimesCount; i++) {
            [keyTimes addObject:@(lastKeyTime + avrageOfLackTimes * i)];
        }
        animation.keyTimes = keyTimes;
        return self;
    };
}

- (NSString *(^)(void))activate {
    CAKeyframeAnimation *animation = self.animation;
    if (animation.keyTimes) {
        if (animation.keyTimes.count < animation.values.count) {
            self.endAtPercent(100);
        }
        NSAssert(animation.keyTimes.lastObject.floatValue == 1, @"the last keyTime must be 1");
    }
    NSMutableArray *timingFunctions = [animation.timingFunctions mutableCopy] ?: [NSMutableArray new];
    while (timingFunctions.count < animation.values.count - 1) {
        [timingFunctions addObject:[TVTiming functionWithName:kCAMediaTimingFunctionDefault]];
    }
    animation.timingFunctions = timingFunctions;
    return super.activate;
}

- (void (^)(void))stop {
    [self releasePath];
    return super.stop;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [super animationDidStop:anim finished:flag];
    [self releasePath];
}

- (void)releasePath {
    CAKeyframeAnimation *animation = self.animation;
    CGPathRelease(animation.path);
    animation.path = NULL;
}

@end

#pragma mark - Sprite
@implementation TVSpriteRotate
- (NSString *)keyPath {
    return @"transform.rotation.z";
}
- (TVSpriteRotate *)x {
    self.animation.keyPath = @"transform.rotation.x";
    return self;
}
- (TVSpriteRotate *)y {
    self.animation.keyPath = @"transform.rotation.y";
    return self;
}
- (TVSpriteRotate *)z {
    self.animation.keyPath = @"transform.rotation.z";
    return self;
}
- (TVSpriteRotate *(^)(CGFloat))startAngle {
    return ^ TVSpriteRotate * (CGFloat value) {
        self.animation.fromValue = @(value);
        return self;
    };
}
- (TVSpriteRotate *(^)(CGFloat))endAngle {
    return ^ TVSpriteRotate * (CGFloat value) {
        self.animation.toValue = @(value);
        return self;
    };
}
- (TVSpriteRotate *(^)(CGFloat, CGFloat))angle {
    return ^ TVSpriteRotate * (CGFloat from,CGFloat to) {
        self.animation.fromValue = @(from);
        self.animation.toValue = @(to);
        return self;
    };
}

@end

@implementation TVSpriteScale
- (TVSpriteScale *(^)(CGFloat, CGFloat))x {
    return ^ TVSpriteScale * (CGFloat from, CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        xAnim.fromValue = @(from); xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat, CGFloat))y {
    return ^ TVSpriteScale * (CGFloat from, CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        xAnim.fromValue = @(from); xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat, CGFloat))z {
    return ^ TVSpriteScale * (CGFloat from, CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.z"];
        xAnim.fromValue = @(from); xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat))xTo {
    return ^ TVSpriteScale * (CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat))yTo {
    return ^ TVSpriteScale * (CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
        xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat))zTo {
    return ^ TVSpriteScale * (CGFloat to) {
        CABasicAnimation *xAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale.z"];
        xAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, xAnim);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat))from {
    return ^ TVSpriteScale * (CGFloat from) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim.fromValue = @(from);
        tv_cache_animations_into_sprite(self, anim, _cmd);
        return self;
    };
}
- (TVSpriteScale *(^)(CGFloat))to {
    return ^ TVSpriteScale * (CGFloat to) {
        CABasicAnimation *anim = tv_get_animations_from_sprite(self, @selector(from)) ?: [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        anim.toValue = @(to);
        tv_add_animation_for_group(self.animation, anim);
        return self;
    };
}
@end

@implementation TVSpriteTranslate
- (TVSpriteTranslate *(^)(CGFloat, CGFloat, CGFloat))from {
    return ^ TVSpriteTranslate * (CGFloat x,CGFloat y,CGFloat z) {
        CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        CABasicAnimation *translationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        CABasicAnimation *translationZ = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
        translationX.fromValue = @(x);
        translationY.fromValue = @(y);
        translationZ.fromValue = @(z);
        tv_cache_animations_into_sprite(self, @[translationX,translationY,translationZ], _cmd);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat, CGFloat, CGFloat))to {
    return ^ TVSpriteTranslate * (CGFloat x,CGFloat y,CGFloat z) {
        NSArray *from = tv_get_animations_from_sprite(self, @selector(from));
        CABasicAnimation *translationX = from[0] ?: [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        CABasicAnimation *translationY = from[1] ?: [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        CABasicAnimation *translationZ = from[2] ?: [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
        translationX.toValue = @(x);
        translationY.toValue = @(y);
        translationZ.toValue = @(z);
        tv_add_animation_for_group(self.animation, translationX);
        tv_add_animation_for_group(self.animation, translationY);
        tv_add_animation_for_group(self.animation, translationZ);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat, CGFloat))x {
    return ^ TVSpriteTranslate * (CGFloat from,CGFloat to) {
        CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        translationX.fromValue = @(from);
        translationX.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationX);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat, CGFloat))y {
    return ^ TVSpriteTranslate * (CGFloat from,CGFloat to) {
        CABasicAnimation *translationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        translationY.fromValue = @(from);
        translationY.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationY);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat, CGFloat))z {
    return ^ TVSpriteTranslate * (CGFloat from,CGFloat to) {
        CABasicAnimation *translationZ = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        translationZ.fromValue = @(from);
        translationZ.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationZ);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat))xBy {
    return ^ TVSpriteTranslate * (CGFloat to) {
        CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        translationX.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationX);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat))yBy {
    return ^ TVSpriteTranslate * (CGFloat to) {
        CABasicAnimation *translationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        translationY.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationY);
        return self;
    };
}
- (TVSpriteTranslate *(^)(CGFloat))zBy {
    return ^ TVSpriteTranslate * (CGFloat to) {
        CABasicAnimation *translationZ = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
        translationZ.toValue = @(to);
        tv_add_animation_for_group(self.animation,translationZ);
        return self;
    };
}
@end

@implementation TVSpriteMove
- (TVSpriteMove *(^)(CGFloat, CGFloat,CGFloat))offset {
    return ^ TVSpriteMove * (CGFloat x,CGFloat y,CGFloat z) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        CABasicAnimation *zPosition = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        position.toValue = @(CGPointMake(self.thinkVerb.presentationLayer.position.x + x,
                                         self.thinkVerb.presentationLayer.position.y + y));
        zPosition.toValue = @(self.thinkVerb.presentationLayer.zPosition + z);
        tv_add_animation_for_group(self.animation,position);
        tv_add_animation_for_group(self.animation,zPosition);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat, CGFloat,CGFloat))from {
    return ^ TVSpriteMove * (CGFloat x,CGFloat y,CGFloat z) {
        NSArray *array = tv_get_animations_from_sprite(self, _cmd);
        CABasicAnimation *position = array ? array[0] : [CABasicAnimation animationWithKeyPath:@"position"];
        CABasicAnimation *zPosition = array ? array[1] : [CABasicAnimation animationWithKeyPath:@"zPosition"];
        position.fromValue = @(CGPointMake(x, y));
        zPosition.fromValue = @(z);
        tv_cache_animations_into_sprite(self, @[position,zPosition], _cmd);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat, CGFloat,CGFloat))to {
    return ^ TVSpriteMove * (CGFloat x,CGFloat y,CGFloat z) {
        NSArray *array = tv_get_animations_from_sprite(self, @selector(from));
        CABasicAnimation *position = array ? array[0] : [CABasicAnimation animationWithKeyPath:@"position"];
        CABasicAnimation *zPosition = array ? array[1] : [CABasicAnimation animationWithKeyPath:@"zPosition"];
        position.toValue = @(CGPointMake(x, y));
        zPosition.toValue = @(z);
        tv_add_animation_for_group(self.animation, position);
        tv_add_animation_for_group(self.animation, zPosition);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat, CGFloat))x {
    return ^ TVSpriteMove * (CGFloat from,CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position.x"];
        position.fromValue = @(from);
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat, CGFloat))y {
    return ^ TVSpriteMove * (CGFloat from,CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position.y"];
        position.fromValue = @(from);
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat, CGFloat))z {
    return ^ TVSpriteMove * (CGFloat from,CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        position.fromValue = @(from);
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat))xTo {
    return ^ TVSpriteMove * (CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position.x"];
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat))yTo {
    return ^ TVSpriteMove * (CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position.y"];
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
- (TVSpriteMove *(^)(CGFloat))zTo {
    return ^ TVSpriteMove * (CGFloat to) {
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        position.toValue = @(to);
        tv_add_animation_for_group(self.animation,position);
        return self;
    };
}
@end

@implementation TVSpriteShadow
- (TVSpriteShadow *(^)(CGSize, CGSize))offset {
    return ^ TVSpriteShadow * (CGSize startOffset,CGSize endOffset) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
        subAnimation.fromValue = @(startOffset);
        subAnimation.toValue = @(endOffset);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteShadow *(^)(CGFloat, CGFloat))offsetTo {
    return ^ TVSpriteShadow * (CGFloat width,CGFloat height) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
        subAnimation.toValue = @(CGSizeMake(width, height));
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}

- (TVSpriteShadow *(^)(CGFloat, CGFloat))opacity {
    return ^ TVSpriteShadow * (CGFloat startOpacity,CGFloat endOpacity) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        subAnimation.fromValue = @(startOpacity);
        subAnimation.toValue = @(endOpacity);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteShadow *(^)(CGFloat))opacityTo {
    return ^ TVSpriteShadow * (CGFloat opacity) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        subAnimation.toValue = @(opacity);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}

- (TVSpriteShadow *(^)(CGFloat, CGFloat))radius {
    return ^ TVSpriteShadow * (CGFloat startRadius,CGFloat endRadius) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        subAnimation.fromValue = @(startRadius);
        subAnimation.toValue = @(endRadius);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteShadow *(^)(CGFloat))radiusTo {
    return ^ TVSpriteShadow * (CGFloat radius) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        subAnimation.toValue = @(radius);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteShadow *(^)(UIColor *, UIColor *))color {
    return ^ TVSpriteShadow * (UIColor * startColor,UIColor *endColor) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
        subAnimation.fromValue = ((__bridge id)startColor.CGColor);
        subAnimation.toValue = ((__bridge id)endColor.CGColor);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteShadow *(^)(UIColor *))colorTo {
    return ^ TVSpriteShadow * (UIColor *color) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
        subAnimation.toValue = ((__bridge id)color.CGColor);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
@end

@implementation TVSpriteBounds
- (TVSpriteBounds *(^)(CGFloat, CGFloat))width {
    return ^ TVSpriteBounds * (CGFloat from,CGFloat to) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        subAnimation.fromValue = @(from);
        subAnimation.toValue = @(to);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteBounds *(^)(CGFloat, CGFloat))height {
    return ^ TVSpriteBounds * (CGFloat from,CGFloat to) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        subAnimation.fromValue = @(from);
        subAnimation.toValue = @(to);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteBounds *(^)(CGFloat))widthTo {
    return ^ TVSpriteBounds * (CGFloat to) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        subAnimation.toValue = @(to);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}
- (TVSpriteBounds *(^)(CGFloat))heightTo {
    return ^ TVSpriteBounds * (CGFloat to) {
        CABasicAnimation *subAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        subAnimation.toValue = @(to);
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}

- (TVSpriteBounds *(^)(CGFloat, CGFloat))from {
    return ^ TVSpriteBounds * (CGFloat width,CGFloat height) {
        CABasicAnimation *subAnimation = tv_get_animations_from_sprite(self, _cmd);
        subAnimation = subAnimation ?: [CABasicAnimation animationWithKeyPath:@"bounds"];
        subAnimation.fromValue = @(CGRectMake(0, 0, width, height));
        tv_cache_animations_into_sprite(self, subAnimation, _cmd);
        return self;
    };
}

- (TVSpriteBounds *(^)(CGFloat, CGFloat))to {
    return ^ TVSpriteBounds * (CGFloat width,CGFloat height) {
        CABasicAnimation *subAnimation = tv_get_animations_from_sprite(self, @selector(from));
        subAnimation = subAnimation ?: [CABasicAnimation animationWithKeyPath:@"bounds"];
        subAnimation.toValue = @(CGRectMake(0, 0, width, height));
        tv_add_animation_for_group(self.animation,subAnimation);
        return self;
    };
}

@end

@implementation TVSpriteAnchor
- (instancetype)init {
    if (self = [super init]) {
        CABasicAnimation *anchorPoint = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
        CABasicAnimation *anchorPointZ = [CABasicAnimation animationWithKeyPath:@"anchorPointZ"];
        tv_add_animation_for_group(self.animation, anchorPoint);
        tv_add_animation_for_group(self.animation, anchorPointZ);
    }
    return self;
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat, CGFloat))offset {
    return ^ TVSpriteAnchor * (CGFloat x,CGFloat y,CGFloat z) {
        CABasicAnimation *anchor = self.animation.animations[0];
        CABasicAnimation *anchorZ = self.animation.animations[1];
        CALayer *layer = self.thinkVerb.view.layer.presentationLayer ?: self.thinkVerb.view.layer;
        anchor.toValue = @(CGPointMake(layer.anchorPoint.x + x,layer.anchorPoint.y + y));
        anchorZ.toValue = @(layer.anchorPointZ + z);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat,CGFloat))from {
    return ^ TVSpriteAnchor * (CGFloat x,CGFloat y,CGFloat z) {
        CABasicAnimation *anchor = self.animation.animations[0];
        CABasicAnimation *anchorZ = self.animation.animations[1];
        anchor.fromValue = @(CGPointMake(x, y));
        anchorZ.fromValue = @(z);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat,CGFloat))to {
    return ^ TVSpriteAnchor * (CGFloat x,CGFloat y,CGFloat z) {
        CABasicAnimation *anchor = self.animation.animations[0];
        CABasicAnimation *anchorZ = self.animation.animations[1];
        anchor.toValue = @(CGPointMake(x, y));
        anchorZ.toValue = @(z);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat))x {
    return ^ TVSpriteAnchor * (CGFloat from,CGFloat to) {
        CABasicAnimation *anchor = self.animation.animations[0];
        
        CGPoint fromPoint = CGPointZero;
        if (anchor.fromValue) [anchor.fromValue getValue:&fromPoint];
        else fromPoint.y =  self.thinkVerb.presentationLayer.anchorPoint.y;
        fromPoint.x = from;
        anchor.fromValue = @(fromPoint);
        
        CGPoint toPoint = CGPointZero;
        if (anchor.toValue) [anchor.toValue getValue:&toPoint];
        else toPoint.y = self.thinkVerb.presentationLayer.anchorPoint.y;
        toPoint.x = to;
        anchor.toValue = @(toPoint);
        
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat))y {
    return ^ TVSpriteAnchor * (CGFloat from,CGFloat to) {
        CABasicAnimation *anchor = self.animation.animations[0];
        
        CGPoint fromPoint = CGPointZero;
        if (anchor.fromValue) [anchor.fromValue getValue:&fromPoint];
        else fromPoint.x =  self.thinkVerb.presentationLayer.anchorPoint.x;
        fromPoint.y = from;
        anchor.fromValue = @(fromPoint);
        
        CGPoint toPoint = CGPointZero;
        if (anchor.toValue) [anchor.toValue getValue:&toPoint];
        else toPoint.x = self.thinkVerb.presentationLayer.anchorPoint.x;
        toPoint.y = to;
        anchor.toValue = @(toPoint);
        
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat, CGFloat))z {
    return ^ TVSpriteAnchor * (CGFloat from,CGFloat to) {
        CABasicAnimation *anchorPointZ = self.animation.animations[1];
        anchorPointZ.fromValue = @(from);
        anchorPointZ.toValue = @(to);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat))xTo {
    return ^ TVSpriteAnchor * (CGFloat x) {
        CABasicAnimation *anchor = self.animation.animations[0];
        CGPoint toPoint = CGPointZero;
        if (anchor.toValue) [anchor.toValue getValue:&toPoint];
        toPoint.x = x;
        if (!anchor.toValue) toPoint.y = self.thinkVerb.presentationLayer.anchorPoint.y;
        anchor.toValue = @(toPoint);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat))yTo {
    return ^ TVSpriteAnchor * (CGFloat y) {
        CABasicAnimation *anchor = self.animation.animations[0];
        CGPoint toPoint = CGPointZero;
        if (anchor.toValue) [anchor.toValue getValue:&toPoint];
        toPoint.y = y;
        if (!anchor.toValue) toPoint.x = self.thinkVerb.presentationLayer.anchorPoint.x;
        anchor.toValue = @(toPoint);
        return self;
    };
}
- (TVSpriteAnchor *(^)(CGFloat))zTo {
    return ^ TVSpriteAnchor * (CGFloat to) {
        CABasicAnimation *anchorPointZ = self.animation.animations[1];
        anchorPointZ.toValue = @(to);
        return self;
    };
}
@end

@implementation TVSpriteFade
- (NSString *)keyPath {return @"opacity";}
- (TVSpriteFade *)fadeOut {
    self.animation.toValue = @(0);
    return self;
}
- (TVSpriteFade *)fadeIn {
    self.animation.toValue = @(1);
    return self;
}
- (TVSpriteFade *(^)(CGFloat))from {
    return ^ TVSpriteFade * (CGFloat value) {
        self.animation.fromValue = @(value > 1 ? 1 : value < 0 ? 0 : value);
        return self;
    };
}
- (TVSpriteFade *(^)(CGFloat))to {
    return ^ TVSpriteFade * (CGFloat value) {
        self.animation.toValue = @(value > 1 ? 1 : value < 0 ? 0 : value);
        return self;
    };
}
@end

@implementation TVSpriteContents
- (TVSpriteContents *(^)(UIImage *, UIImage *))drawRange {
    return ^ TVSpriteContents * (UIImage *from, UIImage *to) {
        CABasicAnimation *drawAnim = [CABasicAnimation animationWithKeyPath:@"contents"];
        drawAnim.fromValue = from ? (__bridge id)from.CGImage : self.thinkVerb.presentationLayer.contents ?: (__bridge id)[self nilImage].CGImage;
        drawAnim.toValue = to ? (__bridge id)to.CGImage : (__bridge id)[self nilImage].CGImage;
        tv_add_animation_for_group(self.animation, drawAnim);
        return self;
    };
}
- (UIImage *)nilImage {
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (TVSpriteContents *(^)(CGRect, CGRect))rectRange {
    return ^ TVSpriteContents * (CGRect from, CGRect to) {
        CABasicAnimation *rectAnim = [CABasicAnimation animationWithKeyPath:@"contentsRect"];
        if (!CGRectEqualToRect(from, CGRectNull)) rectAnim.fromValue = @(from);
        rectAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, rectAnim);
        return self;
    };
}
- (TVSpriteContents *(^)(CGRect))rect {
    return ^ TVSpriteContents * (CGRect to) {
        return self.rectRange(CGRectNull,to);
    };
}
- (TVSpriteContents *(^)(CGFloat, CGFloat))scaleRange {
    return ^ TVSpriteContents * (CGFloat from, CGFloat to) {
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"contentsScale"];
        if (from != CGFLOAT_MAX) scaleAnim.fromValue = @(from);
        scaleAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, scaleAnim);
        return self;
    };
}
- (TVSpriteContents *(^)(CGFloat))scale {
    return ^ TVSpriteContents * (CGFloat to) {
        return self.scaleRange(CGFLOAT_MAX,to);
    };
}
- (TVSpriteContents *(^)(CGRect, CGRect))centerRange {
    return ^ TVSpriteContents * (CGRect from, CGRect to) {
        CABasicAnimation *centerAnim = [CABasicAnimation animationWithKeyPath:@"contentsCenter"];
        if (!CGRectEqualToRect(from, CGRectNull)) centerAnim.fromValue = @(from);
        centerAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, centerAnim);
        return self;
    };
}
- (TVSpriteContents *(^)(CGRect))center {
    return ^ TVSpriteContents * (CGRect to) {
        return self.centerRange(CGRectNull,to);
    };
}
- (TVSpriteContents *(^)(CGFloat, CGFloat))minificationFilterBias {
    return ^ TVSpriteContents * (CGFloat from, CGFloat to) {
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"minificationFilterBias"];
        if (from != CGFLOAT_MAX) scaleAnim.fromValue = @(from);
        scaleAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, scaleAnim);
        return self;
    };
}

@end

@implementation TVSpriteColor
- (NSString *)keyPath {return @"backgroundColor";}
- (TVSpriteColor *(^)(UIColor *, UIColor *))transit {
    return ^TVSpriteColor * (UIColor *from, UIColor *to) {
        if (from) self.animation.fromValue = (__bridge id)from.CGColor;
        self.animation.toValue = (__bridge id)to.CGColor;
        return self;
    };
}
- (TVSpriteColor *(^)(UIColor *))transitTo {
    return ^TVSpriteColor * (UIColor *to) {
        return self.transit(nil,to);
    };
}

@end

@implementation TVSpriteCornerRadius
- (NSString *)keyPath {return @"cornerRadius";}
- (TVSpriteCornerRadius *(^)(CGFloat, CGFloat))transit {
    return ^TVSpriteCornerRadius * (CGFloat from, CGFloat to) {
        if (from != CGFLOAT_MAX) self.animation.fromValue = @(from);
        self.animation.toValue = @(to);
        return self;
    };
}
- (TVSpriteCornerRadius *(^)(CGFloat))transitTo {
    return ^TVSpriteCornerRadius * (CGFloat to) {
        return self.transit(CGFLOAT_MAX,to);
    };
}

@end

@implementation TVSpriteBorder
- (TVSpriteBorder *(^)(CGFloat, CGFloat))width {
    return ^TVSpriteBorder * (CGFloat from, CGFloat to) {
        CABasicAnimation *widthAnim = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        if (from != CGFLOAT_MAX) widthAnim.fromValue = @(from);
        widthAnim.toValue = @(to);
        tv_add_animation_for_group(self.animation, widthAnim);
        return self;
    };
}
- (TVSpriteBorder *(^)(CGFloat))widthTo {
    return ^TVSpriteBorder * (CGFloat to) {
        return self.width(CGFLOAT_MAX,to);
    };
}
- (TVSpriteBorder *(^)(UIColor *, UIColor *))color {
    return ^TVSpriteBorder * (UIColor *from, UIColor *to) {
        CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        if (from) colorAnim.fromValue = (__bridge id)from.CGColor;
        colorAnim.toValue = (__bridge id)to.CGColor;
        tv_add_animation_for_group(self.animation, colorAnim);
        return self;
    };
}
- (TVSpriteBorder *(^)(UIColor *))colorTo {
    return ^TVSpriteBorder * (UIColor *to) {
        return self.color(nil,to);
    };
}

@end

@interface TVSpritePath ()
@property (nonatomic,assign) CGPoint cachedCurvePoint;
@property (nonatomic,assign) CGPoint cachedCpt1,cachedCpt2;
@end

@implementation TVSpritePath
- (NSString *)keyPath {return @"position";}
- (instancetype)init {
    if (self = [super init]) {
        self.cachedCurvePoint = self.cachedCpt1 = self.cachedCpt2 = CGRectNull.origin;
        self.animation.calculationMode = kCAAnimationLinear;
    }
    return self;
}
- (TVSpritePath *(^)(CGFloat, CGFloat))beginWith {
    NSAssert(self.animation.values.count == 0, @"you cannot call beginWith again or there must be something wrong about animation.values");
    return ^ TVSpritePath * (CGFloat x,CGFloat y) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, x, y);
        NSMutableArray *values = [NSMutableArray new];
        [values addObject:@(CGPointMake(x, y))];
        self.animation.values = values;
        CGPathRelease(self.animation.path);
        self.animation.path = path;
        return self;
    };
}
- (TVSpritePath *(^)(CGFloat, CGFloat))lineTo {
    if (self.animation.values.count == 0) {
        self.beginWith(self.thinkVerb.presentationLayer.position.x,self.thinkVerb.presentationLayer.position.y);
    }
    [self addCachedCurvePointIfNeeded];
    return ^ TVSpritePath * (CGFloat x,CGFloat y) {
        CGMutablePathRef path = self.animation.path;
        CGPathAddLineToPoint(path, NULL, x, y);
        [self addValueToValuesWithX:x y:y];
        return self;
    };
}
- (TVSpritePath *(^)(CGFloat, CGFloat))curveTo {
    if (self.animation.values.count == 0) {
        self.beginWith(self.thinkVerb.presentationLayer.position.x,self.thinkVerb.presentationLayer.position.y);
    }
    [self addCachedCurvePointIfNeeded];
    return ^ TVSpritePath * (CGFloat x,CGFloat y) {
        self.cachedCurvePoint = CGPointMake(x, y);
        [self addValueToValuesWithX:x y:y];
        return self;
    };
}
- (TVSpritePath *(^)(CGFloat, CGFloat))cpt1 {
    return ^ TVSpritePath * (CGFloat x,CGFloat y) {
        self.cachedCpt1 = CGPointMake(x, y);
        return self;
    };
}
- (TVSpritePath *(^)(CGFloat, CGFloat))cpt2 {
    return ^ TVSpritePath * (CGFloat x,CGFloat y) {
        self.cachedCpt2 = CGPointMake(x, y);
        return self;
    };
}
- (void)addCachedCurvePointIfNeeded {
    if (!CGPointEqualToPoint(self.cachedCurvePoint, CGRectNull.origin)) {
        NSAssert(!CGPointEqualToPoint(self.cachedCpt1, CGRectNull.origin) &&
                 !CGPointEqualToPoint(self.cachedCpt2, CGRectNull.origin), @"you should set control point");
        CGMutablePathRef path = self.animation.path;
        CGPathAddCurveToPoint(path, NULL,
                              self.cachedCpt1.x, self.cachedCpt1.y,
                              self.cachedCpt2.x, self.cachedCpt2.y,
                              self.cachedCurvePoint.x, self.cachedCurvePoint.y);
        self.cachedCurvePoint = self.cachedCpt1 = self.cachedCpt2 = CGRectNull.origin;
    }
}
- (void)addValueToValuesWithX:(CGFloat)x y:(CGFloat)y {
    NSMutableArray *values = [self.animation.values mutableCopy];
    [values addObject:@(CGPointMake(x, y))];
    self.animation.values = values;
}

- (NSString *(^)(void))activate {
    [self addCachedCurvePointIfNeeded];
    return super.activate;
}

@end

#pragma clang diagnostic pop
