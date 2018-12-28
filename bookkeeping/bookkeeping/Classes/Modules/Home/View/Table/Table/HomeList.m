/**
 * 列表
 * @author 郑业强 2018-12-16 创建文件
 */

#import "HomeList.h"
#import "HomeListCell.h"
#import "HOME_EVENT_MANAGER.h"


#pragma mark - 声明
@interface HomeList()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation HomeList


- (void)initUI {
    [self setBackgroundColor:kColor_BG];
    [self table];
}


#pragma mark - set
- (void)setModels:(NSMutableArray<NSMutableArray<BookMonthModel *> *> *)models {
    _models = models;
    __weak typeof(self) weak = self;
    if (_status == HomeListStatusNormal) {
        // cell
        NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
        // cell
        HomeListCell *cell = [self.table cellForRowAtIndexPath:index];
        cell.models = models;
        // 移动
        [_table scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:false];
    } else if (_status == HomeListStatusPull) {
        // index
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *center = [NSIndexPath indexPathForRow:1 inSection:0];
        // cell
        HomeListCell *cell = [self.table cellForRowAtIndexPath:index];
        HomeListCell *centerCell = [self.table cellForRowAtIndexPath:center];
        cell.models = models;
        // 移动
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [weak.table scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:false];
        } completion:^(BOOL finished){
            [centerCell setModels:models];
            [weak.table scrollToRowAtIndexPath:center atScrollPosition:UITableViewScrollPositionTop animated:false];
        }];
    } else if (_status == HomeListStatusUp) {
        // index
        NSIndexPath *index = [NSIndexPath indexPathForRow:2 inSection:0];
        NSIndexPath *center = [NSIndexPath indexPathForRow:1 inSection:0];
        // cell
        HomeListCell *cell = [self.table cellForRowAtIndexPath:index];
        HomeListCell *centerCell = [self.table cellForRowAtIndexPath:center];
        cell.models = models;
        // 移动
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [weak.table scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:false];
        } completion:^(BOOL finished){
            [centerCell setModels:models];
            [weak.table scrollToRowAtIndexPath:center atScrollPosition:UITableViewScrollPositionTop animated:false];
        }];
    }
    _status = HomeListStatusNormal;
    [_table.mj_header endRefreshing];
    [_table.mj_footer endRefreshing];
}


#pragma mark - 事件
- (void)routerEventWithName:(NSString *)eventName data:(id)data {
    [self handleEventWithName:eventName data:data];
}
- (void)handleEventWithName:(NSString *)eventName data:(id)data {
    NSInvocation *invocation = self.eventStrategy[eventName];
    [invocation setArgument:&data atIndex:2];
    [invocation invoke];
    [super routerEventWithName:eventName data:data];
}
// 下拉刷新
- (void)homeTablePull:(id)data {
    _status = HomeListStatusPull;
}
// 上拉加载
- (void)homeTableUp:(id)data {
    _status = HomeListStatusUp;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeListCell *cell = [HomeListCell loadCode:tableView];
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height;
}


#pragma mark - get
- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [_table setDelegate:self];
        [_table setDataSource:self];
        [_table setPagingEnabled:YES];
        [_table lineHide];
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_table setShowsVerticalScrollIndicator:NO];
        [_table setScrollEnabled:NO];
        [self addSubview:_table];
    }
    return _table;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           HOME_TABLE_PULL: [self createInvocationWithSelector:@selector(homeTablePull:)],
                           HOME_TABLE_UP: [self createInvocationWithSelector:@selector(homeTableUp:)],
                           
                           };
    }
    return _eventStrategy;
}


@end