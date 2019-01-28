<img src="https://github.com/hon-key/ThinkVerb/blob/d5ad3fc25751bb9b388c97d0972f4c6ad4692414/Resources/logo.png" width = "100%" />

# ThinkVerb
ThinkVerb is an Animation Interface based on CoreAnimation, it help you make CAAnimation for view's layer easily. ThinkVerb uses chain programming style to mak CAAnimation. Most of the time you just need to type one line of code to make an animation even if it is complicated. So you can do animation anywhere easily and the code is so human readable.

# Usage
ThinkVerb just have one entrance,that is TVAnimation of an UIView,it is a manager of animation sprite,all you need to do is make an animation sprite using a TVAnimation and then activate it.

#### Take an example,if you want to rotate an UIView forever,just type:
```
NSString *rotation = view.TVAnimation.rotate.z.endAngle(M_PI * 2).repeat(-1).activate();
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
The action stop and release the rotation animation
