//
//  TUILiveAnchorPKListView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/16.
//

#import "TUILiveAnchorPKListView.h"
#import "TRTCLiveRoomDef.h"
#import "Masonry.h"
#import "SDWebImage.h"

@interface TUILiveAnchorPKCell ()

@property(nonatomic, strong) UIImageView *coverImage;
@property(nonatomic, strong) UILabel *inviteLabel;
@property(nonatomic, strong) UILabel *infoLabel;


@end

@implementation TUILiveAnchorPKCell {
    BOOL _isViewReady;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self constructSubViews];
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    _isViewReady = YES;
}

- (void)constructSubViews {
    self.coverImage = [[UIImageView alloc] init];
    self.coverImage.layer.cornerRadius = 20;
    self.coverImage.layer.masksToBounds = YES;
    
    self.inviteLabel = [[UILabel alloc] init];
    self.inviteLabel.text = @"邀请";
    self.inviteLabel.textAlignment = NSTextAlignmentCenter;
    self.inviteLabel.userInteractionEnabled = YES;
    self.inviteLabel.textColor = UIColor.whiteColor;
    self.inviteLabel.backgroundColor = [UIColor colorWithRed:0.0 green:98.0 / 255 blue:227 / 255.0 alpha:1.0];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textColor = UIColor.whiteColor;
    self.infoLabel.font = [UIFont systemFontOfSize:15.0];
    self.infoLabel.numberOfLines = 2;
}

- (void)constructViewHierarchy {
    [self addSubview:self.coverImage];
    [self addSubview:self.inviteLabel];
    [self addSubview:self.infoLabel];
}

- (void)layoutUI {
    [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self).offset(10);
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(-10);
        make.width.mas_equalTo(40);
    }];
    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-15);
        make.right.equalTo(self).offset(-20);
        make.width.mas_equalTo(75);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverImage.mas_trailing).offset(5);
        make.top.equalTo(self).offset(5);
        make.bottom.trailing.equalTo(self).offset(-5);
    }];
}

- (void)configWithModel:(TRTCLiveRoomInfo *)model {
    if ([model.coverUrl isEqualToString:@""]) {
        NSURL *tempUrl = [NSURL URLWithString:@"https://imgcache.qq.com/qcloud/public/static//avatar0_100.20191230.png"];
        [self.coverImage sd_setImageWithURL:tempUrl];
    } else {
        [self.coverImage sd_setImageWithURL:[NSURL URLWithString:model.coverUrl]];
    }
    self.infoLabel.text = [NSString stringWithFormat:@"%@\n%@", model.ownerName, model.roomName];
}

@end

@interface TUILiveAnchorPKListView ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSArray<TRTCLiveRoomInfo *> *roomInfos;
@property(nonatomic, strong)UITableView *anchorTableView;

@end

@implementation TUILiveAnchorPKListView{
    BOOL _isViewReady;
}

- (UITableView *)anchorTableView {
    if (!_anchorTableView) {
        _anchorTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_anchorTableView registerClass:[TUILiveAnchorPKCell class] forCellReuseIdentifier:@"TUILiveAnchorPKCell"];
        _anchorTableView.delegate = self;
        _anchorTableView.dataSource = self;
        _anchorTableView.separatorColor = UIColor.clearColor;
        _anchorTableView.allowsSelection = YES;
        _anchorTableView.backgroundColor = UIColor.clearColor;
    }
    return _anchorTableView;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    self->_isViewReady = YES;
}

- (void)constructViewHierarchy {
    [self addSubview:self.anchorTableView];
}

- (void)layoutUI {
    [self.anchorTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.width.equalTo(self);
        make.height.equalTo(self);
    }];
}

- (void)showWithRoomInfos:(NSArray<TRTCLiveRoomInfo *> *)infos {
    [self refreshRoomInfos:infos];
    self.hidden = NO;
}

- (void)refreshRoomInfos:(NSArray<TRTCLiveRoomInfo *> *)infos {
    self.roomInfos = infos;
    [self.anchorTableView reloadData];
}

- (void)hide {
    self.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = UIColor.clearColor;
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
        footer.textLabel.textColor = UIColor.whiteColor;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.roomInfos.count > 0) {
        return @" ";
    }
    return @"暂无主播";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUILiveAnchorPKCell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[TUILiveAnchorPKCell class]]) {
        TUILiveAnchorPKCell *pkCell = (TUILiveAnchorPKCell *)cell;
        if (indexPath.row < self.roomInfos.count) {
            TRTCLiveRoomInfo *info = self.roomInfos[indexPath.row];
            [pkCell configWithModel:info];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < self.roomInfos.count) {
        TRTCLiveRoomInfo *info = self.roomInfos[indexPath.row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pkListView:didSelectRoom:)]) {
            [self.delegate pkListView:self didSelectRoom:info];
        }
    }
    [self hide];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.frame = CGRectMake(0, 40, tableView.bounds.size.width, 50);
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"PK邀请";
    headerLabel.textColor = UIColor.whiteColor;
    headerLabel.backgroundColor = [UIColor colorWithRed:19.0 / 255.0 green:35.0 / 255.0 blue:63.0 / 255.0 alpha:1.0];
    headerLabel.userInteractionEnabled = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(self.bounds.size.width * 4.0 / 5.0, 0, self.bounds.size.width / 5.0, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = UIColor.clearColor;
    [cancelBtn addTarget:self action:@selector(hidePanel:) forControlEvents:UIControlEventTouchUpInside];
    [headerLabel addSubview:cancelBtn];
    
    return headerLabel;
}

- (void)hidePanel:(UIButton *)sender {
    [self hide];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pkListViewDidHidden:)]) {
        [self.delegate pkListViewDidHidden:self];
    }
}

@end
