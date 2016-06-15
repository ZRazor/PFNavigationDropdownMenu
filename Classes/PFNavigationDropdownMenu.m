 //
//  PFNavigationDropdownMenu.m
//  PFNavigationDropdownMenu
//
//  Created by Cee on 02/08/2015.
//  Copyright (c) 2015 Cee. All rights reserved.
//

#import "PFNavigationDropdownMenu.h"
#import "PFTableView.h"

@interface PFNavigationDropdownMenu()
@property (nonatomic, strong) UIView *tableContainerView;
@property (nonatomic, strong) PFConfiguration *configuration;
@property (nonatomic, assign) CGRect mainScreenBounds;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UILabel *menuTitle;
@property (nonatomic, strong) UIImageView *menuArrow;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) PFTableView *tableView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) BOOL isShown;
@property (nonatomic, assign) BOOL containerViewScrollEnabled;
@property (nonatomic, assign) CGFloat navigationBarHeight;
@end

@implementation PFNavigationDropdownMenu

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        items:(NSArray *)items
                containerView:(UIView *)containerView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Init properties
        self.configuration = [[PFConfiguration alloc] init];
        self.tableContainerView = containerView;
        self.navigationBarHeight = 44;
        self.mainScreenBounds = [UIScreen mainScreen].bounds;
        self.isShown = NO;
        self.items = items;

        // Init button as navigation title
        self.menuButton = [[UIButton alloc] initWithFrame:frame];
        [self.menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.menuButton];
        
        [self.menuButton setTitle:title forState:UIControlStateNormal];
        [self.menuButton setImage:self.configuration.arrowImage forState:UIControlStateNormal];
        
        self.menuButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.menuButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.menuButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);

        // Init table view
        self.tableView = [[PFTableView alloc] initWithFrame:CGRectMake(self.mainScreenBounds.origin.x,
                        self.mainScreenBounds.origin.y,
                        self.mainScreenBounds.size.width,
                        self.mainScreenBounds.size.height + 300 - 64)
                                                      items:items
                                              configuration:self.configuration];
        [self.tableView setAlwaysBounceVertical:self.configuration.bounceVertical];
        __weak typeof(self) weakSelf = self;
        self.tableView.selectRowAtIndexPathHandler = ^(NSUInteger indexPath){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.didSelectItemAtIndexHandler(indexPath);
            [strongSelf setMenuTitleText:items[indexPath]];
            [strongSelf hideMenu];
            strongSelf.isShown = NO;
            [strongSelf layoutSubviews];
        };

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.menuTitle sizeToFit];
    self.menuTitle.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
    [self.menuArrow sizeToFit];
    self.menuArrow.center = CGPointMake(CGRectGetMaxX(self.menuTitle.frame) + self.configuration.arrowPadding, self.frame.size.height / 2.f);
}

- (void)showMenu
{
    if ([self.tableContainerView isKindOfClass:[UIScrollView class]]) {
        self.containerViewScrollEnabled = ((UIScrollView *)self.tableContainerView).scrollEnabled;
        [(UIScrollView *)self.tableContainerView setScrollEnabled:NO];
    }
    // Table view header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 300)];
    headerView.backgroundColor = self.configuration.cellBackgroundColor;
    self.tableView.tableHeaderView = headerView;

    // Reload data to dismiss highlight color of selected cell
    [self.tableView reloadData];

    // Init background view (under table view)
    self.backgroundView = [[UIView alloc] initWithFrame:self.mainScreenBounds];
    self.backgroundView.backgroundColor = self.configuration.maskBackgroundColor;

    // Add background view & table view to container view
    [self.tableContainerView addSubview:self.backgroundView];
    [self.tableContainerView addSubview:self.tableView];


    // Change background alpha
    self.backgroundView.alpha = 0;

    // Animation
    NSUInteger cellsCount = self.items.count;
    if (self.hideSelectedCell) {
        cellsCount--;
    }
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
            -(CGFloat)(cellsCount) * self.configuration.cellHeight - 300,
            self.tableView.frame.size.width,
            self.tableView.frame.size.height);

    [UIView animateWithDuration:self.configuration.animationDuration * 1.5f
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.5
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                 -300,
                                 self.tableView.frame.size.width,
                                 self.tableView.frame.size.height);
                         self.backgroundView.alpha = self.configuration.maskBackgroundOpacity;
