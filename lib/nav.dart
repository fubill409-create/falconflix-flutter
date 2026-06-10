import 'package:flutter/widgets.dart';

/// 全局路由观察者。首页视频流用它感知「被别的页面盖住 / 重新露出」，
/// 以便 push 别的页面（AI 玩法 / 播放页 / 详情）时暂停首页视频，避免后台还出声。
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

/// 首页 Tab 是否当前可见。底部导航切 Tab 时立刻置位（不依赖 IndexedStack/PageView
/// 的离屏重建时序），首页视频流监听它，离开首页即暂停，避免后台残留出声。
final ValueNotifier<bool> homeTabActive = ValueNotifier<bool>(true);
