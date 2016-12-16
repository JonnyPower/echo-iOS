//
//  MessagePresenceView.m
//  Echo
//
//  Created by Jonny Power on 02/12/2016.
//  Copyright © 2016 JonnyPower. All rights reserved.
//

#import "MessagePresenceView.h"
#import "MessagePresenceEntryView.h"

@interface MessagePresenceView ()

@property NSMapTable<NSNumber*, MessagePresenceEntryView*>* idToEntryView;
@property UIScrollView *entryScrollView;
@property UIView *contentView;
@property MessagePresenceEntryView *lastEntryView;

@end

CGFloat const PRESENCE_VIEW_HEIGHT = 30.0f;
int const ENTRY_FADE_TIME_SECONDS = 15;
CGFloat const ENTRY_PADDING = 5.0f;

@implementation MessagePresenceView

@synthesize lastEntryView;
@synthesize entryScrollView;
@synthesize contentView;
@synthesize idToEntryView;

- (instancetype)init {
    self = [super init];
    
    if(self) {
        [self setTranslatesAutoresizingMaskIntoConstraints: NO];
        self.idToEntryView = [NSMapTable strongToStrongObjectsMapTable];
        
        NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem: self
                                                                            attribute: NSLayoutAttributeHeight
                                                                            relatedBy: NSLayoutRelationEqual
                                                                               toItem: nil
                                                                            attribute: NSLayoutAttributeNotAnAttribute
                                                                           multiplier: 1.0f
                                                                             constant: PRESENCE_VIEW_HEIGHT];
        [self addConstraint: constraintHeight];
        
        [self setBackgroundColor:[UIColor colorWithWhite: 0.95f alpha: 1.0f]];
        
        contentView = [[UIView alloc] init];
        [contentView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        entryScrollView = [[UIScrollView alloc] init];
        [self addSubview: entryScrollView];
        [entryScrollView setUserInteractionEnabled: YES];
        [entryScrollView setTranslatesAutoresizingMaskIntoConstraints: NO];
        [entryScrollView addSubview: contentView];
        
        NSLayoutConstraint *contraintContentHeight = [NSLayoutConstraint constraintWithItem: contentView
                                                                                 attribute: NSLayoutAttributeHeight
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: entryScrollView
                                                                                 attribute: NSLayoutAttributeHeight
                                                                                multiplier: 1.0f
                                                                                   constant: 0.0f];
        NSLayoutConstraint *constraintContentWidth = [NSLayoutConstraint constraintWithItem: contentView
                                                                                 attribute: NSLayoutAttributeWidth
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: entryScrollView
                                                                                 attribute: NSLayoutAttributeWidth
                                                                                multiplier: 1.0f
                                                                                  constant: 0.0f];
        NSLayoutConstraint *constraintContentX = [NSLayoutConstraint constraintWithItem: contentView
                                                                              attribute: NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem: entryScrollView
                                                                              attribute: NSLayoutAttributeCenterX
                                                                             multiplier: 1.0f
                                                                               constant:0.0f];
        
        NSLayoutConstraint *constraintContentY = [NSLayoutConstraint constraintWithItem: contentView
                                                                             attribute: NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem: entryScrollView
                                                                             attribute: NSLayoutAttributeCenterY
                                                                            multiplier: 1.0f
                                                                              constant:0.0f];
        
        [entryScrollView addConstraints:@[constraintContentX, constraintContentY, contraintContentHeight, constraintContentWidth]];
        
        NSLayoutConstraint *constraintScrollHeight = [NSLayoutConstraint constraintWithItem: entryScrollView
                                                                                  attribute: NSLayoutAttributeHeight
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: self
                                                                                  attribute: NSLayoutAttributeHeight
                                                                                 multiplier: 1.0f
                                                                                   constant: 0.0f];
        NSLayoutConstraint *constraintScrollWidth = [NSLayoutConstraint constraintWithItem: entryScrollView
                                                                                 attribute: NSLayoutAttributeWidth
                                                                                 relatedBy: NSLayoutRelationEqual
                                                                                    toItem: self
                                                                                 attribute: NSLayoutAttributeWidth
                                                                                multiplier: 1.0f
                                                                                  constant: 0.0f];
        NSLayoutConstraint *constraintScrollBottom = [NSLayoutConstraint constraintWithItem: entryScrollView
                                                                                  attribute: NSLayoutAttributeBottom
                                                                                  relatedBy: NSLayoutRelationEqual
                                                                                     toItem: self
                                                                                  attribute: NSLayoutAttributeBottom
                                                                                 multiplier: 1.0f
                                                                                   constant: 0.0f];
        
        NSLayoutConstraint *constraintScrollX = [NSLayoutConstraint constraintWithItem:entryScrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:1.0f];
        
        [self addConstraints:@[constraintScrollHeight, constraintScrollX, constraintScrollWidth, constraintScrollBottom]];
    }
    
    return self;
}

