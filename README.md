<img src="https://github.com/hon-key/ThinkVerb/blob/d5ad3fc25751bb9b388c97d0972f4c6ad4692414/Resources/logo.png" width = "100%" />

# ThinkVerb
ThinkVerb is an Animation Interface based on CoreAnimation, it help you make CAAnimation for view's layer easily. ThinkVerb uses chain programming style to mak CAAnimation. Most of the time you just need to type one line of code to make an animation even if it is complicated. So you can do animation anywhere easily and the code is so human readable.

# Usage
ThinkVerb just have one entrance,that is TVAnimation of an UIView,it is a manager of animation sprite,all you need to do is make an animation sprite using a TVAnimation and then activate it.

#### Take an example,if you want to rotate an UIView forever,just type:
```
NSString *rotation = view.TVAnimation.rotate.z.endAngle(M_PI * 2).repeat(-1).activate();
```
or you can create sprite with specific name:
```
view.TVAnimation.rotate.z.endAngle(M_PI * 2).repeat(-1).activateAs(@"rotatation");
```

The code rotate your view around the z axis from current angle to endAngle, asume that the current angle is 0, your view will make a turn. **`repeat(-1)`** make this animation repeat forever. At last you just need to call **`activate()`** and the animation will automatically run.

#### If you want to stop rotation, most of time you just need to type:
```
view.TVAnimation.clear();
```
#### The action clear all animations of the view. You can also type:
```
view.TVAnimation.existSprite(rotation).stop();
```

or using specific name:
```
view.TVAnimation.existSprite(@"rotation").stop();
```

The action stop and release the rotation animation

You can see more animation example in ThinkVerbDemo project

You can combine any animation,even like a gun:

```
view.TVAnimation.appearance.duration(3).timing(TVTiming.extremeEaseOut).end();
view.TVAnimation.contents.drawRange(nil,[UIImage imageNamed:@"1"]).didStop(^{
    view.TVAnimation.contents.drawRange([UIImage imageNamed:@"1"],[UIImage imageNamed:@"2"]).didStop(^{
        view.TVAnimation.contents.drawRange([UIImage imageNamed:@"2"],[UIImage imageNamed:@"3"]).didStop(^{
            view.TVAnimation.contents.drawRange([UIImage imageNamed:@"3"],[UIImage imageNamed:@"2"]).activate();
        }).activate();
    }).activate();
}).activate();
```



# Installation
## Using cocoapods
```
pod 'ThinkVerb'
```

## Copy files
Copy all files from Thinkverb fold to your project 

# Indexes

* ### Basic

    - [**move**](#move) **`animate your view's position from one place to another place, position is related to anchorPoint`**

    - [**scale**](#scale) **`scale your view with times param`**

    - [**rotate**](#rotate) **`rotate your view around x/y/z axis`**

    - [**shadow**](#shadow) **`animate shadow offset/opacity/radius/color of a view,`**

    - [**bounds**](#bounds) **`aniamte bounds of a view's layer,bounds,the effect is related to view position `**

    - [**anchor**](#anchor) **`animate anchorPoint,normally you should animate anchor with other related animations`**

    - [**translate**](#translate) **`animte your view's position using offset, can be apply to sublayer`**

    - [**fade**](#fade) **`animate your view's opacity`**
    
    - [**contents**](#contents) **`animate bitmap of layer,using rect to animate rectangle of bitmap with range of [0 0 1 1],etc`**

    - [**backgroundColor**](#backgroundColor) **`aniamte background color of an UIView`**

    - [**cornerRadius**](#cornerRadius) **`animate cornerRadius of an UIView`**

    - [**border**](#border) **`animate border's width and color of an UIView`**

    - [**path**](#path) **`animate transition path of an UIView's layer`**

* ### Appearance
    appearance sprite is used to configure default value to all sprite of an UIView, take an example,if you want all animation keep alive when finished,you may do it like this before you make any sprite:
    ```
    view.TVAnimation.appearance.keepAlive(YES).end();
    ```



## License

ThinkVerb is released under the MIT license. See [LICENSE](https://github.com/hon-key/ThinkVerb/blob/master/LICENSE) for details.
