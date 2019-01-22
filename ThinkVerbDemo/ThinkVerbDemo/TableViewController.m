//
//  TableViewController.m
//  ThinkVerbDemo
//
//  Created by 工作 on 2019/1/19.
//  Copyright © 2019 CAI. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

@interface TableViewController ()
@property (nonatomic,assign) int sectionCount;
@property (nonatomic,strong) NSMutableArray<NSNumber *> *counts;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.title = @"Animation List";
    while (animationSections[self.sectionCount].name) {
        self.sectionCount++;
    }
    self.counts = [NSMutableArray new];
    for (int i = 0; i < self.sectionCount; i++) {
        int count = 0;
        while (animationSections[i].unit[count].key) {
            count++;
        }
        [self.counts addObject:@(count)];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return animationSections[section].name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.counts[section].integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = animationSections[indexPath.section].unit[indexPath.row].key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *controller = [[ViewController alloc] init];
    controller.unit = &animationSections[indexPath.section].unit[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
