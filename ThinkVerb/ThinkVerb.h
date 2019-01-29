//  ThinkVerb.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ThinkVerb, ThinkVerbSprite<T,A:CAAnimation *>, ThinkVerbSpriteAppearance;
@class ThinkVerbSpriteBasic<T>, ThinkVerbSpriteGroup<T>;
@class TVSpriteRotate, TVSpriteScale, TVSpriteMove, TVSpriteFade;
@class TVSpriteShadow, TVSpriteBounds, TVSpriteAnchor, TVSpriteTranslate;
@class TVSpriteContents, TVSpriteColor, TVSpriteCornerRadius, TVSpriteBorder;
@class TVSpritePath;

/**
 Every animation prite are inherit from class ThinkVerbSprite. And the class ThinkVerbSprite implement the protocol ThinkVerbSpriteLike. So all the animation sprites are ThinkVerbSpriteLike.
 This protocol is used to recognize an object which is a ThinkVerbSprite.
 */
@protocol ThinkVerbSpriteLike <NSObject>
@end

/**
 The sprite which animates the CATransform3D property has implemented this protocol.
 ThinkVerbTransform3DType is used to convert a CATransform3D animation to sublayers animation.
 If you want to apply your animation sprite to every sublayer, call -toSubLayer
 */
@protocol ThinkVerbTransform3DType <NSObject>
@optional
- (instancetype)toSubLayer;
- (NSString * (^)(void))activate;
@end

@interface UIView (ThinkVerb)
/**
 Get the animation manager of a UIView.
 Use the animation manager to create a ThinkVerbSprite and do animation operations.
 This is the only entrance you should call in a UIView.
 */
- (ThinkVerb *)TVAnimation;
@end

/**
 Animation manager of a UIView
 */
@interface ThinkVerb : NSObject
/**
 The view which the receiver owns and create animation to.
 */
@property (nonatomic,weak) UIView *view;
/**
 Sprites contain all animations which is Animating / finished.
 Normaly, when an animation(sprite) is done, it will be removed from manager and auto released, but particularly when you call -keepAliveAtEnd of a sprite, the animation will not be removed, You must remove it yourself by calling -stop of the sprite or call -clear of the manager which owns it.
 */
@property (nonatomic,strong) NSMutableSet<ThinkVerbSprite *> *sprites;
/**
 return a CALayer which is presenting on the screen. According to the Mechanism of CoreAnimation, the return layer may be a presentationLayer or the layer of an animation view. This depend on whether the animation has began.
 */
- (CALayer *)presentationLayer;
/**
 use this method to get the exist sprite according to the id which was returned by -activate method.
 you probably use this method to get a sprite and stop it to remove the sprite from a manager.
 */
- (ThinkVerbSprite * (^) (NSString *))existSprite;
/**
 clears all sprites of a animation manager. all sprites will be auto released.
 */
- (void (^) (void))clear;
/**
 ThinkVerbSpriteAppearance manage the global variables. use it to apply default values, and all sprites you create later use these default values.
 */
- (ThinkVerbSpriteAppearance *)appearance;
/**
 Creates an animation sprite to move the view from one point to another point. (CATransform3D).
 */
- (TVSpriteMove *)move;
/**
 Creates an animation sprite to scale the view (CATransform3D).
 */
- (TVSpriteScale *)scale;
/**
 Creates an animation sprite to rotate the view (CATransform3D).
 */
- (TVSpriteRotate *)rotate;
/**
 Creates an animation sprite to animate shadow of the view.
 */
- (TVSpriteShadow *)shadow;
/**
 Creates an animation sprite to animate bounds of the view.
 */
- (TVSpriteBounds *)bounds;
/**
 Creates an animation sprite to animate anchor point of the view. a
 Anchor point affects bounds and transform property.
 */
- (TVSpriteAnchor *)anchor;
/**
 Creates an animation sprite to animate translation (CATransform3D).
 */
- (TVSpriteTranslate *)translate;
/**
 Creates an animation sprite to animate opacity of the view.
 */
- (TVSpriteFade *)fade;
/**
 Creates an animation sprite to animate contents(bitmap) of the view.
 */
