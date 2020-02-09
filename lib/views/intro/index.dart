import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:Tether/domain/index.dart';
import 'package:Tether/domain/user/model.dart';

// Styling Widgets
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:Tether/global/dimensions.dart';

// Local Components
import './landing.dart';
import './first.dart';
import './second.dart';
import './third.dart';
import './action.dart';

class Intro extends StatefulWidget {
  const Intro({Key key}) : super(key: key);

  IntroState createState() => IntroState();
}

class IntroState extends State<Intro> {
  final String title = 'Intro';

  int currentStep = 0;
  bool onboarding = false;
  String loginText = 'Already have a username?';
  // TODO: document SwiperController swipeController; // RIP
  PageController pageController;

  final List<Widget> sections = [
    LandingSection(),
    FirstSection(),
    SecondSection(),
    ThirdSection(),
    ActionSection(),
  ];

  IntroState({Key key});

  @override
  void initState() {
    // TODO: document swipeController = SwiperController(); RIP
    pageController = PageController(
      initialPage: 0,
      keepPage: false,
      viewportFraction: 1.5,
    );
  }

  Widget buildButtonText() {
    switch (currentStep) {
      case 0:
        return const Text('let\'s go',
            style: TextStyle(fontSize: 20, color: Colors.white));
      case 4:
        return const Text('count me in',
            style: TextStyle(fontSize: 20, color: Colors.white));
      default:
        return const Text('next',
            style: TextStyle(fontSize: 20, color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final double widgetWidthScaling = width * 0.725;

    // TODO: document Swiper(
    //   loop: false,
    //   itemCount: 5,
    //   controller: swipeController,
    //   itemBuilder: (BuildContext context, int index) {
    //     return sections[index];
    //   },
    //   onIndexChanged: (index) {
    //     setState(() {
    //       currentStep = index;
    //     });
    //   },
    // ),

    return Scaffold(
      body: StoreConnector<AppState, AppState>(
        converter: (Store<AppState> store) => store.state,
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: Container(
                height: widgetWidthScaling,
                constraints: BoxConstraints(
                  minWidth: 125,
                  minHeight: 345,
                  maxHeight: 400,
                ),
                child: PageView(
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  controller: pageController,
                  children: sections,
                  onPageChanged: (index) {
                    setState(() {
                      currentStep = index;
                      onboarding = index != 0 && index != sections.length - 1;
                    });
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: widgetWidthScaling,
                    height: DEFAULT_BUTTON_HEIGHT,
                    constraints: BoxConstraints(
                      minWidth: MIN_BUTTON_WIDTH,
                      maxWidth: MAX_BUTTON_WIDTH,
                    ),
                    child: FlatButton(
                      onPressed: () {
                        if (currentStep == 0) {
                          setState(() {
                            onboarding = true;
                          });
                        }

                        if (currentStep == sections.length - 2) {
                          setState(() {
                            loginText = 'Already created a username?';
                            onboarding = false;
                          });
                        }

                        if (currentStep == sections.length - 1) {
                          return Navigator.pushNamed(
                            context,
                            '/signup',
                          );
                        }
                        // TODO: document swipeController.next(animation: true);
                        pageController.nextPage(
                          duration: Duration(milliseconds: 350),
                          curve: Curves.ease,
                        );
                      },
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      child: buildButtonText(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 16,
              ),
              constraints: BoxConstraints(
                minWidth: 200,
                minHeight: DEFAULT_BUTTON_HEIGHT,
              ),
              child: onboarding
                  ? Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmoothPageIndicator(
                          controller: pageController, // PageController
                          count: sections.length,
                          effect: WormEffect(
                            spacing: 16,
                            dotHeight: 12,
                            dotWidth: 12,
                            activeDotColor: Color(
                              state.settingsStore.primaryColor,
                            ),
                          ), // your preferred effect
                        ),
                      ],
                    )
                  : TouchableOpacity(
                      activeOpacity: 0.4,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/login',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            loginText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w100,
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
