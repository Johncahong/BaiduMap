//
//  ViewController.m
//  集成百度地图
//
//  Created by Hello Cai on 2022/2/15.
//

#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入POI检索相关头文件
#import <BMKLocationKit/BMKLocationComponent.h>//引入定位相关的头文件

@interface ViewController ()<BMKPoiSearchDelegate,BMKLocationManagerDelegate>
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong)UITextField *textfield;
@property (nonatomic, strong)BMKPoiSearch *poiSearch;

@property (nonatomic, strong) BMKLocationManager *locationManager; //当前位置对象，用于定位
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象，用于在地图上标出蓝色圈
@property (nonatomic, strong) UIView *operateView;
@end

@implementation ViewController

//BMKMapView的生命周期
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //地图视图
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_mapView];
    //显示定位图层
    _mapView.showsUserLocation = YES;
    
    [self buildOperationView];
    
    //定位
    [self location];
}

-(void)buildOperationView{
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 50)];
    [self.view addSubview:operateView];
    self.operateView = operateView;
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, self.view.bounds.size.width-150, 40)];
    textfield.text = @"小吃";
    textfield.backgroundColor = [UIColor whiteColor];
    [self.operateView addSubview:textfield];
    self.textfield = textfield;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-75, textfield.frame.origin.y, 60, 40)];
    [btn setTitle:@"poi检索" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.operateView addSubview:btn];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.operateView.alpha = self.operateView.alpha==1?0:1;
}

//代码来自百度定位文档
-(void)location{
    //单此定位
//    BMKLocationManager  *locationManager = [[BMKLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
//    locationManager.pausesLocationUpdatesAutomatically = NO;
//    locationManager.allowsBackgroundLocationUpdates = YES;
//    locationManager.locationTimeout = 10;
//    locationManager.reGeocodeTimeout = 10;
//
//    [locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
//             //获取经纬度和该定位点对应的位置信息
//    }];
    

    //连续定位
    BMKLocationManager *locationManager = [[BMKLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.allowsBackgroundLocationUpdates = NO;// YES的话是可以进行后台定位的，但需要项目配置，否则会报错，具体参考开发文档
    locationManager.locationTimeout = 10;
    locationManager.reGeocodeTimeout = 10;
    self.locationManager = locationManager;
    
    //开始定位
    [locationManager startUpdatingLocation];
}

//POI检索
-(void)btnClick:(UIButton *)button{
    if (self.userLocation.location == nil) {
        NSLog(@"当前位置为空");
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //POI周边（圆形区域）检索
    //初始化请求参数类BMKNearbySearchOption的实例
    BMKPOINearbySearchOption *nearbyOption = [[BMKPOINearbySearchOption alloc] init];
    //检索关键字，必选
    NSString *keyword = self.textfield.text;
    nearbyOption.keywords = @[keyword];
    //检索中心点的经纬度，必选
//    nearbyOption.location = CLLocationCoordinate2DMake(40.051231, 116.282051);
    nearbyOption.location = self.userLocation.location.coordinate;
    //检索半径，单位是米。
    nearbyOption.radius = 1000;
    //是否严格限定召回结果在设置检索半径范围内。默认值为false。
    nearbyOption.isRadiusLimit = NO;
    //POI检索结果详细程度
    //nearbyOption.scope = BMK_POI_SCOPE_BASIC_INFORMATION;
    //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
    //nearbyOption.filter = filter;
    //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
    nearbyOption.pageIndex = 0;
    //单次召回POI数量，默认为10条记录，最大返回20条。
    nearbyOption.pageSize = 10;
    
    BOOL flag = [self.poiSearch poiSearchNearBy:nearbyOption];
    if (flag) {
        NSLog(@"POI周边检索成功");
    } else {
        NSLog(@"POI周边检索失败");
    }
}

#pragma mark - BMKLocationManagerDelegate
//由于以下代理方法中分别且仅只返回heading或location信息，请开发者务必将该对象定义为全局类型，避免在以下回调用使用局部的BMKUserLocation对象，导致出现定位显示错误位置的情况。
/**
*  @brief 连续定位回调函数。
*  @param manager 定位 BMKLocationManager 类。
*  @param location 定位结果，参考BMKLocation。
*  @param error 错误信息。
*/
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error{
    if (error) {
        NSLog(@"连续定位error:%@", error);
        return;
    }
    if (!location) {
        return;
    }
    
    CLLocationCoordinate2D corordinate = location.location.coordinate;
    NSLog(@"纬度:%.3f, 经度:%.3f", corordinate.latitude, corordinate.longitude);
    
    self.userLocation.location = location.location;
    [_mapView updateLocationData:self.userLocation];
    
    //设置地图显示区域，以当前位置为坐标
    //精度半径（值越小，地图显示的越详细具体）
    BMKCoordinateSpan span = BMKCoordinateSpanMake(0.02, 0.02);
    _mapView.region = BMKCoordinateRegionMake(corordinate, span);
}


/**
* @brief 该方法为BMKLocationManager提供设备朝向的回调方法。
* @param manager 提供该定位结果的BMKLocationManager类的实例
* @param heading 设备的朝向结果
*/
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateHeading:(CLHeading * _Nullable)heading{
    
    if (!heading) {
        return;
    }
    
    self.userLocation.heading = heading;
    [_mapView updateLocationData:self.userLocation];
}



#pragma mark - BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误码，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    //BMKSearchErrorCode错误码，BMK_SEARCH_NO_ERROR：检索结果正常返回
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
//        NSLog(@"检索结果返回成功：%@",poiResult.poiInfoList);
        for (BMKPoiInfo *poiInfo in poiResult.poiInfoList) {
            NSLog(@"name:%@, address:%@", poiInfo.name, poiInfo.address);
            
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            annotation.coordinate = poiInfo.pt;
            annotation.title = poiInfo.name;
            annotation.subtitle = poiInfo.address;
            [self.mapView addAnnotation:annotation];
        }
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD) {
        NSLog(@"检索词有歧义");
    } else {
        NSLog(@"其他检索结果错误码相关处理");
    }
}

#pragma mark - 懒加载
-(BMKPoiSearch *)poiSearch{
    if (!_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return _poiSearch;
}

-(BMKUserLocation *)userLocation{
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}
@end
