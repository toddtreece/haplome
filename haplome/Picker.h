
#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

@interface Picker : UIView {

@private
	UILabel* _haplomeNameLabel;
	BrowserViewController* _bvc;
}

@property (nonatomic, assign) id<BrowserViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString* haplomeName;

- (id)initWithFrame:(CGRect)frame type:(NSString *)type;

@end
