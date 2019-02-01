<img src="https://github.com/hon-key/ThinkVerb/blob/d5ad3fc25751bb9b388c97d0972f4c6ad4692414/Resources/logo.png" width = "100%" />

[English Introduction](https://github.com/hon-key/ThinkVerb/blob/master/README_EN.md)

# ThinkVerb
ThinkVerb 是一组基于 CoreAnimation 的 API，相比与直接使用 CoreAnimation，ThinkVerb 通过链式语法进行编程，并且自管理 CAAnimation，你无需自己手动创建任何 CAAnimation 并将其添加到视图上。

得益于此，ThinkVerb 可以用非常少的代码快速生成基础动画，不单单如此，你所写的代码还相当可读而易于维护。

目前 ThinkVerb 的功能几乎涵盖了所有的基础动画，你可以轻松通过多个基础动画的组合来生成一个复杂的动画。如果用原生代码，你可能需要大量代码来完成此工作，但是用 ThinkVerb，你则可以在短短几行代码里完成相同的工作量。

# Usage
ThinkVerb 很简单，它只有一个入口，那就是 ThinkVerb 扩展 UIView 的一个属性：TVAnimation。

TVAnimation 管理所有的动画单元，我们称动画单元为 Sprite，你需要做的只有：通过 TVAnimation 创建 sprite，配置 sprite，最后 activate sprite。
这样，动画就被激活，UIView 将自动开始动画。

#### 例如，如果你想永不停息地旋转你的 UIView，你只需要下面这一句代码：
```
NSString *rotation = view.TVAnimation.rotate.z.endAngle(M_PI * 2).repeat(-1).activate();
```
或者，如果你想为你创建的 sprite 定义你自己想要的名字，你可以这么写:
```
view.TVAnimation.rotate.z.endAngle(M_PI * 2).repeat(-1).activateAs(@"rotation");
```

这行代码会绕着 z 轴旋转你的 UIView，其旋转角度是从 UIView 当前的角度旋转到 M_PI * 2，假设当前角度是 0，那就是转一圈。**`repeat(-1)`** 能够让 sprite 无限重复。最后，调用 **`activate()`** 就等于激活了该动画。

#### 通常情况下，如果你没有让 sprite 永远重复下去，或者没有让 sprite 在动画结束时停留，sprite 会自动被移除并释放，而如上面的例子，你需要手动移除该动画:
```
view.TVAnimation.clear();
```
#### 上面一行代码移除 view 的所有动画，通常情况下，你调用这一行代码就够了，如果你不想对 view 的其他动画造成影响，你可以只移除相应的动画:
```
view.TVAnimation.existSprite(rotation).stop();
```

如果你自己定义了名字，你可以这么做:
```
view.TVAnimation.existSprite(@"rotation").stop();
```

这样，旋转会停止，sprite 会被移除并释放，否则，就算 view 释放掉了，sprite 也不会被释放，从而造成内存泄漏。

你可以通过 ThinkVerbDemo 看到更多的例子。

ThinkVerb 做复杂动画也是相当轻松的，你甚至可以写出一把手枪来:

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
拷贝子 ThinkVerb 文件夹下的所有源码到你的工程

# Indexes

* ### Basic

    - [**move**](#move) **`从某个点移动 view 到另一个点`**

    - [**scale**](#scale) **`将 view 缩放到某个倍数`**

    - [**rotate**](#rotate) **`围绕 x/y/z 轴旋转 view`**

    - [**shadow**](#shadow) **`对 shadow 的 offset/opacity/radius/color 做动画,`**

    - [**bounds**](#bounds) **`对 view 的 bounds 做动画，注意该动画效果取决于 anchorPoint `**

    - [**anchor**](#anchor) **`对 view 的 anchorPoint 做动画，单独进行不会有任何效果，需要和相关的动画组合才会有效果`**

    - [**translate**](#translate) **`通过偏移来移动动画，基于 Transform3D，所以你可以将它应用到 sublayer 上`**

    - [**fade**](#fade) **`淡入淡出`**
    
    - [**contents**](#contents) **`对 cotnents 属性做动画，如 rect属性会对位图的渲染返回做动画，范围在 [0 0 1 1] 内`**

    - [**backgroundColor**](#backgroundColor) **`背景变换`**

    - [**cornerRadius**](#cornerRadius) **`圆角动画`**

    - [**border**](#border) **`对 view 的边框的宽度和颜色做动画`**

    - [**path**](#path) **`对 view 做关键帧动画，可通过贝塞尔控制点生成曲线动画`**

* ### Appearance
    appearance sprite 可以用来对某个 view 配置默认参数，如果你想让某个 view 的所有 sprite 默认在动画结束时停留而不移除，你可以在生成 sprite 之前写:
    ```
    view.TVAnimation.appearance.keepAlive(YES).end();
    ```



## License

ThinkVerb is released under the MIT license. See [LICENSE](https://github.com/hon-key/ThinkVerb/blob/master/LICENSE) for details.
