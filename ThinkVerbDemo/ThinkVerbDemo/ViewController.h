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

typedef struct AnimationSection {
    NSString *name;
    AnimationUnit *unit;
}AnimationSection;

extern AnimationSection animationSections[];
extern AnimationUnit baseAnimations[];
extern AnimationUnit animationSets[];
 
@interface ViewController : UIViewController
@property AnimationUnit *unit;
@end

