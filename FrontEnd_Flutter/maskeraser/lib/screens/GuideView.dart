import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:maskeraser/main.dart';

class GuideView extends StatefulWidget {
  @override
  _GuideViewState createState() => _GuideViewState();
}

class _GuideViewState extends State<GuideView> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/intro/$assetName',
        width: double.infinity, height: double.infinity, fit: BoxFit.fill);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 12.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      //bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.fromLTRB(16.0, 22.0, 16.0, 16.0),
    );

    return SafeArea(
      child: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
              title: "1. 이미지 선택",
              body: "마스크를 제거하고 싶은 이미지를 갤러리에서 선택!",
              image: _buildImage('img1.png'),
              decoration: pageDecoration.copyWith(
                bodyFlex: 1,
                imageFlex: 5,
                bodyAlignment: Alignment.bottomCenter,
                imageAlignment: Alignment.topCenter,
              )),
          PageViewModel(
              title: "2. 마스크 제거",
              body: "파란색 마스크 제거 버튼 클릭!",
              image: _buildImage('img2.png'),
              decoration: pageDecoration.copyWith(
                bodyFlex: 1,
                imageFlex: 5,
                bodyAlignment: Alignment.bottomCenter,
                imageAlignment: Alignment.topCenter,
              )),
          PageViewModel(
            title: "3. 확인",
            body: "변환된 이미지가 만족스럽다면 저장, 공유 기능을 활용하세요!",
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
          //spacing: const EdgeInsets.symmetric(horizontal: 3.0),
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
      ),
    );
  }
}