- (TVSpriteContents *)contents;
/**
 Creates an animation sprite to animate backgroundColor of the view.
 */
- (TVSpriteColor *)backgroundColor;
/**
 Creates an animation sprite to animate cornerRadius of the view.
 */
- (TVSpriteCornerRadius *)cornerRadius;
/**
 Creates an animation sprite to animate border width and color of the view.
 */
- (TVSpriteBorder *)border;
/**
 Creates an animation sprite to animate path
 */
- (TVSpritePath *)path;
@end

/**
 Timing function Encapsulation.
 Recommend you to use Tween-o-Matic to check the effect of the value you set.
 The chinese version is https://github.com/YouXianMing/Tween-o-Matic-CN
 */
@interface TVTiming : CAMediaTimingFunction
/**
 Create a timing function
 */
+ (id (^) (CGFloat,CGFloat,CGFloat,CGFloat))create;
/**
 Ease out timing function
 */
+ (id)extremeEaseOut;
/**
 Ease In timing function
 */
+ (id)extremeEaseIn;
/**
 Linear timing function
 */
+ (id)linear;
@end

#pragma mark - Basic Sprite
/**
 ThinkVerbSprite is the basic class of all sprites.
 */
@interface ThinkVerbSprite <T,A:CAAnimation *> : NSObject <ThinkVerbSpriteLike,CAAnimationDelegate>
/**
 Every sprite has an identifier, you use identifier to recognize which animation sprite you want.
 */
@property (nonatomic,copy) NSString *identifier;
/**
 The manager which owns the receiver.
 */
@property (nonatomic,weak) ThinkVerb *thinkVerb;
/**
 The animation. This may be a CABasicAnimation or CAAnimationGroup.
 */
@property (nonatomic,strong) A animation;
/**
 sets repeat count for animation, < 0 represent forever.
 */
- (T (^)(NSInteger))repeat;
/**
 sets animation duration time.
 */
- (T (^)(CGFloat))duration;
/**
 sets animation delay time
 */
- (T (^)(CGFloat))delay;
/**
 sets animation timing function.
 if you are setting this property to keyframe animation like 'path',timing should be call after a calling of keyframe action,the timing funtion is bounded to the keyframe action.
 notice that if you are setting the timing property of appearance sprite,than you make a keyframe animation like 'path',timing property will effect the whole animation except every keyframe.
 */
- (T (^)(TVTiming *))timing;
/**
 Determines if the receiver plays in the reverse upon completion.
 */
- (T)reverse;
/**
 Determines if the animation is removed from the target layer’s animations upon completion,default is NO.
 */
- (T (^)(BOOL))keepAlive;
/**
 activates the animation and return the identifier of the animation.
 */
- (NSString * (^)(void))activate;
- (void (^)(NSString *))activateAs;
/**
 stops the animation and removes it.
 */
- (void (^)(void))stop;
/**
 called when the animation stops.
 */
- (T (^)(void(^)(void)))didStop;

- (T)with;
@end

@interface ThinkVerbTransform3DTypeDefaultImplementation : ThinkVerbSprite <ThinkVerbTransform3DType>
@end

@interface ThinkVerbSpriteAppearance : ThinkVerbSprite <ThinkVerbSpriteAppearance *,CABasicAnimation *>
- (void(^)(void))end;
@end

@interface ThinkVerbSpriteBasic <T> : ThinkVerbSprite <T,CABasicAnimation *>
@property (nonatomic,copy) NSString *keyPath;
@end

@interface ThinkVerbSpriteGroup <T> : ThinkVerbSprite <T,CAAnimationGroup *>
@end

@interface ThinkVerbSpriteKeyframe <T> : ThinkVerbSprite <T,CAKeyframeAnimation *>
@property (nonatomic,copy) NSString *keyPath;
/*
 The "mode". Possible values are `kCAAnimationDiscrete', `kCAAnimationLinear',
 `kCAAnimationPaced', `kCAAnimationCubic' and `kCAAnimationCubicPaced'.
 Defaults to `kCAAnimationLinear'. When set to
 `kCAAnimationPaced' or `kCAAnimationCubicPaced' the `timing' and `endAtPercent'
 properties of the animation are ignored and calculated implicitly.
 */