- (void)removePresenceEntryView:(MessagePresenceEntryView*)entryView {
    if(entryView && ![entryView online]) {
        BOOL removeLastEntry = entryView.next == nil;
        if(removeLastEntry) {
            self.lastEntryView = entryView.previous;
            entryView.previous.next = nil;
        } else {
            entryView.next.previous = entryView.previous;
            BOOL removingFirstEntry = entryView.previous == nil;
            if(removingFirstEntry) {
                [self.contentView removeConstraint: [self findXConstraintForEntryView:entryView.next]];
                [self.contentView addConstraint:[self newXConstraintForEntryView: entryView.next]];
            } else {
                entryView.previous.next = entryView.next;
            }
        }
        [self.idToEntryView removeObjectForKey: entryView.participant.id];
        [entryView removeFromSuperview];
    }
}

- (void)participantJoined:(Participant *)joined {
    MessagePresenceEntryView *existing = [self.idToEntryView objectForKey:joined.id];
    if(!existing) {
        [self addEntryViewForParticipant: joined];
    } else {
        [existing setOnline:YES];
    }
}

- (void)participantLeft:(Participant *)left {
    MessagePresenceEntryView *entryView = [self.idToEntryView objectForKey: left.id];
    [entryView setOnline: NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ENTRY_FADE_TIME_SECONDS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removePresenceEntryView: entryView];
    });
}

- (void)participantsReset {
    for(MessagePresenceEntryView *entryView in [idToEntryView objectEnumerator]){
        [entryView removeFromSuperview];
    }
    self.idToEntryView = [NSMapTable strongToStrongObjectsMapTable];
    self.lastEntryView = nil;
}

- (NSLayoutConstraint*)newXConstraintForEntryView:(MessagePresenceEntryView*)entryView {
    if(entryView.previous) {
        return [NSLayoutConstraint constraintWithItem: entryView
                                            attribute: NSLayoutAttributeLeft
                                            relatedBy: NSLayoutRelationEqual
                                               toItem: entryView.previous
                                            attribute: NSLayoutAttributeRight
                                           multiplier: 1.0f
                                             constant: ENTRY_PADDING];
    } else {
        return [NSLayoutConstraint constraintWithItem: entryView
                                            attribute: NSLayoutAttributeLeft
                                            relatedBy: NSLayoutRelationEqual
                                               toItem: entryView.superview
                                            attribute: NSLayoutAttributeLeft
                                           multiplier: 1.0f
                                             constant: ENTRY_PADDING];
    }
}

- (NSLayoutConstraint*)findXConstraintForEntryView:(MessagePresenceEntryView*)entryView {
    NSArray<NSLayoutConstraint*> *contraints = [self.contentView constraints];
    for(NSLayoutConstraint *constraint in contraints) {
        if([constraint.firstItem isEqual: entryView]
           && constraint.firstAttribute == NSLayoutAttributeLeft) {
            return constraint;
        }
    }
    return nil;
}

- (void)addEntryViewForParticipant:(Participant*)participant {
    MessagePresenceEntryView *entryView = [[MessagePresenceEntryView alloc] initWithPrevious: self.lastEntryView
                                                                                 participant: participant];
    [self.contentView addSubview: entryView];
    
    if(entryView.previous) {
        entryView.previous.next = entryView;
    }
    
    [self.idToEntryView setObject: entryView forKey: participant.id];
    
    NSLayoutConstraint *constraintXEntryView = [self newXConstraintForEntryView:entryView];
    
    NSLayoutConstraint *constraintYEntryView = [NSLayoutConstraint constraintWithItem: entryView
                                                                            attribute: NSLayoutAttributeCenterY
                                                                            relatedBy: NSLayoutRelationEqual
                                                                               toItem: contentView
                                                                            attribute: NSLayoutAttributeCenterY
                                                                           multiplier: 1.0f
                                                                             constant: 0.0f];
    [self.contentView addConstraints: @[constraintXEntryView, constraintYEntryView]];
    self.lastEntryView = entryView;
}

@end