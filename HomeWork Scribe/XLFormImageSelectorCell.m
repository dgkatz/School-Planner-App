//
//  XLFormImageSelectorCell.m
//  
//
//  Created by Daniel Katz on 5/13/15.
//
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIView+XLFormAdditions.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "XLFormImageSelectorCell.h"
#import "dataClass.h"

NSString *const kFormImageSelectorCellDefaultImage = @"defaultImage";
NSString *const kFormImageSelectorCellImageRequest = @"imageRequest";

@interface XLFormImageSelectorCell() <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) UIImage * defaultImage;
@property (nonatomic) NSURLRequest * imageRequest;

@end

@implementation XLFormImageSelectorCell{
    CGFloat _imageHeight;
    CGFloat _imageWidth;
}
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;


#pragma mark - XLFormDescriptorCell


- (void)configure
{
    [super configure];
    _imageHeight = 100.0f;
    _imageWidth = 100.0f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.separatorInset = UIEdgeInsetsZero;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.textLabel];
    [self addLayoutConstraints];
    [self.textLabel addObserver:self forKeyPath:@"image note" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    
}

- (void)update
{
    self.textLabel.text = self.rowDescriptor.title;
    self.imageView.image = self.rowDescriptor.value ?: self.defaultImage;
    if (self.imageRequest && !self.rowDescriptor.value){
        __weak __typeof(self) weakSelf = self;
        [self.imageView setImageWithURLRequest:self.imageRequest
                              placeholderImage:self.defaultImage
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           if (!weakSelf.rowDescriptor.value && image){
                                               [weakSelf.imageView setImage:image];
                                           }
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //NSLog(@"Failed to download image");
                                       }];
    }
}


+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    return 120.0f;
}

-(void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.rowDescriptor.selectorTitle delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Choose Existing Photo", @"Choose Existing Photo"), NSLocalizedString(@"Take A Photo", @"Take a Picture"), nil];
    actionSheet.tag = self.tag;
    [actionSheet showInView:self.formViewController.view];
}

#pragma mark - LayoutConstraints

-(void)addLayoutConstraints
{
    NSDictionary *uiComponents = @{ @"image" : self.imageView,
                                    @"text"  : self.textLabel};
    
    NSDictionary *metrics = @{@"margin":@5.0};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[text]" options:0 metrics:metrics views:uiComponents]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[text]" options:0 metrics:metrics views:uiComponents]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:-10.0f]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[image(width)]" options:0 metrics:@{ @"width" : @(_imageWidth) } views:uiComponents]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
}


-(void)setImageValue:(UIImage *)image
{
    self.rowDescriptor.value = image;
    self.imageView.image = image;
    dataClass *obj = [dataClass getInstance];
    obj.assignmentImage = [UIImage imageNamed:@"pencil.png"];
}

-(void)updateConstraints
{
    
    [super updateConstraints];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.textLabel && [keyPath isEqualToString:@"text"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            [self.contentView needsUpdateConstraints];
        }
    }
}

-(void)dealloc
{
   // [self.textLabel addObserver:self forKeyPath:@"image note" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
    [self.textLabel removeObserver:self forKeyPath:@"image note"];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    if (buttonIndex == 0){
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        [self.formViewController presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if (buttonIndex == 1){
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        [self.formViewController presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dataClass *obj = [dataClass getInstance];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        // ensure the user has taken a picture
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToUse = editedImage;
        }
        else {
            imageToUse = originalImage;
        }
        [self setImageValue:imageToUse];
    }
    obj.assignmentImage = [UIImage imageNamed:@"pencil.png"];
    
    [self.formViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Properties

-(UIImageView *)imageView
{
    //dataClass *obj = [dataClass getInstance];
    if (_imageView) return _imageView;
    _imageView = [UIImageView autolayoutView];
    _imageView.layer.masksToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.cornerRadius = _imageHeight / 2.0;
    //obj.assignmentImage = _imageView;
    return _imageView;
}

-(UILabel *)textLabel
{
    if (_textLabel) return _textLabel;
    _textLabel = [UILabel autolayoutView];
    return _textLabel;
}


-(void)setDefaultImage:(UIImage *)defaultImage
{
    _defaultImage = defaultImage;
}


-(void)setImageRequest:(NSURLRequest *)imageRequest
{
    _imageRequest = imageRequest;
}


@end