# ── flutter_stripe / Stripe Android：release R8 收缩规则 ──
# 我们只用 PaymentSheet 充值，不用 Stripe 把卡发进 Google Pay 钱包(push provisioning / TapAndPay)。
# 那条用不到的代码路径会引用下面这些类；R8 收缩时它们不在包内，仅产生“缺失引用”告警，明确忽略即可。
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.**

# TapAndPay(Google Pay 发卡)是合作方专用库、公网 Maven 取不到，已在 build.gradle 排除；
# 插件里只走反射(Class.forName)用它，运行时我们也从不触发，忽略其缺失告警。
-dontwarn com.google.android.gms.tapandpay.**
