//
//  ViewController.m
//  JOpenGLGraphic
//
//  Created by jiang on 2025/9/17.
//

//ViewControllers
#import "ViewController.h"

//Views
#import "JGLView.h"

//Category
#import "UIButton+Block.h"
#import "UIView+Block.h"

#define ChoiceBtnWidth 55
#define ChoiceBtnHeight 30
#define ChoiceBtnBottom 30
#define ChoiceBtnTitle @"选择"
#define PickerViewHeight 299
#define CancelTitle @"取消"
#define OkTitle @"确定"
#define OkBtnWidth 55
#define OkBtnHeight 30
#define CancelBtnWidth 55
#define CancelBtnHeight 30

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) self = weakSelf;


@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) JGLView *glView;//OpenGL视图
@property (nonatomic, strong) UIButton *choiceBtn;//选择绘制图元类型按钮

@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, strong) UIPickerView *pickerView;//选择器视图
@property (nonatomic, strong) UIButton *cancelBtn;//取消按钮
@property (nonatomic, strong) UIButton *okBtn;//确定按钮
@property (nonatomic, assign) JGLViewDrawType type;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, assign) BOOL isAnimate;
 
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

-(void)initUI{
    //添加OpenGL视图
    [self.view addSubview:self.glView];
    [self.view addSubview:self.choiceBtn];
    [self addGesture];
    
    self.pickerContainer.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-PickerViewHeight, CGRectGetWidth(self.view.frame), PickerViewHeight);
}

//添加手势
-(void)addGesture{
    WeakSelf
    [self.view addGestureBlock:^(UIGestureRecognizer * _Nonnull gestureRecognizer) {
        StrongSelf
        [self hiddenPicker];
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;
    self.choiceBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0 - ChoiceBtnWidth/2.0, CGRectGetHeight(self.view.frame) - ChoiceBtnHeight - ChoiceBtnBottom, ChoiceBtnWidth, ChoiceBtnHeight);
    if(_pickerContainer && !self.isAnimate){
        _pickerContainer.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-PickerViewHeight, CGRectGetWidth(self.view.frame), PickerViewHeight);
        _pickerView.frame = CGRectMake(0, 0, CGRectGetWidth(_pickerContainer.frame), CGRectGetHeight(_pickerContainer.frame));
        self.cancelBtn.frame = CGRectMake(16, 9, CancelBtnWidth, CancelBtnHeight);
        self.okBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - OkBtnWidth - 16, 9, OkBtnWidth, OkBtnHeight);
    }
}

#pragma mark - UIPickerViewDataSource&UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.titles.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row < self.titles.count){
        return [self.titles objectAtIndex:row];
    }
    return @"";
}

#pragma mark - PickerView
//显示选择视图
-(void)showPicker{
    [self.view addSubview:self.pickerContainer];
    self.pickerContainer.transform = CGAffineTransformMakeTranslation(0, PickerViewHeight);
    self.isAnimate = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerContainer.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        self.isAnimate = NO;
    }];
}

//隐藏选择视图
-(void)hiddenPicker{
    if(_pickerContainer){
        self.isAnimate = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.pickerContainer.transform = CGAffineTransformMakeTranslation(0, PickerViewHeight);
        }completion:^(BOOL finished) {
            [self.pickerContainer removeFromSuperview];
            self.pickerContainer.transform = CGAffineTransformIdentity;
            self.isAnimate = NO;
        }];
    }
}

#pragma mark - setter&getter
//图层
-(JGLView *)glView{
    if(!_glView){
        JGLView *glView = [[JGLView alloc] initWithFrame:self.view.bounds];
        _glView = glView;
    }
    return _glView;
}

-(UIView *)pickerContainer{
    if(!_pickerContainer){
        _pickerContainer = [[UIView alloc] init];
        [_pickerContainer addSubview:self.pickerView];
        [_pickerContainer addSubview:self.cancelBtn];
        [_pickerContainer addSubview:self.okBtn];
    }
    return _pickerContainer;
}

//选择按钮
-(UIButton *)choiceBtn{
    if(!_choiceBtn){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:ChoiceBtnTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        WeakSelf
        [btn addTouchActionBlock:^(NSInteger tag) {
            StrongSelf
            [self showPicker];
        }];
        _choiceBtn = btn;
    }
    return _choiceBtn;
}

//确定按钮
-(UIButton *)okBtn{
    if(!_okBtn){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:OkTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        WeakSelf
        [btn addTouchActionBlock:^(NSInteger tag) {
            StrongSelf
            self.glView.type = [self.pickerView selectedRowInComponent:0];
            [self hiddenPicker];
        }];
        _okBtn = btn;
    }
    return _okBtn;
}

//取消按钮
-(UIButton *)cancelBtn{
    if(!_cancelBtn){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:CancelTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        WeakSelf
        [btn addTouchActionBlock:^(NSInteger tag) {
            StrongSelf
            [self hiddenPicker];
        }];
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

-(UIPickerView *)pickerView{
    if(!_pickerView){
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-PickerViewHeight, CGRectGetWidth(self.view.frame), PickerViewHeight)];
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        _pickerView = pickerView;
    }
    return _pickerView;
}

-(NSArray *)titles{
    return @[@"点",@"线(Lines)",@"线(Line_Strip)",@"线(Line_Loop)",@"三角形(Triangle)",@"三角形(Triangle_Strip)",@"三角形(Triangle_Loop)"];
}

@end
