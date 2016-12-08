//
//  MessagingViewController.m
//  Echo
//
//  Created by Jonny Power on 05/05/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "AppDelegate.h"
#import "MessagingViewController.h"
#import "MessageCell.h"
#import "MessageTableView.h"
#import "MessageTextFieldView.h"

#import "Participant.h"

@interface MessagingViewController ()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property int lookbackDays;
@property NSIndexPath* insertedIndexPath;

@end

@implementation MessagingViewController

@synthesize webSocketClient;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize refreshControl;
@synthesize lookbackDays;
@synthesize textEmpty;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if(self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *logoutBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"‹ Logout"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:appDelegate
                                                                               action:@selector(logout)];
        [logoutBarButtonItem setTintColor:[UIColor whiteColor]];
        [[self navigationItem] setLeftBarButtonItem: logoutBarButtonItem];
    }
    
    [self.view becomeFirstResponder];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchView)];
    [self.view addGestureRecognizer:recognizer];
    
    MessageTableView *tableView = ((MessageTableView*)self.tableView);
    tableView.messageTextFieldView.delegate = self;
    [webSocketClient addPresenceDelegate:tableView.messagePresenceView];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
                                              inManagedObjectContext:managedObjectContext];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sent" ascending:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:managedObjectContext
                                              sectionNameKeyPath:@"dayString"
                                                       cacheName:@"Messages"];
    fetchedResultsController.delegate = self;
    
    
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(actionHistroy:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [self updateRefreshControlLabel];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [webSocketClient addDelegate: self];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    [self.tableView reloadData];
    if([[self.fetchedResultsController sections] count]>0){
        [self.textEmpty setHidden: YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [webSocketClient removeDelegate: self];
}

- (void)didTouchView {
    [self.view becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionLogout:(id)sender {
    NSLog(@"actionLogout: %@", [sender description]);
}

- (void)actionHistroy:(id)sender {
    lookbackDays++;
    [webSocketClient messageHistory: lookbackDays];
}

- (void)messageHistoryFinished {
    [refreshControl endRefreshing];
    [self updateRefreshControlLabel];
    [self.tableView reloadData];
    [self scrollToTop];
}

- (void)updateRefreshControlLabel {
    NSDate *lookbackDate = [[NSDate date] dateByAddingTimeInterval:0-(60*60*24*(lookbackDays+1))];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:lookbackDate
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pull to get messages for %@", dateString] attributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)sendMessage:(NSString *)content {
    [webSocketClient pushMessage: content];
}

- (void)scrollToBottom {
    if ([[self.fetchedResultsController sections] count]) {
        NSInteger section = [[self.fetchedResultsController sections] count]-1;
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        NSInteger rows = [sectionInfo numberOfObjects];
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:rows inSection:section];
        [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)scrollToTop {
    if ([[self.fetchedResultsController sections] count]) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *dayLabel = [[UILabel alloc] init];
    [dayLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    [dayLabel setFont: [UIFont systemFontOfSize:10]];
    [dayLabel setTextColor:[UIColor lightGrayColor]];
    [dayLabel setTextAlignment:NSTextAlignmentCenter];
    [dayLabel setText: [self tableView:tableView titleForHeaderInSection:section]];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:dayLabel];
    
    NSLayoutConstraint *constraintDayLabelHeight = [NSLayoutConstraint constraintWithItem: dayLabel
                                                                                attribute: NSLayoutAttributeHeight
                                                                                relatedBy: NSLayoutRelationEqual
                                                                                   toItem: nil
                                                                                attribute: NSLayoutAttributeNotAnAttribute
                                                                               multiplier: 1.0f
                                                                                 constant: 20.0f];
    NSLayoutConstraint *constraintDayLabelWidth = [NSLayoutConstraint constraintWithItem: dayLabel
                                                                               attribute: NSLayoutAttributeWidth
                                                                               relatedBy: NSLayoutRelationEqual
                                                                                  toItem: headerView
                                                                               attribute: NSLayoutAttributeWidth
                                                                              multiplier: 1.0f
                                                                                constant: 0.0f];
    NSLayoutConstraint *constraintDayLabelCenterY = [NSLayoutConstraint constraintWithItem: dayLabel
                                                                                 attribute: NSLayoutAttributeCenterY
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: headerView
                                                                                 attribute: NSLayoutAttributeCenterY
                                                                                multiplier: 1.0f
                                                                                  constant: 0.0f];
    [headerView addConstraints:@[constraintDayLabelWidth, constraintDayLabelHeight, constraintDayLabelCenterY]];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo>  sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"messageCell";
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [fetchedResultsController objectAtIndexPath:indexPath];
    Participant *from = message.from;
    
    MessageCell *messageCell = (MessageCell*)cell;
    [messageCell setBackgroundColor:[UIColor clearColor]];
    [messageCell.textDeviceName setText: from.name];
    [messageCell.textMessageContent setText: message.content];
    
    NSString *imageString = [NSString stringWithFormat:@"%@_icon", from.type];
    [messageCell.deviceImage setImage:[UIImage imageNamed:imageString]];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:message.sent
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    [messageCell.textSent setText:dateString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [fetchedResultsController objectAtIndexPath:indexPath];
    CGRect messageBoundingRect = [message.content boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 40, 0)
                                                               options:(NSStringDrawingUsesLineFragmentOrigin)
                                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]}
                                                               context:nil];
    return ceilf(messageBoundingRect.size.height + 58);
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.insertedIndexPath = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    if([[self.fetchedResultsController sections] count]>0){
        [self.textEmpty setHidden: YES];
    }
    if (self.insertedIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.insertedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        self.insertedIndexPath = nil;
    }
}

@end
