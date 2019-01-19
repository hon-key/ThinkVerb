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
@property (nonatomic,assign) int count;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.title = @"Animation List";
    while (animationUnits[self.count].key) {
        self.count++;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = animationUnits[indexPath.row].key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *controller = [[ViewController alloc] init];
    controller.unit = &animationUnits[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
