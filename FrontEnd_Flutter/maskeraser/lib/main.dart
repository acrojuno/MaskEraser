import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maskeraser/screens/MainView.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),(Route<dynamic> route) => false
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/intro/$assetName', width: double.infinity, height: double.infinity, fit: BoxFit.fill);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 12.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.fromLTRB(16.0, 22.0, 16.0, 16.0),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
            title: "1. 이미지 선택",
            body:
            "마스크를 제거하고 싶은 이미지를 갤러리에서 선택!",
            image: _buildImage('img1.png'),
            decoration: pageDecoration.copyWith(
              bodyFlex: 1,
              imageFlex: 5,
              bodyAlignment: Alignment.bottomCenter,
              imageAlignment: Alignment.topCenter,
            )
        ),
        PageViewModel(
            title: "2. 마스크 제거",
            body:
            "파란색 마스크 제거 버튼 클릭!",
            image: _buildImage('img2.png'),
            decoration: pageDecoration.copyWith(
              bodyFlex: 1,
              imageFlex: 5,
              bodyAlignment: Alignment.bottomCenter,
              imageAlignment: Alignment.topCenter,
            )
        ),
        PageViewModel(
          title: "3. 확인",
          body:
          "변환된 이미지가 만족스럽다면 저장, 공유 기능을 활용하세요!",
          image: _buildImage('img3.png'),
          decoration: pageDecoration.copyWith(
            bodyFlex: 1,
            imageFlex: 5,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        // color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ScreenUtil : 반응형(크기에 따라 자동으로 크기 조절되는) 위젯을 만들기 위한 패키지
    return ScreenUtilInit(
      //디바이스 사이즈 설정(단위: dp)
      designSize: Size(320, 533),
      minTextAdapt: true,
      //splitScreenMode: true,
      builder: (_) => MaterialApp(
        builder: (context, widget) {
          ScreenUtil.init(context);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainView(),
      ),
    );
  }
}