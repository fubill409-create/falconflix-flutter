// 法律文件内容（6 语）：隐私政策 + 用户协议。GDPR 对齐的全球标准基线。
// ⚠️ 这是专业级草稿（Claude 起草），上线前请由律师审阅各属地条款。
//    ja/ko/ar/fr 为功能级法律翻译，建议母语 + 律师双审。
// 主体：FALCONFLIX-SINGAPORE-TECH PTE. LTD.（新加坡）｜联系：support@falconflix.app
//
// TermsScreen / PrivacyScreen 按当前 App 语言取对应版本，缺失回退英文。

class LegalDocData {
  final String title;
  final String updated; // 最近更新
  final String intro;
  final List<List<String>> sections; // [ [小标题, 段落...], ... ]
  const LegalDocData({required this.title, required this.updated, required this.intro, required this.sections});
}

const String _kUpdated = '2026-06-10';

LegalDocData privacyDoc(String lang) => _privacy[lang] ?? _privacy['en']!;
LegalDocData termsDoc(String lang) => _terms[lang] ?? _terms['en']!;

// ════════════════════════ 隐私政策 ════════════════════════
const Map<String, LegalDocData> _privacy = {
  'en': LegalDocData(
    title: 'Privacy Policy',
    updated: _kUpdated,
    intro:
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD. (the “Company”, “we”, “us”) operates the FalconFlix application and related services (“FalconFlix” or the “Service”). '
        'This Privacy Policy explains what personal information we collect, how we use, share, transfer and protect it, and the rights you have. '
        'It applies to all users worldwide. Please read it carefully before using the Service.',
    sections: [
      [
        '1. Who We Are',
        'The data controller is FALCONFLIX-SINGAPORE-TECH PTE. LTD., a company incorporated in Singapore. '
            'For any privacy question or to exercise your rights, contact us at support@falconflix.app.',
        'For any privacy matter, or to exercise your rights under the EU/UK GDPR or other applicable laws, contact us at support@falconflix.app. Where the law later requires us to designate a Data Protection Officer or an EU/UK representative, we will identify them in this Policy.',
      ],
      [
        '2. Information We Collect',
        'Account information: when you register or sign in, we collect your email address, or the unique identifier and basic profile returned by a third-party sign-in you authorize (Google, Apple), and the nickname and avatar you set.',
        'Usage and device information: to provide and improve the Service, we collect your viewing and interaction history, favorites, search terms, and technical data such as device model, operating system, app version, language, approximate region, IP address and crash logs.',
        'Transaction information: when you purchase Eagle Coins, payment is processed by our third-party processor Stripe. We do not store your full card number; we keep only the order number, amount and payment status needed for reconciliation and support.',
        'Communications: if you contact support or submit feedback, we keep the content of your messages to respond and improve the Service.',
      ],
      [
        '3. How We Use Your Information and Legal Bases',
        'We use your information to: provide and maintain the Service and your account (performance of a contract); personalize recommendations and remember your preferences (our legitimate interests, or your consent where required); process top-ups and deliver virtual benefits (performance of a contract); keep the account and platform secure and prevent fraud and abuse (legitimate interests and legal obligations); respond to your enquiries and complaints; and comply with applicable laws (legal obligation).',
        'Where we rely on consent, you may withdraw it at any time without affecting prior processing.',
      ],
      [
        '4. How We Share and Disclose Information',
        'We do not sell your personal information. We share only what is necessary, with: (a) service providers that perform functions on our behalf, such as payment (Stripe), cloud hosting, push notifications and analytics; (b) authorities or third parties where required to comply with law, enforce our terms, or protect the rights and safety of users; and (c) a successor entity in connection with a merger, acquisition or sale of assets, subject to this Policy.',
      ],
      [
        '5. International Data Transfers',
        'FalconFlix is a global Service operated from Singapore. Your information may be stored and processed on servers in one or more countries outside your own, and the hosting location may change as our infrastructure evolves. Service providers acting on our behalf (such as Stripe, Google and Apple) may also process certain data in the United States and other countries.',
        'Where information is transferred out of the EEA, the United Kingdom, the Republic of Korea, Japan or other regions that restrict cross-border transfers, we rely on a lawful transfer mechanism — such as the European Commission’s Standard Contractual Clauses or your explicit consent — together with appropriate supplementary safeguards. You may request further information about these safeguards at support@falconflix.app.',
      ],
      [
        '6. Data Retention',
        'We keep your personal information only for as long as necessary for the purposes described in this Policy, or as required by law. '
            'Account data is retained while your account is active and for a reasonable period afterwards; transaction records are kept for the period required by applicable accounting and tax laws. '
            'When information is no longer needed, we delete or anonymize it.',
      ],
      [
        '7. How We Protect Your Information',
        'We use reasonable technical and organizational measures, including encryption in transit and access controls, to protect your personal information against unauthorized access, disclosure or loss. '
            'No method of transmission or storage is completely secure, and we cannot guarantee absolute security.',
      ],
      [
        '8. Your Rights',
        'Subject to applicable law, you have the right to access, correct, update or delete your personal information; to restrict or object to certain processing; to data portability; and to withdraw consent at any time. '
            'You can exercise many of these directly in the app under Settings → Account & Security (including account deletion and data export), or by contacting support@falconflix.app.',
        'If you are in the EEA or the United Kingdom, you also have the right to lodge a complaint with your local data protection supervisory authority.',
      ],
      [
        '9. Children',
        'FalconFlix is intended for adults (18 years or older) and contains mature dramatic content. '
            'We do not knowingly collect personal information from children. If you believe a child has provided us with personal information, please contact support@falconflix.app and we will delete it.',
      ],
      [
        '10. Cookies, SDKs and Similar Technologies',
        'We and our service providers use device identifiers and software development kits (SDKs) — for example for analytics, crash reporting and push notifications — to operate, secure and improve the Service. '
            'You can control push notifications and some tracking through your device settings.',
      ],
      [
        '11. Region-Specific Notices',
        'Where local law grants you additional rights or requires specific disclosures — including under the EU/UK GDPR, Japan’s Act on the Protection of Personal Information (APPI), the Republic of Korea’s Personal Information Protection Act (PIPA), Saudi Arabia’s Personal Data Protection Law (PDPL) and the United Arab Emirates’ Federal Decree-Law No. 45 of 2021 — we honor those rights and provide those disclosures in the localized version of this Policy. '
            'Please contact support@falconflix.app to exercise your rights, and we will respond as required by the applicable law.',
      ],
      [
        '12. Changes to This Policy',
        'We may update this Privacy Policy from time to time. We will post the updated version in the Service and update the “Last updated” date, and will notify you of material changes by more prominent means.',
      ],
      [
        '13. Contact Us',
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app. If you have any question about this Policy or our handling of your information, please reach out and we will be glad to help.',
      ],
    ],
  ),
  'zh': LegalDocData(
    title: '隐私政策',
    updated: _kUpdated,
    intro:
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD.（以下简称“本公司”“我们”）运营 FalconFlix 应用及相关服务（以下简称“本服务”或“FalconFlix”）。'
        '本《隐私政策》说明我们收集哪些个人信息、如何使用、共享、传输与保护这些信息，以及您所享有的权利。本政策适用于全球用户，请您在使用前仔细阅读。',
    sections: [
      [
        '一、我们是谁',
        '数据控制者为在新加坡注册成立的 FALCONFLIX-SINGAPORE-TECH PTE. LTD.。'
            '如有任何隐私问题或需行使您的权利，请通过 support@falconflix.app 与我们联系。',
      ],
      [
        '二、我们收集的信息',
        '账号信息：当您注册或登录时，我们会收集您的邮箱地址，或经您授权的第三方登录（Google、Apple）所返回的唯一标识与基础资料，以及您设置的昵称、头像等。',
        '使用与设备信息：为提供与改进服务，我们会收集您的观看与互动记录、收藏、搜索关键词，以及设备型号、操作系统、应用版本、语言、大致地区、IP 地址、崩溃日志等技术信息。',
        '交易信息：当您充值鹰币时，支付由第三方支付机构 Stripe 处理。我们不会存储您完整的银行卡号，仅保留订单号、金额、支付状态等对账与客服所必需的记录。',
        '沟通信息：当您联系客服或提交反馈时，我们会保留您的消息内容，用于回复与改进服务。',
      ],
      [
        '三、我们如何使用信息及合法性依据',
        '我们使用上述信息用于：提供并维护服务与您的账号（履行合同）；进行个性化推荐与记住您的偏好（基于我们的正当利益，或在法律要求时基于您的同意）；完成充值与权益发放（履行合同）；保障账号与平台安全、防范欺诈与滥用（正当利益与法律义务）；响应您的咨询与投诉；以及履行适用法律规定的义务（法律义务）。',
        '在我们以您的同意为依据时，您可随时撤回同意，且不影响撤回前的处理。',
      ],
      [
        '四、信息的共享与披露',
        '我们不会出售您的个人信息。仅在必要范围内共享，对象包括：（1）代表我们履行职能的服务提供商，如支付（Stripe）、云存储、消息推送与数据分析；（2）为遵守法律、执行我们的条款或保护用户权利与安全而依法要求的机关或第三方；（3）在合并、收购或资产出售情形下的承继主体，并受本政策约束。',
      ],
      [
        '五、跨境数据传输',
        'FalconFlix 面向全球，由新加坡主体运营。您的信息可能存储与处理于您所在国家或地区以外的一个或多个国家的服务器上，且随着我们基础设施的演进，托管地点可能发生变化；代表我们处理数据的服务提供商（如 Stripe、Google、Apple）也可能在美国等国家处理部分数据。'
            '当信息自欧洲经济区、英国、韩国、日本或其他限制跨境传输的地区向外传输时，我们将依据合法的传输机制——例如欧盟委员会的标准合同条款（SCC）或您的明确同意——并辅以适当的补充保护措施。您可通过 support@falconflix.app 索取有关这些保护措施的进一步信息。',
      ],
      [
        '六、信息的保留期限',
        '我们仅在实现本政策所述目的所必需的期间内，或在法律要求的期间内保留您的个人信息。'
            '账号数据在您的账号存续期间及其后合理期间内保留；交易记录按适用的会计与税务法律所要求的期限保留。当信息不再需要时，我们会予以删除或匿名化。',
      ],
      [
        '七、我们如何保护您的信息',
        '我们采用合理的技术与组织措施，包括传输加密与访问控制，保护您的个人信息免遭未经授权的访问、披露或损毁。'
            '但任何传输或存储方式都无法做到绝对安全，我们无法保证信息的绝对安全。',
      ],
      [
        '八、您的权利',
        '在适用法律范围内，您有权访问、更正、更新或删除您的个人信息，限制或反对某些处理，要求数据可携，以及随时撤回同意。'
            '其中许多操作您可直接在 App 内「设置 → 账号与安全」完成（包括注销账号与导出数据），或通过 support@falconflix.app 联系我们。',
        '若您位于欧洲经济区或英国，您还有权向当地的数据保护监管机构投诉。',
      ],
      [
        '九、未成年人',
        'FalconFlix 面向成年人（18 周岁及以上），包含成人向的剧情内容。'
            '我们不会在知情情况下收集未成年人的个人信息。若您认为有未成年人向我们提供了个人信息，请通过 support@falconflix.app 联系我们，我们将予以删除。',
      ],
      [
        '十、Cookie、SDK 及类似技术',
        '我们及服务提供商会使用设备标识符与软件开发工具包（SDK）——例如用于数据分析、崩溃报告与消息推送——以运营、保护并改进本服务。'
            '您可通过设备设置控制推送通知及部分跟踪。',
      ],
      [
        '十一、属地特别说明',
        '在当地法律赋予您额外权利或要求特定披露的情况下——包括欧盟/英国《通用数据保护条例》（GDPR）、日本《个人信息保护法》（APPI）、韩国《个人信息保护法》（PIPA）、沙特《个人数据保护法》（PDPL）、阿联酋 2021 年第 45 号联邦法令等——我们将在本政策对应语言版本中尊重这些权利并作出相应披露。'
            '请通过 support@falconflix.app 行使您的权利，我们将按适用法律的要求予以回应。',
      ],
      [
        '十二、本政策的更新',
        '我们可能不时更新本隐私政策。更新后将在本服务内公布并更新“最近更新”日期；对于重大变更，我们会以更显著的方式通知您。',
      ],
      [
        '十三、联系我们',
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD.——support@falconflix.app。如您对本政策或我们处理信息的方式有任何疑问，欢迎与我们联系。',
      ],
    ],
  ),
  'ja': LegalDocData(
    title: 'プライバシーポリシー',
    updated: _kUpdated,
    intro:
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD.（以下「当社」）は、FalconFlix アプリ及び関連サービス（以下「本サービス」）を運営します。'
        '本プライバシーポリシーは、日本の個人情報保護法（APPI）その他適用法令に従い、当社が取り扱う個人情報の項目・利用目的・第三者提供・外国移転・安全管理、及びお客様の権利について説明します。ご利用前に必ずお読みください。',
    sections: [
      ['1. 事業者情報', '個人情報取扱事業者：FALCONFLIX-SINGAPORE-TECH PTE. LTD.（シンガポールで設立。以下「当社」）。本サービスの個人情報に関するお問い合わせ窓口：support@falconflix.app。'],
      ['2. 取得する個人情報', 'アカウント情報：登録・ログイン時のメールアドレス、又はお客様が許可した第三者ログイン（Google、Apple）から返される識別子・基本プロフィール、設定したニックネーム・アイコン。', '利用・端末情報：視聴・操作履歴、お気に入り、検索語、端末モデル、OS、アプリ版数、言語、おおよその地域、IP アドレス、クラッシュログ等。', '取引情報：イーグルコイン購入時、決済は第三者 Stripe が処理し、当社はカード番号全体を保存せず、照合・サポートに必要な注文番号・金額・決済状況のみを保持します。', 'お問い合わせ情報：サポート連絡・フィードバックの内容。'],
      ['3. 利用目的', '当社は取得した個人情報を、次の利用目的の範囲で取り扱います：本サービス及びアカウントの提供・本人認証・維持；ショートドラマの配信及び AI キャラクターとの対話機能の提供；イーグルコインのチャージ（Stripe による米ドル決済）及び特典付与；視聴体験のレコメンド・個別化及び設定の記憶；18 歳以上であることの確認及び年齢制限の運用；不正・なりすまし・不正利用の防止及びセキュリティの確保；お問い合わせ・苦情への対応；サービスの改善及び統計分析；法令上の義務の履行。利用目的を変更する場合は、関連性を有すると合理的に認められる範囲で行い、本ポリシーで通知します。'],
      ['4. 第三者提供', '当社は、法令に基づく場合等を除き、あらかじめご本人の同意なく個人データを第三者に提供しません。なお、利用目的の達成に必要な範囲で、決済・クラウド・プッシュ通知・分析等の業務を外部に委託することがあり、この場合は委託先に対して必要かつ適切な監督を行います（委託は第三者提供には当たりません）。'],
      ['5. 外国にある第三者への提供・外的環境の把握', '本サービスは全世界向けであり、お客様の個人データは、お住まいの国・地域以外の国にあるサーバー及び委託先（例：決済の Stripe、Google、Apple は米国等）で保存・処理される場合があります。当社のインフラ変更に伴い、保存先の国は変動し得ます。', '外国にある第三者へ個人データを提供するにあたり、当社は、移転先の国名、当該国の個人情報保護制度に関する情報、及び提供先が講ずる措置を確認のうえ、法令に従い、必要な場合にはあらかじめご本人の同意を取得します。お客様の個人データが外国のサーバーに保存される場合、当社は当該外国の制度を把握したうえで安全管理措置を講じます（外的環境の把握）。各国の制度については個人情報保護委員会の公表資料（https://www.ppc.go.jp/）もご参照ください。'],
      ['6. 保有個人データの開示等の請求', 'お客様は、当社の保有個人データについて、利用目的の通知、開示（電磁的記録の提供を含む）、訂正・追加・削除、利用停止・消去、第三者提供の停止を請求できます。ご請求は support@falconflix.app で受け付けます。当社はご本人であることを確認のうえ、法令に従い遅滞なく対応します。開示等の請求には、法令の認める範囲で手数料を申し受ける場合があります。'],
      ['7. 保存期間', '当社は、利用目的の達成に必要な期間、又は法令で求められる期間に限り個人データを保持します。アカウントデータは利用中及び終了後の合理的な期間、取引記録は会計・税務法令が求める期間保持し、不要となった情報は削除又は匿名化します。'],
      ['8. 安全管理措置', '当社は、組織的・人的・技術的・物理的な安全管理措置（社内規程の整備、従業者の監督、アクセス権限の管理、通信の暗号化等）を講じ、個人データの漏えい・滅失・毀損の防止に努めます。外的環境（外国での保存）も踏まえて対応します。'],
      ['9. Cookie・SDK 等の技術', '当社及び提供事業者は、分析・クラッシュ報告・プッシュ通知等のために端末識別子や SDK を利用し、本サービスを運営・保護・改善します。プッシュ通知及び一部のトラッキングは端末設定で制御できます。'],
      ['10. 未成年者', 'FalconFlix は 18 歳以上の方を対象とし、成人向けのドラマ内容を含みます。未成年者が利用する場合は法定代理人の同意が必要です。当社は未成年者の個人情報を故意に収集せず、判明した場合は削除します。'],
      ['11. 漏えい等への対応', '個人データの漏えい・滅失・毀損であって個人の権利利益を害するおそれが大きいものが生じた場合、当社は法令に従い、個人情報保護委員会への報告及びご本人への通知を行います。'],
      ['12. 苦情・お問い合わせ窓口', '当社の個人情報の取扱いに関する苦情・ご相談は support@falconflix.app までお申し出ください。適切かつ迅速な処理に努めます。'],
      ['13. 本ポリシーの変更', '当社は本ポリシーを随時変更することがあります。変更後は本サービス内に掲示し「最終更新日」を更新し、重要な変更はより目立つ方法で通知します。'],
    ],
  ),
  'ko': LegalDocData(
    title: '개인정보 처리방침',
    updated: _kUpdated,
    intro:
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD.(이하 "회사")는 FalconFlix 앱 및 관련 서비스(이하 "서비스")를 운영합니다. '
        '본 개인정보 처리방침은 대한민국 「개인정보 보호법」(PIPA) 등 관련 법령에 따라 회사가 처리하는 개인정보의 항목·목적·보유기간·제3자 제공·위탁·국외 이전·파기 및 이용자의 권리를 설명합니다. 이용 전에 반드시 읽어 주시기 바랍니다.',
    sections: [
      ['1. 수집하는 개인정보 항목 및 방법', '계정 정보: 이메일 주소, 또는 이용자가 동의한 제3자 로그인(Google, Apple)이 반환하는 식별자·기본 프로필, 설정한 닉네임·아바타.', '이용·기기 정보: 시청·상호작용 기록, 즐겨찾기, 검색어, 기기 모델, 운영체제, 앱 버전, 언어, 대략적 지역, IP 주소, 오류 로그.', '거래 정보: 이글 코인 충전 시 결제는 제3자 Stripe가 처리하며, 전체 카드번호는 저장하지 않고 주문번호·금액·결제 상태만 보관합니다.', '수집 방법: 이용자의 직접 입력, 서비스 이용 과정에서의 자동 생성·수집, 제3자 로그인 제공자로부터의 수신.'],
      ['2. 개인정보의 처리 목적', '회사는 ① 서비스·계정 제공 및 본인 인증·유지 ② 숏드라마 스트리밍 및 AI 캐릭터 상호작용 제공 ③ 이글 코인 충전(Stripe, 미국 달러 결제) 및 혜택 지급 ④ 추천 개인화 및 설정 기억 ⑤ 만 18세 이상 여부 확인 및 연령 제한 운영 ⑥ 부정 이용 방지 및 보안 ⑦ 문의·민원 응대 ⑧ 서비스 개선 및 통계 ⑨ 법령상 의무 이행을 위하여 개인정보를 처리합니다.'],
      ['3. 처리 및 보유 기간', '회사는 처리 목적 달성에 필요한 기간 또는 법령이 정한 기간 동안 개인정보를 보유합니다. 계정 정보는 회원 탈퇴 시까지(관계 법령에 따른 보존 의무가 있는 경우 해당 기간), 거래·결제 기록은 전자상거래 등 관련 법령이 정한 기간(예: 계약·청약철회·대금결제 기록 5년, 소비자 불만·분쟁처리 기록 3년) 보유합니다. 보유기간이 지나거나 목적이 달성된 정보는 지체 없이 파기합니다.'],
      ['4. 만 14세 미만 아동의 개인정보', 'FalconFlix는 만 18세 이상을 대상으로 하는 서비스로서 만 14세 미만 아동의 개인정보를 수집하지 않습니다. 만 14세 미만 아동의 개인정보가 수집된 사실이 확인되면 지체 없이 파기합니다.'],
      ['5. 개인정보의 제3자 제공', '회사는 이용자의 동의가 있거나 법령에 특별한 규정이 있는 경우에 한하여 개인정보를 제3자에게 제공하며, 그 외에는 제공하지 않습니다.'],
      ['6. 개인정보 처리의 위탁', '회사는 원활한 서비스 제공을 위해 다음과 같이 개인정보 처리 업무를 위탁합니다 — 결제 처리(Stripe), 클라우드 호스팅, 푸시 알림(Google·Apple), 통계 분석. 회사는 「개인정보 보호법」에 따라 위탁계약 시 안전조치를 명시하고 수탁자가 개인정보를 안전하게 처리하는지 감독합니다.'],
      ['7. 개인정보의 국외 이전', '서비스는 전 세계를 대상으로 하며, 이용자의 개인정보는 거주 국가 외의 국가에 있는 서버 및 수탁자(예: Stripe·Google·Apple은 미국)에서 보관·처리될 수 있고, 인프라 변경에 따라 보관 국가가 달라질 수 있습니다. 회사는 국외 이전 시 ① 이전 항목 ② 이전 국가·시기·방법 ③ 이전받는 자 ④ 이용 목적 및 보유 기간을 고지하고, 관련 법에 따라 필요한 경우 별도의 동의를 받습니다. 이용자는 국외 이전을 거부할 수 있으며(거부 시 일부 서비스 이용이 제한될 수 있음), 거부는 support@falconflix.app으로 요청할 수 있습니다.'],
      ['8. 개인정보의 파기 절차 및 방법', '보유기간이 지나거나 목적이 달성된 개인정보는 지체 없이 파기합니다. 전자적 파일은 복구·재생되지 않도록 안전하게 삭제하고, 출력물은 분쇄 또는 소각하여 파기합니다.'],
      ['9. 자동화된 결정 및 AI 기능', 'FalconFlix는 AI 가상 캐릭터와의 상호작용 및 콘텐츠 추천 기능을 제공합니다. 이러한 기능은 오락·편의를 위한 것으로 이용자에게 법적 효력이나 그에 준하는 중대한 영향을 미치는 완전 자동화된 결정을 하지 않습니다. 이용자는 관련하여 설명 요구 및 거부를 support@falconflix.app으로 요청할 수 있습니다.'],
      ['10. 정보주체의 권리·의무 및 행사 방법', '이용자는 개인정보 열람·정정·삭제·처리정지 및 동의 철회를 요청할 수 있습니다. 상당수는 앱 내 "설정 → 계정 및 보안"(계정 삭제·데이터 내보내기 포함)에서, 또는 support@falconflix.app으로 행사할 수 있으며, 회사는 요청일로부터 10일 이내에 조치합니다.'],
      ['11. 개인정보의 안전성 확보조치', '회사는 내부관리계획 수립, 접근권한 관리, 접근통제, 전송·저장 시 암호화, 접속기록 보관 및 위·변조 방지 등 관리적·기술적·물리적 안전성 확보조치를 시행합니다.'],
      ['12. 쿠키 등 자동수집 장치', '회사와 제공업체는 분석·오류 보고·푸시 알림 등을 위해 기기 식별자와 SDK를 사용합니다. 이용자는 기기 설정에서 푸시 알림과 일부 추적을 제어할 수 있습니다.'],
      ['13. 개인정보 보호책임자', '회사는 개인정보 처리에 관한 업무를 총괄하는 개인정보 보호책임자를 지정합니다. 개인정보 관련 문의·불만·피해 구제는 support@falconflix.app으로 연락해 주십시오.'],
      ['14. 국내대리인', '회사는 국외 사업자로서, 「개인정보 보호법」이 정한 국내대리인 지정 기준에 해당하게 되는 경우 국내대리인을 지정하여 본 방침에 그 성명·주소·연락처를 게재합니다.'],
      ['15. 권익침해 구제 방법', '이용자는 아래 기관에 분쟁 해결이나 상담을 신청할 수 있습니다 — 개인정보분쟁조정위원회(1833-6972, www.kopico.go.kr), 개인정보침해신고센터/KISA(118, privacy.kisa.or.kr), 대검찰청 사이버수사과(1301), 경찰청 사이버수사국(182).'],
      ['16. 처리방침의 변경', '본 방침은 수시로 변경될 수 있으며, 변경 시 서비스 내에 게시하고 "최종 업데이트" 날짜를 갱신하며 중대한 변경은 사전에 안내합니다.'],
    ],
  ),
  'ar': LegalDocData(
    title: 'سياسة الخصوصية',
    updated: _kUpdated,
    intro:
        'تُشغّل شركة FALCONFLIX-SINGAPORE-TECH PTE. LTD. («الشركة»، «نحن») تطبيق FalconFlix والخدمات ذات الصلة («الخدمة»). '
        'توضّح هذه السياسة — بما يتوافق مع نظام حماية البيانات الشخصية في المملكة العربية السعودية والمرسوم بقانون اتحادي رقم (45) لسنة 2021 في دولة الإمارات وغيرها من الأنظمة المعمول بها — المعلومات التي نجمعها وكيف نستخدمها ونشاركها وننقلها ونحميها، وما لك من حقوق. يُرجى قراءتها بعناية قبل استخدام الخدمة.',
    sections: [
      ['١. من نحن', 'المتحكم في البيانات هو شركة FALCONFLIX-SINGAPORE-TECH PTE. LTD. المؤسسة في سنغافورة («الشركة»). لأي استفسار يخص الخصوصية أو لممارسة حقوقك تواصل مع support@falconflix.app.'],
      ['٢. المعلومات التي نجمعها وكيفية جمعها', 'معلومات الحساب: البريد الإلكتروني، أو المُعرّف والملف الأساسي من تسجيل دخول طرف ثالث تأذن به (Google، Apple)، والاسم المستعار والصورة.', 'معلومات الاستخدام والجهاز: سجل المشاهدة والتفاعل والمفضلة وكلمات البحث وطراز الجهاز ونظام التشغيل وإصدار التطبيق واللغة والمنطقة التقريبية وعنوان IP وسجلات الأعطال.', 'معلومات المعاملات: عند شراء عملات النسر تُعالَج المدفوعات عبر Stripe، ولا نخزّن رقم البطاقة كاملاً بل نحتفظ برقم الطلب والمبلغ وحالة الدفع فقط.', 'طرق الجمع: إدخالك المباشر، والجمع التلقائي أثناء استخدام الخدمة، والاستلام من مزوّدي تسجيل الدخول.'],
      ['٣. أغراض المعالجة وأساسها النظامي', 'نعالج بياناتك للأغراض التالية وبالأساس النظامي المبيّن: تقديم الخدمة والحساب وصيانتهما (تنفيذ عقد)؛ بثّ الدراما والتفاعل مع شخصيات الذكاء الاصطناعي (تنفيذ عقد)؛ معالجة الشحن بالدولار الأمريكي عبر Stripe ومنح المزايا (تنفيذ عقد)؛ التخصيص وتذكّر التفضيلات (المصلحة المشروعة أو موافقتك)؛ التحقق من بلوغ 18 عامًا وأمن المنصة ومنع الاحتيال (المصلحة المشروعة والالتزام النظامي)؛ الرد على الاستفسارات والشكاوى؛ والامتثال للأنظمة (التزام نظامي).'],
      ['٤. هل تقديم البيانات إلزامي', 'بعض البيانات (مثل البريد الإلكتروني ووسيلة الدفع) لازمة لإنشاء الحساب وتقديم الخدمة، وبدونها يتعذّر تشغيل الخدمة أو إتمام الشراء. أما البيانات الاختيارية فيؤدي عدم تقديمها فقط إلى تعذّر ميزات معيّنة دون حرمانك من الخدمة الأساسية.'],
      ['٥. مشاركة المعلومات والإفصاح عنها', 'لا نبيع معلوماتك الشخصية. نشارك ما يلزم فقط مع: (أ) مزوّدي خدمات ينفّذون مهامًا نيابة عنا (الدفع Stripe، الاستضافة السحابية، الإشعارات، التحليلات)؛ (ب) الجهات المختصة عند طلب النظام أو لحماية حقوق المستخدمين وسلامتهم؛ (ج) كيان خَلَف في حالة اندماج أو استحواذ أو بيع أصول، مع الالتزام بهذه السياسة.'],
      ['٦. نقل البيانات خارج بلدك', 'الخدمة عالمية وتُشغَّل من سنغافورة، وقد تُخزَّن بياناتك وتُعالَج على خوادم في دولة أو أكثر خارج بلدك، وقد يتغيّر بلد الاستضافة مع تطوّر بنيتنا التقنية؛ كما قد يعالج بعض مزوّدينا (Stripe، Google، Apple) البيانات في الولايات المتحدة. وعند نقل البيانات خارج بلدك نعتمد على أساس مشروع للنقل — مثل الشروط التعاقدية القياسية المعتمدة أو موافقتك الصريحة — مع ضمانات مناسبة، ويمكنك طلب معلومات عنها عبر support@falconflix.app.'],
      ['٧. مدة الاحتفاظ والإتلاف', 'نحتفظ بالبيانات للمدة اللازمة للأغراض الموضّحة أو وفق ما يقتضيه النظام. تُحفظ بيانات الحساب أثناء نشاطه ولمدة معقولة بعده، وسجلات المعاملات للمدة التي تقتضيها أنظمة المحاسبة والضرائب، ويتم إتلاف البيانات بطريقة آمنة عند انتهاء الحاجة إليها.'],
      ['٨. أمن المعلومات', 'نطبّق تدابير تقنية وتنظيمية معقولة، منها التشفير أثناء النقل وضبط الوصول، لحماية بياناتك. ولا توجد وسيلة نقل أو تخزين آمنة تمامًا، فلا يمكننا ضمان الأمان المطلق.'],
      ['٩. حقوقك', 'وفقًا للأنظمة المعمول بها، لك الحق في العلم والوصول إلى بياناتك والحصول عليها وتصحيحها وإتلافها، والاعتراض على بعض المعالجة أو تقييدها، ونقل البيانات، والعدول عن موافقتك في أي وقت. يمكنك ممارسة الكثير من ذلك داخل التطبيق عبر «الإعدادات ← الحساب والأمان» (بما في ذلك حذف الحساب وتصدير البيانات) أو عبر support@falconflix.app، وسنستجيب خلال المدة التي يحددها النظام (وعادةً خلال 30 يومًا).'],
      ['١٠. الأطفال', 'FalconFlix مخصّص للبالغين (18 عامًا فأكثر) ويتضمّن محتوى دراميًا ناضجًا مصنّفًا للكبار. لا نجمع عن قصد بيانات الأطفال، وإذا تبيّن خلاف ذلك نحذفها. للتواصل: support@falconflix.app.'],
      ['١١. ملفات تعريف الارتباط وحزم SDK', 'نستخدم نحن ومزوّدونا مُعرّفات الأجهزة وحزم SDK — مثلاً للتحليلات والإبلاغ عن الأعطال والإشعارات — لتشغيل الخدمة وتأمينها وتحسينها. يمكنك التحكم في الإشعارات وبعض التتبّع عبر إعدادات جهازك.'],
      ['١٢. أحكام خاصة بالمناطق', 'حيثما منحك النظام المحلي حقوقًا إضافية أو تطلّب إفصاحات محددة — بما في ذلك نظام حماية البيانات الشخصية في المملكة العربية السعودية (تحت إشراف الهيئة السعودية للبيانات والذكاء الاصطناعي «سدايا»)، والمرسوم بقانون اتحادي رقم (45) لسنة 2021 في دولة الإمارات، واللائحة العامة لحماية البيانات في الاتحاد الأوروبي/المملكة المتحدة، وقانونَي اليابان (APPI) وكوريا (PIPA) — فإننا نحترم تلك الحقوق ونلتزم بالإفصاحات المطلوبة. للممارسة تواصل مع support@falconflix.app.'],
      ['١٣. تغييرات هذه السياسة', 'قد نُحدّث هذه السياسة من حين لآخر، وسننشر النسخة المُحدّثة داخل الخدمة ونُحدّث تاريخ «آخر تحديث»، ونُعلمك بالتغييرات الجوهرية بوسيلة أبرز.'],
      ['١٤. تواصل معنا', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app.'],
    ],
  ),
  'fr': LegalDocData(
    title: 'Politique de confidentialité',
    updated: _kUpdated,
    intro:
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD. (la « Société », « nous ») exploite l’application FalconFlix et les services associés (le « Service »). '
        'La présente Politique de confidentialité, conforme au RGPD et à la loi française Informatique et Libertés (sous le contrôle de la CNIL), explique quelles données personnelles nous traitons, comment nous les utilisons, partageons, transférons et protégeons, ainsi que vos droits. Veuillez la lire attentivement avant d’utiliser le Service.',
    sections: [
      ['1. Qui nous sommes', 'Le responsable du traitement est FALCONFLIX-SINGAPORE-TECH PTE. LTD., société immatriculée à Singapour. Contact vie privée : support@falconflix.app.', 'Pour toute question relative à la protection des données, ou pour exercer vos droits au titre du RGPD, contactez-nous à support@falconflix.app. Lorsque la loi exige la désignation d’un délégué à la protection des données ou d’un représentant dans l’Union (article 27 du RGPD), leurs coordonnées seront indiquées ici.'],
      ['2. Données que nous collectons', 'Données de compte : adresse e-mail, ou l’identifiant et le profil de base renvoyés par une connexion tierce que vous autorisez (Google, Apple), ainsi que le pseudo et l’avatar que vous définissez.', 'Données d’usage et d’appareil : historique de visionnage et d’interaction, favoris, recherches, et données techniques (modèle d’appareil, système d’exploitation, version de l’app, langue, région approximative, adresse IP, journaux de plantage).', 'Données de transaction : lors de l’achat d’Eagle Coins, le paiement est traité par notre prestataire tiers Stripe ; nous ne stockons pas votre numéro de carte complet, seulement le numéro de commande, le montant et le statut nécessaires au rapprochement et au support.', 'Communications : le contenu de vos messages au support ou de vos retours, pour répondre et améliorer le Service.'],
      ['3. Finalités et bases légales', 'Nous utilisons vos données pour : fournir et maintenir le Service et votre compte (exécution d’un contrat) ; personnaliser les recommandations et mémoriser vos préférences (intérêt légitime, ou votre consentement lorsque requis) ; traiter les recharges en dollars américains via Stripe et délivrer les avantages (exécution d’un contrat) ; vérifier la majorité (18 ans), sécuriser la plateforme et prévenir la fraude (intérêt légitime et obligations légales) ; répondre à vos demandes ; et respecter les lois applicables (obligation légale).', 'Lorsque nous nous fondons sur le consentement, vous pouvez le retirer à tout moment, sans effet sur les traitements antérieurs.'],
      ['4. Partage et divulgation', 'Nous ne vendons pas vos données. Nous ne les partageons que dans la mesure nécessaire avec : (a) des prestataires agissant pour notre compte (paiement Stripe, hébergement cloud, notifications, analyse) ; (b) les autorités ou tiers lorsque la loi l’exige, pour appliquer nos conditions ou protéger les droits et la sécurité des utilisateurs ; (c) une entité repreneuse en cas de fusion, acquisition ou cession d’actifs, soumise à la présente Politique.'],
      ['5. Transferts internationaux', 'Le Service est mondial et exploité depuis Singapour. Vos données peuvent être stockées et traitées sur des serveurs situés dans un ou plusieurs pays hors de votre pays, et le lieu d’hébergement peut évoluer ; certains prestataires (Stripe, Google, Apple) peuvent traiter des données aux États-Unis. Singapour et les États-Unis ne font pas l’objet d’une décision d’adéquation de l’Union européenne.', 'Pour les transferts hors EEE, nous nous appuyons sur les clauses contractuelles types (CCT) de la Commission européenne (version 2021), assorties d’une analyse d’impact du transfert et de mesures supplémentaires ; une copie des garanties peut être obtenue à support@falconflix.app.'],
      ['6. Durées de conservation', 'Nous ne conservons vos données que le temps nécessaire aux finalités ou requis par la loi, selon un cycle « base active » puis « archivage intermédiaire ». Les données de compte sont conservées tant que le compte est actif et pendant une durée raisonnable ensuite ; les données de prospects/comptes inactifs jusqu’à 3 ans après le dernier contact ; les pièces de facturation et de paiement 10 ans conformément au droit commercial. Au-delà, les données sont supprimées ou anonymisées.'],
      ['7. Sécurité', 'Nous appliquons des mesures techniques et organisationnelles raisonnables, dont le chiffrement en transit et le contrôle d’accès, pour protéger vos données contre tout accès, divulgation ou perte non autorisés. Aucune méthode n’étant totalement sûre, nous ne pouvons garantir une sécurité absolue.'],
      ['8. Vos droits', 'Sous réserve du droit applicable, vous pouvez accéder à vos données, les rectifier, les mettre à jour ou les effacer, limiter certains traitements ou vous y opposer, demander la portabilité, et retirer votre consentement à tout moment. Exercice via Réglages → Compte et sécurité (suppression de compte et export inclus) ou support@falconflix.app.', 'Vous avez le droit d’introduire une réclamation auprès de la Commission nationale de l’informatique et des libertés (CNIL), 3 Place de Fontenoy, TSA 80715, 75334 Paris Cedex 07 (www.cnil.fr), sans préjudice de tout autre recours.'],
      ['9. Cookies et autres traceurs', 'Nous ne déposons les traceurs non essentiels (mesure d’audience, analyse, SDK) qu’après votre consentement, recueilli par un acte positif clair. Il est aussi simple de refuser que d’accepter, le consentement est recueilli par finalité, et vous pouvez modifier vos choix à tout moment via « Gérer mes traceurs ». Votre choix est conservé pour une durée maximale de 6 à 13 mois. Les traceurs strictement nécessaires au fonctionnement du Service ne requièrent pas de consentement.'],
      ['10. Directives post-mortem', 'Conformément à l’article 85 de la loi Informatique et Libertés, vous pouvez définir des directives générales ou particulières relatives à la conservation, à l’effacement et à la communication de vos données personnelles après votre décès. Les directives particulières peuvent nous être communiquées à support@falconflix.app. En l’absence de directives, vos héritiers peuvent exercer certains droits.'],
      ['11. Enfants', 'FalconFlix est strictement réservé aux personnes majeures (18 ans et plus) et contient du contenu dramatique pour adultes. En droit français, la majorité numérique est fixée à 15 ans (article 45 de la loi Informatique et Libertés). Nous ne collectons pas sciemment de données de mineurs et supprimerons toute donnée identifiée comme telle ; contactez support@falconflix.app.'],
      ['12. Modifications', 'Nous pouvons mettre à jour cette Politique. La version mise à jour sera publiée dans le Service avec une date de « dernière mise à jour » actualisée ; les changements importants vous seront notifiés de manière plus visible.'],
      ['13. Nous contacter', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app. Pour toute question sur cette Politique ou notre traitement de vos données, n’hésitez pas à nous écrire.'],
    ],
  ),
};

// ════════════════════════ 用户协议 ════════════════════════
const Map<String, LegalDocData> _terms = {
  'en': LegalDocData(
    title: 'Terms of Service',
    updated: _kUpdated,
    intro:
        'Welcome to FalconFlix. These Terms of Service (the “Terms”) are a binding agreement between you and FALCONFLIX-SINGAPORE-TECH PTE. LTD. (the “Company”, “we”), '
        'governing your use of FalconFlix and its short-drama streaming, AI character interaction and virtual benefit (Eagle Coins) services. '
        'Please read them carefully. By registering, signing in or using FalconFlix, you confirm that you have read, understood and agree to these Terms.',
    sections: [
      [
        '1. The Service',
        'FalconFlix is a premium short-drama streaming and interactive entertainment platform for a global audience. It mainly provides: on-demand short dramas; AI virtual character interaction; the top-up and use of the virtual benefit “Eagle Coins”; and related features such as recommendations, favorites and sharing. We may continuously optimize, adjust or expand the Service; the actual features depend on the version you use.',
      ],
      [
        '2. Account Registration and Security',
        'You may register and sign in by email, Google or Apple. You must provide true and accurate information and keep your credentials safe. You are responsible for all activity under your account. If you find any unauthorized use or security issue, contact support@falconflix.app immediately.',
      ],
      [
        '3. Eagle Coins and Payment',
        '“Eagle Coins” are a virtual benefit used within FalconFlix to unlock episodes and take part in AI interaction. They have no legal-currency status, cannot be exchanged for cash, and cannot be transferred or used outside the Service.',
        'Top-ups are processed by the third-party processor Stripe and billed in US Dollars (USD). Except where required by applicable law or where we expressly agree otherwise in writing, purchased or used Eagle Coins are non-refundable. Packs, prices and the coins credited are as shown at the time of purchase.',
      ],
      [
        '4. User Conduct',
        'You agree to use the Service lawfully and not to use it for any activity that violates applicable laws or public order and morals, including without limitation: posting unlawful or infringing content; spreading malware; recording or copying Service content without authorization; reverse-engineering or disrupting the Service; or unlawfully obtaining Eagle Coins or others’ account information. If you breach these rules, we may restrict features, suspend or close the account, and reserve the right to pursue legal remedies.',
      ],
      [
        '5. Intellectual Property',
        'All content in the Service — including dramas, footage, audio and video, text, interface, trademarks, logos and AI character images — is owned by the Company or its licensors and protected by applicable law. You may not copy, distribute, adapt, rent or use it commercially without the rights holder’s written permission.',
      ],
      [
        '6. Third-Party Services',
        'The Service integrates third-party sign-in (Google, Apple) and third-party payment (Stripe). When using these features you must also comply with the relevant third party’s agreements and policies. Issues caused by a third-party service are the responsibility of that third party under its own terms.',
      ],
      [
        '7. Disclaimers and Limitation of Liability',
        'The Service is provided “as is”. To the maximum extent permitted by applicable law, we do not warrant that the Service will be uninterrupted or error-free, and we are not liable for losses caused by force majeure, network failures, third parties or your own actions. In any case, our total liability to you will not exceed the fees you actually paid for the relevant Service. Nothing in these Terms limits liability that cannot be limited under applicable law.',
      ],
      [
        '8. Changes and Termination of the Service',
        'We may change, suspend or terminate part or all of the Service for business, technical or legal reasons, with reasonable prior notice where appropriate. If you breach these Terms, we may terminate the Service to you at any time.',
      ],
      [
        '9. Governing Law and Dispute Resolution',
        'These Terms are governed by the laws of the Republic of Singapore. Any dispute arising out of or relating to these Terms shall first be resolved through good-faith negotiation; failing which, either party may submit the dispute to the competent court at the location of the Company. This does not deprive you of the protection of mandatory consumer laws in your country of residence.',
      ],
      [
        '10. Your Local Consumer Rights',
        'If you are a consumer, you may have mandatory statutory rights under the law of your country of residence (for example, rights of withdrawal or refund in the EU). Nothing in these Terms affects those mandatory rights.',
      ],
      [
        '11. Amendments to These Terms',
        'We may update these Terms from time to time. The updated version will be published in the Service with an updated “Last updated” date. If you continue to use FalconFlix after an update, you are deemed to accept the revised Terms.',
      ],
      [
        '12. Contact Us',
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app.',
      ],
    ],
  ),
  'zh': LegalDocData(
    title: '用户协议',
    updated: _kUpdated,
    intro:
        '欢迎使用 FalconFlix。本《用户协议》（以下简称“本协议”）由您与 FALCONFLIX-SINGAPORE-TECH PTE. LTD.（以下简称“本公司”“我们”）订立，'
        '就您使用 FalconFlix 提供的短剧点播、AI 角色互动、虚拟权益（鹰币）等服务约定双方权利义务。请您在使用前仔细阅读；一旦您注册、登录或使用 FalconFlix，即视为您已充分理解并同意本协议全部内容。',
    sections: [
      [
        '一、服务内容',
        'FalconFlix 为面向全球用户的精品短剧流媒体与互动娱乐平台，主要提供：精品短剧在线点播；AI 虚拟角色互动；虚拟权益“鹰币”的充值与消耗；以及围绕上述服务的推荐、收藏、分享等功能。我们可能不断优化、调整或扩展服务内容，具体功能以您所使用的版本实际呈现为准。',
      ],
      [
        '二、账号注册与安全',
        '您可通过邮箱、Google 或 Apple 注册并登录。您应保证所提供信息真实、准确，并妥善保管账号凭证。账号下发生的一切行为由账号持有人承担相应责任。若发现账号被未经授权使用或存在安全漏洞，请立即通过 support@falconflix.app 与我们联系。',
      ],
      [
        '三、鹰币与充值',
        '“鹰币”是 FalconFlix 内用于解锁剧集、参与 AI 互动等的虚拟权益，仅可在本服务内使用，不具有法定货币属性，不可兑换为现金，亦不可转让或在服务外流通。',
        '鹰币充值通过第三方支付机构 Stripe 处理，并以美元（USD）计价结算。除适用法律强制要求或我们另行书面承诺外，已购买或已消耗的鹰币不予退款。具体套餐、价格及到账数量以您充值时页面展示为准。',
      ],
      [
        '四、用户行为规范',
        '您承诺合法、合规地使用本服务，不得从事任何违反所适用法律法规或公序良俗的行为，包括但不限于：发布违法或侵权内容、传播恶意程序、未经授权录制或盗录服务内容、对服务进行反向工程或破坏其正常运行、利用技术手段非法获取鹰币或他人账号信息。若您违反上述规范，我们有权视情节采取限制功能、冻结或注销账号等措施，并保留追究法律责任的权利。',
      ],
      [
        '五、知识产权',
        '本服务所包含的剧集、画面、音视频、文字、界面、商标、Logo 及 AI 角色形象等内容，其知识产权均归本公司或相应权利人所有，受适用法律保护。未经权利人书面许可，您不得以任何形式复制、传播、改编、出租或用于商业用途。',
      ],
      [
        '六、第三方服务',
        '本服务集成了第三方登录（Google、Apple）与第三方支付（Stripe）。您在使用相关功能时，还应遵守对应第三方的协议与政策。因第三方服务自身原因导致的问题，由该第三方依其条款承担相应责任。',
      ],
      [
        '七、免责声明与责任限制',
        '本服务按“现状”提供。在适用法律允许的最大范围内，我们不对服务的绝对不中断、无错误作出保证；因不可抗力、网络故障、第三方原因或您自身原因造成的损失，我们不承担责任。在任何情况下，我们对您承担的责任总额不超过您就相关服务实际支付的费用。本协议不排除或限制依适用法律不可排除或限制的责任。',
      ],
      [
        '八、服务的变更与终止',
        '我们可能因业务调整、技术升级或法律要求等原因变更、暂停或终止部分或全部服务，并在适当情况下提前以适当方式通知。若您违反本协议，我们有权随时终止向您提供服务。',
      ],
      [
        '九、适用法律与争议解决',
        '本协议适用新加坡共和国法律。因本协议产生或与之相关的任何争议，双方应首先友好协商解决；协商不成的，任一方均可将争议提交至本公司所在地具有管辖权的法院解决。本条不剥夺您在居住国所享有的强制性消费者法律保护。',
      ],
      [
        '十、您的当地消费者权利',
        '若您为消费者，您可能依居住国法律享有强制性法定权利（例如欧盟的撤销权或退款权）。本协议的任何内容均不影响该等强制性权利。',
      ],
      [
        '十一、协议的修订',
        '我们可能不时更新本协议，更新后将在本服务内公布并更新“最近更新”日期。若您在协议更新后继续使用 FalconFlix，即视为您接受修订后的协议。',
      ],
      [
        '十二、联系我们',
        'FALCONFLIX-SINGAPORE-TECH PTE. LTD.——support@falconflix.app。',
      ],
    ],
  ),
  'ja': LegalDocData(
    title: '利用規約',
    updated: _kUpdated,
    intro:
        'FalconFlix へようこそ。本利用規約（以下「本規約」）は、お客様と FALCONFLIX-SINGAPORE-TECH PTE. LTD.（以下「当社」）との間の拘束力ある契約であり、'
        'FalconFlix のショートドラマ配信、AI キャラクター対話、仮想特典（イーグルコイン）等のサービス利用について定めます。'
        'ご利用前に必ずお読みください。登録・ログインまたは利用をもって、本規約に同意したものとみなします。',
    sections: [
      ['1. サービス内容', 'FalconFlix は全世界の利用者向けの高品質ショートドラマ配信・インタラクティブ娯楽プラットフォームで、主にショートドラマのオンデマンド配信、AI 仮想キャラクター対話、仮想特典「イーグルコイン」のチャージと利用、レコメンド・お気に入り・共有等の機能を提供します。当社は随時サービスを最適化・調整・拡張することがあり、実際の機能はご利用の版に準じます。'],
      ['2. アカウント登録と安全', 'メール、Google または Apple で登録・ログインできます。提供する情報は真実かつ正確である必要があり、認証情報は適切に管理してください。アカウント下の一切の行為は名義人の責任となります。不正利用やセキュリティ上の問題を発見した場合は直ちに support@falconflix.app へご連絡ください。'],
      ['3. イーグルコインと決済', '「イーグルコイン」はエピソードの解放や AI 対話に用いる本サービス内の仮想特典で、本サービス内でのみ利用でき、法定通貨ではなく、現金との交換・譲渡・サービス外での流通はできません。', 'チャージは第三者の Stripe が処理し、米ドル（USD）で決済されます。適用法が義務付ける場合や当社が別途書面で約束する場合を除き、購入済み・使用済みのイーグルコインは返金されません。パッケージ・価格・付与数は購入時の画面表示に準じます。'],
      ['4. 利用者の行為規範', '法令や公序良俗に反する行為（違法・権利侵害コンテンツの投稿、マルウェアの拡散、無断録画・盗録、リバースエンジニアリングや妨害、不正な手段によるコイン・他者情報の取得を含むがこれらに限らない）に本サービスを利用しないことに同意します。違反した場合、当社は機能制限・凍結・アカウント抹消等の措置をとり、法的責任を追及する権利を留保します。'],
      ['5. 知的財産', '本サービスに含まれるドラマ、映像、音声、テキスト、インターフェース、商標、ロゴ、AI キャラクター画像等の知的財産は当社または各権利者に帰属し、適用法で保護されます。権利者の書面による許可なく、複製・配布・改変・貸与・商業利用はできません。'],
      ['6. 第三者サービス', '本サービスは第三者ログイン（Google、Apple）と第三者決済（Stripe）を統合しています。これらの機能の利用にあたっては各第三者の規約・ポリシーにも従う必要があります。第三者サービス自体に起因する問題は、当該第三者がその規約に従い責任を負います。'],
      ['7. 免責と責任の制限', '本サービスは「現状有姿」で提供されます。適用法が認める最大限の範囲で、中断や誤りのないことを保証せず、不可抗力・通信障害・第三者・お客様自身の事由による損害について責任を負いません。いかなる場合も当社の責任総額は当該サービスについて実際にお支払いいただいた金額を超えません。適用法上制限できない責任を制限するものではありません。'],
      ['8. サービスの変更・終了', '当社は事業上・技術上・法的理由によりサービスの一部または全部を変更・停止・終了することがあり、適切な場合は事前に適切な方法で通知します。お客様が本規約に違反した場合、当社はいつでも提供を終了できます。'],
      ['9. 準拠法と紛争解決', '本規約はシンガポール共和国法に準拠します。本規約に起因または関連する紛争は、まず誠実な協議で解決し、解決しない場合はいずれの当事者も当社所在地の管轄裁判所に提起できます。本条はお客様の居住国の強行的な消費者法の保護を奪うものではありません。'],
      ['10. 居住地の消費者の権利', '消費者であるお客様は、居住国の法律により強行的な法定権利（例：EU の撤回権・返金権）を有する場合があります。本規約の内容はそれらの強行的権利に影響しません。'],
      ['11. 規約の改定', '当社は本規約を随時更新することがあります。更新版は「最終更新日」とともに本サービス内に掲示します。更新後も FalconFlix を利用し続けた場合、改定後の規約に同意したものとみなします。'],
      ['12. お問い合わせ', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app。'],
    ],
  ),
  'ko': LegalDocData(
    title: '이용약관',
    updated: _kUpdated,
    intro:
        'FalconFlix에 오신 것을 환영합니다. 본 이용약관(이하 "약관")은 이용자와 FALCONFLIX-SINGAPORE-TECH PTE. LTD.(이하 "회사") 간의 구속력 있는 계약으로, '
        'FalconFlix의 숏드라마 스트리밍, AI 캐릭터 상호작용, 가상 혜택(이글 코인) 등 서비스 이용에 관한 권리와 의무를 정합니다. '
        '이용 전에 반드시 읽어 주시고, 가입·로그인 또는 이용 시 본 약관에 동의한 것으로 봅니다.',
    sections: [
      ['1. 서비스 내용', 'FalconFlix는 전 세계 이용자를 위한 프리미엄 숏드라마 스트리밍·인터랙티브 엔터테인먼트 플랫폼으로, 주로 숏드라마 주문형 스트리밍, AI 가상 캐릭터 상호작용, 가상 혜택 "이글 코인"의 충전·사용, 추천·즐겨찾기·공유 등의 기능을 제공합니다. 회사는 서비스를 수시로 최적화·조정·확장할 수 있으며 실제 기능은 이용하시는 버전을 따릅니다.'],
      ['2. 계정 가입과 보안', '이메일, Google 또는 Apple로 가입·로그인할 수 있습니다. 제공하는 정보는 진실하고 정확해야 하며 인증정보를 안전하게 관리해야 합니다. 계정에서 발생한 모든 행위는 명의자가 책임집니다. 무단 사용이나 보안 문제를 발견하면 즉시 support@falconflix.app으로 연락 주십시오.'],
      ['3. 이글 코인과 결제', '"이글 코인"은 회차 잠금 해제와 AI 상호작용에 사용하는 서비스 내 가상 혜택으로, 서비스 내에서만 사용할 수 있고 법정화폐가 아니며 현금 교환·양도·서비스 외 유통이 불가능합니다.', '충전은 제3자 Stripe가 처리하며 미국 달러(USD)로 결제됩니다. 관련 법이 의무화하거나 회사가 별도로 서면 약속한 경우를 제외하고, 구매·사용한 이글 코인은 환불되지 않습니다. 패키지·가격·지급 수량은 구매 시 화면 표시를 따릅니다.'],
      ['4. 이용자 행위 규범', '법령이나 공서양속에 반하는 행위(불법·침해 콘텐츠 게시, 악성 프로그램 유포, 무단 녹화·복제, 리버스 엔지니어링이나 방해, 부정한 수단으로 코인·타인 정보 취득 등을 포함하되 이에 한정되지 않음)에 서비스를 이용하지 않을 것에 동의합니다. 위반 시 회사는 기능 제한·동결·계정 말소 등의 조치를 취하고 법적 책임을 물을 권리를 보유합니다.'],
      ['5. 지식재산권', '서비스에 포함된 드라마, 영상, 음성, 텍스트, 인터페이스, 상표, 로고, AI 캐릭터 이미지 등의 지식재산권은 회사 또는 각 권리자에게 귀속되며 관련 법으로 보호됩니다. 권리자의 서면 허가 없이 복제·배포·개작·대여·상업적 이용을 할 수 없습니다.'],
      ['6. 제3자 서비스', '서비스는 제3자 로그인(Google, Apple)과 제3자 결제(Stripe)를 통합합니다. 해당 기능 이용 시 각 제3자의 약관과 정책도 준수해야 합니다. 제3자 서비스 자체로 인한 문제는 해당 제3자가 그 약관에 따라 책임집니다.'],
      ['7. 면책과 책임 제한', '서비스는 "있는 그대로" 제공됩니다. 관련 법이 허용하는 최대 범위에서 중단이나 오류가 없음을 보증하지 않으며, 불가항력·통신 장애·제3자·이용자 본인의 사유로 인한 손해에 책임지지 않습니다. 어떤 경우에도 회사의 총 책임은 해당 서비스에 실제로 지불한 금액을 초과하지 않습니다. 관련 법상 제한할 수 없는 책임을 제한하지 않습니다.'],
      ['8. 서비스의 변경·종료', '회사는 사업·기술·법적 사유로 서비스의 일부 또는 전부를 변경·중단·종료할 수 있으며 적절한 경우 사전에 적절한 방법으로 통지합니다. 이용자가 약관을 위반하면 회사는 언제든지 제공을 종료할 수 있습니다.'],
      ['9. 준거법과 분쟁 해결', '본 약관은 싱가포르 공화국 법을 준거법으로 합니다. 약관에 기인하거나 관련된 분쟁은 먼저 성실히 협의하여 해결하고, 해결되지 않으면 어느 당사자든 회사 소재지의 관할 법원에 제기할 수 있습니다. 본 조항은 이용자의 거주국 강행 소비자법 보호를 박탈하지 않습니다.'],
      ['10. 거주지 소비자 권리', '소비자인 이용자는 거주국 법률에 따라 강행 법정 권리(예: EU의 철회권·환불권)를 가질 수 있습니다. 본 약관의 어떤 내용도 그러한 강행 권리에 영향을 주지 않습니다.'],
      ['11. 약관의 개정', '회사는 본 약관을 수시로 갱신할 수 있습니다. 갱신본은 "최종 업데이트" 날짜와 함께 서비스 내에 게시됩니다. 갱신 후에도 FalconFlix를 계속 이용하면 개정된 약관에 동의한 것으로 봅니다.'],
      ['12. 문의처', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app.'],
    ],
  ),
  'ar': LegalDocData(
    title: 'شروط الخدمة',
    updated: _kUpdated,
    intro:
        'مرحبًا بك في FalconFlix. تشكّل شروط الخدمة هذه («الشروط») اتفاقًا مُلزمًا بينك وبين شركة FALCONFLIX-SINGAPORE-TECH PTE. LTD. («الشركة»، «نحن»)، '
        'تحكم استخدامك لخدمات FalconFlix من بثّ الدراما القصيرة والتفاعل مع شخصيات الذكاء الاصطناعي والمزايا الافتراضية (عملات النسر). '
        'يُرجى قراءتها بعناية. وبتسجيلك أو دخولك أو استخدامك للخدمة تُقرّ بأنك قرأت هذه الشروط وفهمتها ووافقت عليها.',
    sections: [
      ['١. الخدمة', 'FalconFlix منصّة مميّزة لبثّ الدراما القصيرة والترفيه التفاعلي لجمهور عالمي، تقدّم أساسًا: الدراما القصيرة عند الطلب؛ التفاعل مع شخصيات الذكاء الاصطناعي؛ شحن واستخدام المزية الافتراضية «عملات النسر»؛ وميزات مرتبطة كالتوصيات والمفضلة والمشاركة. قد نُحسّن الخدمة أو نعدّلها أو نوسّعها باستمرار، والميزات الفعلية تتبع الإصدار الذي تستخدمه.'],
      ['٢. تسجيل الحساب وأمنه', 'يمكنك التسجيل والدخول عبر البريد الإلكتروني أو Google أو Apple. يجب تقديم معلومات صحيحة ودقيقة والحفاظ على بيانات الدخول. أنت مسؤول عن كل نشاط يتم عبر حسابك. وعند اكتشاف أي استخدام غير مصرّح به أو مشكلة أمنية تواصل فورًا مع support@falconflix.app.'],
      ['٣. عملات النسر والدفع', '«عملات النسر» مزية افتراضية داخل FalconFlix لفتح الحلقات والمشاركة في تفاعل الذكاء الاصطناعي، تُستخدم داخل الخدمة فقط، وليست عملة قانونية، ولا يمكن تحويلها إلى نقد أو نقلها أو تداولها خارج الخدمة.', 'تُعالَج عمليات الشحن عبر مزوّد الطرف الثالث Stripe وتُحتسب بالدولار الأمريكي (USD). وباستثناء ما يقتضيه القانون المعمول به أو ما نوافق عليه كتابةً، فإن عملات النسر المشتراة أو المستخدمة غير قابلة للاسترداد. وتتبع الباقات والأسعار وعدد العملات الممنوحة ما يُعرَض وقت الشراء.'],
      ['٤. سلوك المستخدم', 'توافق على استخدام الخدمة بشكل قانوني وعدم استخدامها في أي نشاط يخالف القوانين المعمول بها أو النظام العام والآداب، بما في ذلك على سبيل المثال لا الحصر: نشر محتوى غير قانوني أو منتهِك؛ نشر البرمجيات الخبيثة؛ تسجيل أو نسخ محتوى الخدمة دون إذن؛ الهندسة العكسية أو تعطيل الخدمة؛ أو الحصول غير المشروع على العملات أو معلومات حسابات الآخرين. وعند مخالفتك قد نقيّد الميزات أو نوقف الحساب أو نغلقه، ونحتفظ بحق اتخاذ الإجراءات القانونية.'],
      ['٥. الملكية الفكرية', 'جميع محتويات الخدمة — بما فيها الدراما واللقطات والصوت والفيديو والنصوص والواجهة والعلامات التجارية والشعارات وصور شخصيات الذكاء الاصطناعي — مملوكة للشركة أو للمرخّصين لها ومحمية بالقانون المعمول به. ولا يجوز نسخها أو توزيعها أو تعديلها أو تأجيرها أو استخدامها تجاريًا دون إذن كتابي من صاحب الحق.'],
      ['٦. خدمات الأطراف الثالثة', 'تدمج الخدمة تسجيل دخول طرف ثالث (Google، Apple) ودفعًا من طرف ثالث (Stripe). وعند استخدام هذه الميزات عليك الالتزام أيضًا باتفاقيات وسياسات الطرف الثالث المعني. والمشكلات الناتجة عن خدمة طرف ثالث تقع على عاتق ذلك الطرف وفق شروطه.'],
      ['٧. إخلاء المسؤولية وحدودها', 'تُقدَّم الخدمة «كما هي». وإلى أقصى حد يسمح به القانون، لا نضمن أن تكون الخدمة دون انقطاع أو خطأ، ولا نتحمّل الخسائر الناجمة عن القوة القاهرة أو أعطال الشبكة أو الأطراف الثالثة أو تصرفاتك. وفي جميع الأحوال لا تتجاوز مسؤوليتنا الإجمالية تجاهك ما دفعته فعليًا مقابل الخدمة المعنية. ولا يحدّ ذلك من أي مسؤولية لا يمكن تقييدها قانونًا.'],
      ['٨. تغيير الخدمة وإنهاؤها', 'قد نغيّر الخدمة أو نوقفها أو ننهيها كليًا أو جزئيًا لأسباب تجارية أو تقنية أو قانونية، مع إشعار مسبق مناسب عند الاقتضاء. وإذا خالفت هذه الشروط جاز لنا إنهاء تقديم الخدمة لك في أي وقت.'],
      ['٩. القانون الحاكم وتسوية النزاعات', 'تخضع هذه الشروط لقوانين جمهورية سنغافورة. وأي نزاع ينشأ عنها أو يتصل بها يُسوّى أولًا عبر التفاوض بحسن نية؛ وإن تعذّر ذلك جاز لأي طرف عرض النزاع على المحكمة المختصة في مقر الشركة. ولا يحرمك ذلك من حماية قوانين المستهلك الإلزامية في بلد إقامتك.'],
      ['١٠. حقوقك الاستهلاكية المحلية', 'إذا كنت مستهلكًا فقد تكون لك حقوق قانونية إلزامية بموجب قانون بلد إقامتك (مثل حقوق التراجع أو الاسترداد في الاتحاد الأوروبي). ولا يؤثّر أي بند في هذه الشروط على تلك الحقوق الإلزامية.'],
      ['١١. تعديل الشروط', 'قد نُحدّث هذه الشروط من حين لآخر. وسننشر النسخة المُحدّثة داخل الخدمة مع تحديث تاريخ «آخر تحديث». ومتابعتك استخدام FalconFlix بعد التحديث تعني قبولك للشروط المعدّلة.'],
      ['١٢. تواصل معنا', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app.'],
    ],
  ),
  'fr': LegalDocData(
    title: 'Conditions d’utilisation',
    updated: _kUpdated,
    intro:
        'Bienvenue sur FalconFlix. Les présentes Conditions d’utilisation (les « Conditions ») constituent un accord contraignant entre vous et FALCONFLIX-SINGAPORE-TECH PTE. LTD. (la « Société », « nous »), '
        'régissant votre utilisation de FalconFlix et de ses services de streaming de dramas courts, d’interaction avec des personnages IA et d’avantages virtuels (Eagle Coins). '
        'Veuillez les lire attentivement. En vous inscrivant, en vous connectant ou en utilisant FalconFlix, vous confirmez les avoir lues, comprises et acceptées.',
    sections: [
      ['1. Le Service', 'FalconFlix est une plateforme premium de streaming de dramas courts et de divertissement interactif pour un public mondial. Elle fournit principalement : des dramas courts à la demande ; l’interaction avec des personnages virtuels IA ; la recharge et l’utilisation de l’avantage virtuel « Eagle Coins » ; et des fonctions associées telles que recommandations, favoris et partage. Nous pouvons optimiser, ajuster ou étendre le Service en continu ; les fonctions réelles dépendent de la version que vous utilisez.'],
      ['2. Inscription et sécurité du compte', 'Vous pouvez vous inscrire et vous connecter par e-mail, Google ou Apple. Vous devez fournir des informations exactes et protéger vos identifiants. Vous êtes responsable de toute activité sur votre compte. En cas d’utilisation non autorisée ou de problème de sécurité, contactez immédiatement support@falconflix.app.'],
      ['3. Eagle Coins et paiement', 'Les « Eagle Coins » sont un avantage virtuel utilisé dans FalconFlix pour débloquer des épisodes et participer à l’interaction IA. Ils ne s’utilisent que dans le Service, n’ont pas valeur de monnaie légale, et ne peuvent être échangés contre des espèces, ni transférés ou utilisés hors du Service.', 'Les recharges sont traitées par notre prestataire tiers Stripe et facturées en dollars américains (USD). Sauf si la loi l’exige ou si nous l’acceptons expressément par écrit, les Eagle Coins achetés ou utilisés ne sont pas remboursables. Les offres, prix et montants crédités sont ceux affichés au moment de l’achat.'],
      ['4. Conduite de l’utilisateur', 'Vous vous engagez à utiliser le Service licitement et à ne pas l’employer pour une activité contraire aux lois applicables ou à l’ordre public, y compris, sans s’y limiter : publier des contenus illicites ou contrefaisants ; diffuser des logiciels malveillants ; enregistrer ou copier des contenus du Service sans autorisation ; faire de l’ingénierie inverse ou perturber le Service ; ou obtenir illicitement des Eagle Coins ou les informations de comptes d’autrui. En cas de manquement, nous pouvons restreindre des fonctions, suspendre ou fermer le compte, et nous réservons le droit d’agir en justice.'],
      ['5. Propriété intellectuelle', 'Tout le contenu du Service — dramas, séquences, audio et vidéo, textes, interface, marques, logos et images de personnages IA — appartient à la Société ou à ses concédants et est protégé par la loi applicable. Vous ne pouvez le copier, distribuer, adapter, louer ou exploiter commercialement sans l’autorisation écrite du titulaire des droits.'],
      ['6. Services tiers', 'Le Service intègre une connexion tierce (Google, Apple) et un paiement tiers (Stripe). En utilisant ces fonctions, vous devez aussi respecter les accords et politiques du tiers concerné. Les problèmes dus à un service tiers relèvent de la responsabilité de ce tiers selon ses propres conditions.'],
      ['7. Exclusions et limitation de responsabilité', 'Le Service est fourni « en l’état ». Dans la mesure maximale permise par la loi, nous ne garantissons pas qu’il sera ininterrompu ou sans erreur, et ne sommes pas responsables des pertes dues à la force majeure, aux pannes réseau, aux tiers ou à vos propres actes. En tout état de cause, notre responsabilité totale envers vous n’excédera pas les sommes que vous avez effectivement payées pour le Service concerné. Rien ne limite une responsabilité qui ne peut l’être selon la loi.'],
      ['8. Modification et résiliation du Service', 'Nous pouvons modifier, suspendre ou résilier tout ou partie du Service pour des raisons commerciales, techniques ou légales, avec un préavis raisonnable le cas échéant. Si vous enfreignez les Conditions, nous pouvons cesser de vous fournir le Service à tout moment.'],
      ['9. Droit applicable et litiges', 'Les présentes Conditions sont régies par le droit de la République de Singapour. Tout litige qui en découle sera d’abord résolu de bonne foi par la négociation ; à défaut, chaque partie peut le soumettre au tribunal compétent du lieu de la Société. Cela ne vous prive pas de la protection des lois impératives de consommation de votre pays de résidence.'],
      ['10. Vos droits de consommateur locaux', 'Si vous êtes consommateur, vous pouvez disposer de droits légaux impératifs selon la loi de votre pays de résidence (par exemple un droit de rétractation ou de remboursement dans l’UE). Rien dans ces Conditions n’affecte ces droits impératifs.'],
      ['11. Modifications des Conditions', 'Nous pouvons mettre à jour ces Conditions de temps à autre. La version mise à jour sera publiée dans le Service avec une date de « dernière mise à jour ». Si vous continuez à utiliser FalconFlix après une mise à jour, vous êtes réputé accepter les Conditions révisées.'],
      ['12. Nous contacter', 'FALCONFLIX-SINGAPORE-TECH PTE. LTD. — support@falconflix.app.'],
    ],
  ),
};