- (T (^)(CAAnimationCalculationMode))mode;
/**
 sets the end point of a keyFrame animation action,percent value should be in range of [0,100],
 and the percent of begin point and end point must be 0 and 100, every percent must be larger than the previous percent
 you no need to call this method all the time, because system will automatically caculate the average value between the two point if there are points betwwen them.
 */
- (T (^)(NSInteger))endAtPercent;
@end

#pragma mark - Sprite
/**
Rotation sprite,based on ThinkVerbTransform3DType
'x' : sets the x axis as rotation axis
'y' : sets the y axis as rotation axis
'z' : sets the z axis as rotation axis
'angle' : sets rotation angle range
'startAngle' : sets rotation start angle
'endAngle' : sets rotation end angle
 */
@interface TVSpriteRotate : ThinkVerbSpriteBasic <TVSpriteRotate *> <ThinkVerbTransform3DType>
- (TVSpriteRotate *)x;
- (TVSpriteRotate *)y;
- (TVSpriteRotate *)z;
- (TVSpriteRotate * (^)(CGFloat,CGFloat))angle;
- (TVSpriteRotate * (^)(CGFloat))startAngle;
- (TVSpriteRotate * (^)(CGFloat))endAngle;
@end

/**
 Scale sprite,use this sprite to scale an UIView
 'x/y/z' : sets the scale factor of x/y/z axis
 'xTo/yTo/zTo' : sets the scale factor of x/y/z axis to a value,with current value as a start value
 'from' : sets a start value to scale factor of all axis, you should call 'to' method after calling this
 'to' : sets a end value to scale factor of all axis, you no need to call 'from' mehod before calling this
 */
@interface TVSpriteScale : ThinkVerbSpriteGroup <TVSpriteScale *> <ThinkVerbTransform3DType>
- (TVSpriteScale * (^)(CGFloat,CGFloat))x;
- (TVSpriteScale * (^)(CGFloat,CGFloat))y;
- (TVSpriteScale * (^)(CGFloat,CGFloat))z;
- (TVSpriteScale * (^)(CGFloat))xTo;
- (TVSpriteScale * (^)(CGFloat))yTo;
- (TVSpriteScale * (^)(CGFloat))zTo;
- (TVSpriteScale * (^)(CGFloat))from;
- (TVSpriteScale * (^)(CGFloat))to;
@end

/**
 Translate sprite,use this sprite to make translation to an UIView,using offset value
 'x/y/z' : sets the translation offset of x/y/z axis
 'xBy/yBy/zBy' : sets the translation offset of x/y/z axis to a value,with current value as a start value
 'from' : sets a start value to translation offset of all axis, you should call 'to' method after calling this
 'to' : sets a end value to scale factor of all axis, you no need to call 'from' mehod before calling this
 */
@interface TVSpriteTranslate : ThinkVerbSpriteGroup <TVSpriteTranslate *> <ThinkVerbTransform3DType>
- (TVSpriteTranslate * (^)(CGFloat,CGFloat,CGFloat))from;
- (TVSpriteTranslate * (^)(CGFloat,CGFloat,CGFloat))to;
- (TVSpriteTranslate * (^)(CGFloat,CGFloat))x;
- (TVSpriteTranslate * (^)(CGFloat,CGFloat))y;
- (TVSpriteTranslate * (^)(CGFloat,CGFloat))z;
- (TVSpriteTranslate * (^)(CGFloat))xBy;
- (TVSpriteTranslate * (^)(CGFloat))yBy;
- (TVSpriteTranslate * (^)(CGFloat))zBy;
@end

/**
 Move sprite,use this sprite to make translation to an UIView,different from 'TVSpriteTranslate',it use logical coordinate to make translation,and is not a 'ThinkVerbTransform3DType' so you cannot apply it to sublayer
 'x/y/z' : sets the translation offset of x/y/z axis
 'xBy/yBy/zBy' : sets the translation offset of x/y/z axis to a value,with current value as a start value
 'from' : sets a start value to translation offset of all axis, you should call 'to' method after calling this
 'to' : sets a end value to scale factor of all axis, you no need to call 'from' mehod before calling this
 */
