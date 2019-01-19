//
//  ViewController.h
//  ThinkVerbDemo
//
//  Created by Ruite Chen on 2019/1/16.
//  Copyright © 2019 CAI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct AnimationUnit {
    NSString *key;
    NSString *selector;
}AnimationUnit;

extern AnimationUnit animationUnits[];

@interface ViewController : UIViewController

@property AnimationUnit *unit;

@end