//                         [self.menuButton.imageView setTransform:CGAffineTransformMakeRotation(0)];

                     }
                     completion:nil];
}

- (void)hideMenu
{
    if ([self.tableContainerView isKindOfClass:[UIScrollView class]]) {
        [(UIScrollView *)self.tableContainerView setScrollEnabled:self.containerViewScrollEnabled];
    }

    // Change background alpha
    self.backgroundView.alpha = self.configuration.maskBackgroundOpacity;

    [UIView animateWithDuration:self.configuration.animationDuration * 1.5f
                          delay:0
         usingSpringWithDamping:.7
          initialSpringVelocity:.5
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                 -200,
                                 self.tableView.frame.size.width,
                                 self.tableView.frame.size.height);
                         self.backgroundView.alpha = self.configuration.maskBackgroundOpacity;
//                         [self.menuButton.imageView setTransform:CGAffineTransformMakeRotation(M_PI)];

                     }
                     completion:nil];

    NSUInteger cellsCount = self.items.count;
    if (self.hideSelectedCell) {
        cellsCount--;
    }
    [UIView animateWithDuration:self.configuration.animationDuration
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                 -(CGFloat)(cellsCount) * self.configuration.cellHeight - 300,
                                 self.tableView.frame.size.width,
                                 self.tableView.frame.size.height);
                         self.backgroundView.alpha = 0;
                     } completion:^(BOOL finished) {
                [self.tableView removeFromSuperview];
                [self.backgroundView removeFromSuperview];
            }];

}

- (void)rotateArrow
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.configuration.animationDuration
                     animations:^{
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         strongSelf.menuButton.imageView.transform = CGAffineTransformRotate(strongSelf.menuButton.imageView.transform, 180 * (CGFloat)(M_PI / 180));
                     } completion:^(BOOL finished){
                         [self.menuButton setUserInteractionEnabled:YES];
                     }];
}

- (void)setMenuTitleText:(NSString *)title
{
    [self.menuButton setTitle:title forState:UIControlStateNormal];
}

- (void)menuButtonTapped:(UIButton *)sender
{
    self.isShown = !self.isShown;
    [self.menuButton setUserInteractionEnabled:NO];
    if (self.isShown) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
    [self rotateArrow];
}

#pragma mark - Setters
- (void)setCellHeight:(CGFloat)cellHeight
{
    self.configuration.cellHeight = cellHeight;
}

- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    self.configuration.cellBackgroundColor = cellBackgroundColor;
}

- (void)setCellTextLabelColor:(UIColor *)cellTextLabelColor
{
    self.configuration.cellTextLabelColor = cellTextLabelColor;
}

- (void)setCellTextLabelFont:(UIFont *)cellTextLabelFont
{
    self.configuration.cellTextLabelFont = cellTextLabelFont;
    self.menuTitle.font = self.configuration.cellTextLabelFont;
}

- (void)setCellSelectionColor:(UIColor *)cellSelectionColor
{
    self.configuration.cellSelectionColor = cellSelectionColor;
}

- (void)setCheckMarkImage:(UIImage *)checkMarkImage
{
    self.configuration.checkMarkImage = checkMarkImage;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    self.configuration.animationDuration = animationDuration;
}

- (void)setArrowImage:(UIImage *)arrowImage
{
    self.configuration.arrowImage = arrowImage;
    self.menuArrow.image = self.configuration.arrowImage;
}

- (void)setArrowPadding:(CGFloat)arrowPadding
{
    self.configuration.arrowPadding = arrowPadding;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor
{
    self.configuration.maskBackgroundColor = maskBackgroundColor;
}

- (void)setMaskBackgroundOpacity:(CGFloat)maskBackgroundOpacity
{
    self.configuration.maskBackgroundOpacity = maskBackgroundOpacity;
}

- (void)setMenuTitleColor:(UIColor *)menuTitleColor
{
    self.configuration.menuTitleColor = menuTitleColor;
    self.menuTitle.textColor = self.configuration.menuTitleColor;
}

- (void)setHideSelectedCell:(BOOL)hideSelectedCell
{
    self.configuration.hideSelectedCell = hideSelectedCell;
    [self.tableView reloadData];
}

- (void)setBounceVertical:(BOOL)bounceVertical
{
    self.configuration.bounceVertical = bounceVertical;
    [self.tableView setAlwaysBounceVertical:self.configuration.bounceVertical];
}

@end