@interface TVSpriteMove : ThinkVerbSpriteGroup <TVSpriteMove *>
- (TVSpriteMove * (^)(CGFloat,CGFloat,CGFloat))offset;
- (TVSpriteMove * (^)(CGFloat,CGFloat,CGFloat))from;
- (TVSpriteMove * (^)(CGFloat,CGFloat,CGFloat))to;
- (TVSpriteMove * (^)(CGFloat,CGFloat))x;
- (TVSpriteMove * (^)(CGFloat,CGFloat))y;
- (TVSpriteMove * (^)(CGFloat,CGFloat))z;
- (TVSpriteMove * (^)(CGFloat))xTo;
- (TVSpriteMove * (^)(CGFloat))yTo;
- (TVSpriteMove * (^)(CGFloat))zTo;
@end

/**
 Shadow sprite,use this sprite to make animate shaddow to an UIView
 'offset/offsetTo' : animate shadowOffset,use offset to animate in range,use offsetTo to animate from current value to target value
 'opacity/opacityTo' : animate shadowOpacity
 'radius/radiusTo' : animate shadowRadius
 'color/colorTo' : animate shadowColor
 */
@interface TVSpriteShadow : ThinkVerbSpriteGroup <TVSpriteShadow *>
- (TVSpriteShadow * (^)(CGFloat,CGFloat))offsetTo;
- (TVSpriteShadow * (^)(CGSize,CGSize))offset;

- (TVSpriteShadow * (^)(CGFloat))opacityTo;
- (TVSpriteShadow * (^)(CGFloat,CGFloat))opacity;

- (TVSpriteShadow * (^)(CGFloat))radiusTo;
- (TVSpriteShadow * (^)(CGFloat,CGFloat))radius;

- (TVSpriteShadow * (^)(UIColor *))colorTo;
- (TVSpriteShadow * (^)(UIColor *,UIColor *))color;
@end

/**
 Bounds sprite,use this sprite to animate Bounds of an UIView,this will makes an effect like what you make using scale sprite
 'width/widthTo' : animate width of the bounds of view to a value
 'height/heightTo' : animate height of the bounds of view to a value
 'from/to' : animate height and height of the bounds of view to a value
 */
@interface TVSpriteBounds : ThinkVerbSpriteGroup <TVSpriteBounds *>
- (TVSpriteBounds * (^)(CGFloat,CGFloat))width;
- (TVSpriteBounds * (^)(CGFloat,CGFloat))height;
- (TVSpriteBounds * (^)(CGFloat))widthTo;
- (TVSpriteBounds * (^)(CGFloat))heightTo;
- (TVSpriteBounds * (^)(CGFloat,CGFloat))from;
- (TVSpriteBounds * (^)(CGFloat,CGFloat))to;
@end

/**
 Anchor sprite,use this sprite to animate anchor of an UIView
 Normally,anchor is related to bounds,move and ThinkVerbTransform3DType sprite,more detail in CoreAnimation Programming Guide
 */
@interface TVSpriteAnchor : ThinkVerbSpriteGroup <TVSpriteAnchor *>
- (TVSpriteAnchor * (^)(CGFloat,CGFloat,CGFloat))offset;
- (TVSpriteAnchor * (^)(CGFloat,CGFloat,CGFloat))from;
- (TVSpriteAnchor * (^)(CGFloat,CGFloat,CGFloat))to;
- (TVSpriteAnchor * (^)(CGFloat,CGFloat))x;
- (TVSpriteAnchor * (^)(CGFloat,CGFloat))y;
- (TVSpriteAnchor * (^)(CGFloat,CGFloat))z;
- (TVSpriteAnchor * (^)(CGFloat))xTo;
- (TVSpriteAnchor * (^)(CGFloat))yTo;
- (TVSpriteAnchor * (^)(CGFloat))zTo;
@end

