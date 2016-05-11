//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMColors.h"
#import "QMUpdateUserViewController.h"
#import "QMNotification.h"
#import "REActionSheet.h"
#import "QMImagePicker.h"
#import "QMTasks.h"
#import "QMCore.h"
#import "QMProfile.h"
#import <QMImageView.h>

typedef NS_ENUM(NSUInteger, QMSettingsSection) {
    
    QMSettingsSectionFullName,
    QMSettingsSectionUserInfo,
    QMSettingsSectionStatus,
    QMSettingsSectionExtra,
    QMSettingsSectionSocial,
    QMSettingsSectionLogout
};

typedef NS_ENUM(NSUInteger, QMUserInfo) {
    
    QMUserInfoPhone,
    QMUserInfoEmail
};

@interface QMSettingsViewController ()

<
QMProfileDelegate,
QMImageViewDelegate,
QMImagePickerResultHandler
>

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) BFTask *subscribeTask;
@property (weak, nonatomic) BFTask *logoutTask;

@end

@implementation QMSettingsViewController

+ (instancetype)settingsViewController {
    
    return [[UIStoryboard storyboardWithName:kQMSettingsStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure user data
    [self configureUserData:[QMCore instance].currentProfile.userData];
    self.pushNotificationSwitch.on = [QMCore instance].currentProfile.pushNotificationsEnabled;
    
    // subscribe to delegates
    [QMCore instance].currentProfile.delegate = self;
    self.avatarImageView.delegate = self;
}

- (void)configureUserData:(QBUUser *)userData {
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:userData.avatarUrl]
                              placeholder:[UIImage imageNamed:@"upic_avatarholder"]
                                  options:SDWebImageHighPriority
                                 progress:nil
                           completedBlock:nil];
    
    self.fullNameLabel.text = userData.fullName;
    
    self.phoneLabel.text = userData.phone.length > 0 ? userData.phone : NSLocalizedString(@"QM_STR_NONE", nil);
    
    self.emailLabel.text = userData.email.length > 0 ? userData.email : NSLocalizedString(@"QM_STR_NONE", nil);
    
    self.statusLabel.text = userData.status.length > 0 ? userData.status : NSLocalizedString(@"QM_STR_NONE", nil);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUpdateUser]) {
        
        QMUpdateUserViewController *updateUserVC = segue.destinationViewController;
        updateUserVC.updateUserField = [sender unsignedIntegerValue];
    }
}

- (IBAction)pushNotificationSwitchPressed:(UISwitch *)sender {
    
    if (self.subscribeTask) {
        // task is in progress
        return;
    }
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) timeUntilDismiss:0];
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
        
        [QMNotification dismissNotificationPanel];
        
        return nil;
    };
    
    if (sender.isOn) {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager subscribeForPushNotifications] continueWithBlock:completionBlock];
    }
    else {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager unSubscribeFromPushNotifications] continueWithBlock:completionBlock];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
            
        case QMSettingsSectionFullName:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldFullName)];
            break;
            
        case QMSettingsSectionUserInfo: {
            
            switch (indexPath.row) {
                    
                case QMUserInfoPhone:
                    break;
                    
                case QMUserInfoEmail:
                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldEmail)];
                    break;
            }
            
            break;
        }
            
        case QMSettingsSectionStatus:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldStatus)];
            break;
            
        case QMSettingsSectionExtra:
            break;
            
        case QMSettingsSectionSocial:
            break;
            
        case QMSettingsSectionLogout:
            
            if (self.logoutTask) {
                // task is in progress
                return;
            }
            
            [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) timeUntilDismiss:0];
            
            self.logoutTask = [[[QMCore instance] logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                
                [QMNotification dismissNotificationPanel];
                [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                return nil;
            }];

            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionFullName) {
        
        return [super tableView:tableView viewForHeaderInSection:section];
    }
    
    QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                            initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(tableView.frame),
                                                                     40.0f)];
    
    if (section == QMSettingsSectionStatus) {
        
        headerView.title = @"STATUS";
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionFullName) {
        
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    
    if (section == QMSettingsSectionStatus) {
        
        return 40.0f;
    }
    
    return 24.0f;
}

#pragma mark - QMProfileDelegate

- (void)profile:(QMProfile *)__unused currentProfile didUpdateUserData:(QBUUser *)userData {
    
    [self configureUserData:userData];
}

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    @weakify(self);
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        @strongify(self);
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil) andActionBlock:^{
            [QMImagePicker takePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil) andActionBlock:^{
            [QMImagePicker choosePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{
            
        }];
    }];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) timeUntilDismiss:0];
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUserImage:photo progress:nil] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        [self.avatarImageView setImage:photo withKey:task.result.avatarUrl];
        
        [QMNotification dismissNotificationPanel];
        
        return nil;
    }];
}

@end