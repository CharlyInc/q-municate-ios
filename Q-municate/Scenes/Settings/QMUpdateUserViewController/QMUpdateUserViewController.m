//
//  QMUpdateUserViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUpdateUserViewController.h"
#import "QMCore.h"
#import "QMProfile.h"
#import "QMColors.h"
#import "QMShadowView.h"
#import "QMTasks.h"
#import "QMNotification.h"

@interface QMUpdateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (copy, nonatomic) NSString *bottomText;
@property (weak, nonatomic) BFTask *task;

@end

@implementation QMUpdateUserViewController

- (void)viewDidLoad {
    NSAssert(_updateUserField != QMUpdateUserFieldNone, @"Must be a valid update field.");
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure appearance
    [self configureAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)configureAppearance {
    
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    
    switch (self.updateUserField) {
            
        case QMUpdateUserFieldFullName:
            [self configureWithKeyPath:@keypath(QBUUser.new, fullName)
                                 title:NSLocalizedString(@"QM_STR_FULLNAME", nil)
                                  text:currentUser.fullName
                            bottomText:NSLocalizedString(@"QM_STR_FULLNAME_DESCRIPTION", nil)];
            break;
            
        case QMUpdateUserFieldEmail:
            [self configureWithKeyPath:@keypath(QBUUser.new, email)
                                 title:NSLocalizedString(@"QM_STR_EMAIL", nil)
                                  text:currentUser.email
                            bottomText:NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil)];
            break;
            
        case QMUpdateUserFieldStatus:
            [self configureWithKeyPath:@keypath(QBUUser.new, status)
                                 title:NSLocalizedString(@"QM_STR_STATUS", nil)
                                  text:currentUser.status
                            bottomText:NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil)];
            break;
            
        case QMUpdateUserFieldNone:
            break;
    }
}

- (void)configureWithKeyPath:(NSString *)keyPath
                       title:(NSString *)title
                        text:(NSString *)text
                  bottomText:(NSString *)bottomText {
    
    self.keyPath = keyPath;
    self.title =
    self.textField.placeholder = title;
    self.cachedValue =
    self.textField.text = text;
    self.bottomText = bottomText;
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.task != nil) {
        // task is in progress
        return;
    }
    
    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    [updateUserParams setValue:self.textField.text forKeyPath:self.keyPath];
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) timeUntilDismiss:0];
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUser:updateUserParams] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
        
        @strongify(self);
        [QMNotification dismissNotificationPanel];
        [self.navigationController popViewControllerAnimated:YES];
        
        return nil;
    }];
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = ![sender.text isEqualToString:self.cachedValue];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView titleForFooterInSection:(NSInteger)__unused section {
    
    switch (self.updateUserField) {
            
        case QMUpdateUserFieldFullName:
            return NSLocalizedString(@"QM_STR_FULLNAME_DESCRIPTION", nil);
            
        case QMUpdateUserFieldEmail:
            return NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil);
            
        case QMUpdateUserFieldStatus:
            return NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil);
            
        case QMUpdateUserFieldNone:
            return nil;
            break;
    }
}

@end