/**
 Fade sprite,use this sprite to animate opacity of an UIView
 */
@interface TVSpriteFade : ThinkVerbSpriteBasic <TVSpriteFade *>
- (TVSpriteFade *)fadeOut;
- (TVSpriteFade *)fadeIn;
- (TVSpriteFade * (^) (CGFloat))from;
- (TVSpriteFade * (^) (CGFloat))to;
@end

/**
 Contents sprite,use this sprite to animate bitmap of an UIView's layer
 'drawRange' : animate from a bitmap to another bitmap, nil represents no bitmap
 'rect/rectRange' : animate rectangle of the contents,a rectangle in normalized image coordinates defining the
                    subrectangle of the `contents' property that will be drawn into the
                    layer. If pixels outside the unit rectangles are requested, the edge
                    pixels of the contents image will be extended outwards
 'scale/scaleRange' : animate contentsScale factor of an UIView's layer contents
 'center/centerRange' : contentsCenter defines a area to scale,default is [0 0 1 1],meaning of scall all of the contents
 */
@interface TVSpriteContents : ThinkVerbSpriteGroup <TVSpriteContents *>
- (TVSpriteContents * (^)(CGRect))rect;
- (TVSpriteContents * (^)(CGFloat))scale;
- (TVSpriteContents * (^)(CGRect))center;

- (TVSpriteContents * (^)(UIImage *,UIImage *))drawRange;
- (TVSpriteContents * (^)(CGRect,CGRect))rectRange;
- (TVSpriteContents * (^)(CGFloat,CGFloat))scaleRange;
- (TVSpriteContents * (^)(CGRect,CGRect))centerRange;

- (TVSpriteContents * (^)(CGFloat,CGFloat))minificationFilterBias;
@end

/**
 Color sprite,use this sprite to animate color of an UIView's layer.
 */
@interface TVSpriteColor : ThinkVerbSpriteBasic <TVSpriteColor *>
- (TVSpriteColor * (^)(UIColor *))transitTo;
- (TVSpriteColor * (^)(UIColor *,UIColor *))transit;
@end

/**
 CornerRadius sprite,use this sprite to animate cornerRadius of an UIView's layer.
 */
@interface TVSpriteCornerRadius : ThinkVerbSpriteBasic <TVSpriteCornerRadius *>
- (TVSpriteCornerRadius * (^)(CGFloat))transitTo;
- (TVSpriteCornerRadius * (^)(CGFloat,CGFloat))transit;
@end

/**
 Border sprite,use this sprite to animate border width and border color of an UIView's layer.
 */
@interface TVSpriteBorder : ThinkVerbSpriteGroup <TVSpriteBorder *>
- (TVSpriteBorder * (^)(CGFloat,CGFloat))width;
- (TVSpriteBorder * (^)(CGFloat))widthTo;
- (TVSpriteBorder * (^)(UIColor *,UIColor *))color;
- (TVSpriteBorder * (^)(UIColor *))colorTo;
@end

/**
 Path sprite,use this sprite to animate transition path of an UIView's layer
 You use this to make a custom moving path,first you may call -beginWith to set your origin point, if you don't,sprite will sets it to current presentation layer position
 You can call -timing to set timing function for evey animation point which is set from -lineto and -curveTo. if you don't sprite will automatically set the missing timing function property to linear timing function
 You can call -endAtPercent to set end time for every animation point which is set from -lineto and -curveTo,if you don't sprite will automatically caculate missing keytimes evenly
 You should call -cpt1 and -cpt2 to set control point for -curveTo to let system know how to do interpolation calculation
 */
@interface TVSpritePath : ThinkVerbSpriteKeyframe <TVSpritePath *>
- (TVSpritePath * (^)(CGFloat,CGFloat))beginWith;
- (TVSpritePath * (^)(CGFloat,CGFloat))lineTo;
- (TVSpritePath * (^)(CGFloat,CGFloat))curveTo;
- (TVSpritePath * (^)(CGFloat,CGFloat))cpt1;
- (TVSpritePath * (^)(CGFloat,CGFloat))cpt2;
@end







