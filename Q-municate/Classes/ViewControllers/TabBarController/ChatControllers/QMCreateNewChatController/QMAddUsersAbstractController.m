//
//  QMAddUsersAbstractController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddUsersAbstractController.h"
#import "QMInviteFriendsCell.h"
#import "QMUsersService.h"

@interface QMAddUsersAbstractController ()

@property (weak, nonatomic) IBOutlet UIButton *performButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QMAddUsersAbstractController

- (id)initWithChatDialog:(QBChatDialog *)chatDialog {
    
    if (self = [super init]) {
        self.selectedFriends = [NSMutableArray array];
        
#warning me.iD
#warning QMContactList shared
        //        _friendsSelectedMArray = [NSMutableArray new];
        //
        //        NSArray *unsortedUsers = [[QMContactList shared].friendsAsDictionary allValues];
        //        NSMutableArray *sortedUsers = [self sortUsersByFullname:unsortedUsers];
        //
        //        NSMutableArray *usersToDelete = [NSMutableArray new];
        //        for (NSString *participantID in chatDialog.occupantIDs) {
        //
        //            QBUUser *user = [QMContactList shared].friendsAsDictionary[participantID];
        //            if (user != nil) {
        //                [usersToDelete addObject:user];
        //            }
        //        }
        //        [sortedUsers removeObjectsInArray:usersToDelete];
        //
        //        _friendListArray = sortedUsers;
    }
    return self;
}

- (NSMutableArray *)sortUsersByFullname:(NSArray *)users
{
    NSArray *sortedUsers = nil;
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    return [sortedUsers mutableCopy];
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurePerformButtonBorder];
    [self updateNavTitle];
    [self applyChangesForPerformButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Configurations

- (void)updateNavTitle {
    
    self.title  = [NSString stringWithFormat:@"%d Selected", self.selectedFriends.count];
}

- (void)configurePerformButtonBorder {
    
    self.performButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.performButton.layer.borderWidth = 0.5;
}

- (void)applyChangesForPerformButton {
    
    [self.performButton setEnabled:!self.selectedFriends.count == 0];
}

#pragma mark - Actions

/** Override this methods */
- (IBAction)performAction:(id)sender
{
   CHECK_OVERRIDE();
}

- (IBAction)cancelSelection:(id)sender {
    
    if ([self.selectedFriends count] > 0) {
        [self.selectedFriends removeAllObjects];
        
        [self updateNavTitle];
        [self applyChangesForPerformButton];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMInviteFriendsCell *cell = (QMInviteFriendsCell *) [tableView dequeueReusableCellWithIdentifier:kCreateChatCellIdentifier];
    QBUUser *friend = self.friends[indexPath.row];
    [cell configureCellWithParamsForQBUser:friend checked:[self.selectedFriends containsObject:friend]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBUUser *checkedUser = self.friends[indexPath.row];
    
    if ([self.selectedFriends containsObject:checkedUser]) {
        [self.friends removeObject:checkedUser];
    } else {
        [self.friends addObject:checkedUser];
    }

    // update navigation title:
    [self updateNavTitle];
    
	[self applyChangesForPerformButton];
	[self.tableView reloadData];
}

@end
