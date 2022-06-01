//
//  RCRoomListViewController.m
//  RCLiveVideoDemo
//
//  Created by 彭蕾 on 2022/5/27.
//

#import "RCRoomListViewController.h"
#import "RCLoginViewController.h"
#import "RCRoomListPresenter.h"
#import "RCRoomListCell.h"
#import "RCSceneVideoRoomDemo-Swift.h"
#import <Masonry/Masonry.h>
#import <RCSceneVideoRoom/RCSceneVideoRoom.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface RCRoomListViewController ()<UITableViewDelegate, UITableViewDataSource, RCConnectionStatusChangeDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RCRoomListPresenter *presenter;
@property (nonatomic, assign) BOOL isIMConnected;

@end

static NSString * const roomCellIdentifier = @"RCRoomListCell";
@implementation RCRoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频直播";
    
    [self buildLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![LoginBridge isLogin]) {
        self.isIMConnected = NO;
        RCLoginViewController *loginVC = [RCLoginViewController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        return ;
    }
    
    NSString *suffixString = [[LoginBridge userDefaultsSavedMobile] substringFromIndex:7];
    self.title = [NSString stringWithFormat:@"直播列表-%@", suffixString];
    
    if (!self.isIMConnected) {
        [self initIMWithToken:[LoginBridge userDefaultsSavedToken]];
        return ;
    }
    
    [self refresh];
}

- (void)refresh {
    [self.presenter fetchRoomListWithCompletionBlock:^(BOOL success) {
        if (!success) {
            return ;
        }
        [self.tableView reloadData];
    }];
}


- (void)buildLayout {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [LoginBridge userDefaultsSavedName];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"开始直播"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(createRoom)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)createRoom {
    [VideoRoomBridge createRoomFromVC:self.navigationController];
}

#pragma mark - im connection
- (void)initIMWithToken:(NSString *)token {
    [[RCIMClient sharedRCIMClient] initWithAppKey:[AppConfigs getRCKey]];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    [[RCIMClient sharedRCIMClient] connectWithToken:token timeLimit:5
    dbOpened:^(RCDBErrorCode code) {
        //消息数据库打开，可以进入到主页面
        if (code == RCDBOpenSuccess) {
            NSLog(@"login success,db open success");
        } else {
            NSLog(@"login success, db open failed");
        }
    } success:^(NSString *userId) {

        NSLog(@"IMClient connect success");
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"login_success_msg"];
            self.isIMConnected = YES;
            [self refresh];
        });
    
    } error:^(RCConnectErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == RC_CONN_TOKEN_INCORRECT) {
                //token 非法，从 APP 服务获取新 token，并重连
                NSLog(@"need refresh im token");
            } else if(status == RC_CONNECT_TIMEOUT) {
                //连接超时，弹出提示，可以引导用户等待网络正常的时候再次点击进行连接
                [SVProgressHUD showErrorWithStatus:@"network_time_out"];
            } else {
                //无法连接 IM 服务器，请根据相应的错误码作出对应处理
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ code: %ld",@"network_error",(long)status]];
            }
            
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ code: %ld",@"login_fail_msg",(long)status]];
        });
        
    }];
}

#pragma mark - UITabelView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presenter.dataModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    RoomListRoomModel *room = self.presenter.dataModels[indexPath.row];
    [cell updateCellWithName:room.roomName roomId:room.roomId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomListRoomModel *room = self.presenter.dataModels[indexPath.row];
    [VideoRoomBridge joinVoiceRoomWithRoomId:room.roomId fromVC:self.navigationController];
}

#pragma mark - RCConnectionStatusChangeDelegate
/// IMLib连接状态的的监听器
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    switch (status) {
        case ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            [LoginBridge logout];
            break;
            
        default:
            break;
    }
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 220;
        [_tableView registerClass:[RCRoomListCell class] forCellReuseIdentifier:roomCellIdentifier];
    }
    return _tableView;
}

- (RCRoomListPresenter *)presenter {
    if (!_presenter) {
        _presenter = [RCRoomListPresenter new];
    }
    return _presenter;
}

@end
