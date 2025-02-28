import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:localite/models/custom_user.dart';
import 'package:localite/screens/user_screens/user_chatlist.dart';
import 'package:localite/screens/user_screens/user_home.dart';
import 'package:localite/screens/user_screens/user_pending_requests.dart';
import 'package:localite/screens/user_screens/user_profile.dart';
import 'package:provider/provider.dart';

class UserNavigatorHome extends StatefulWidget {
  @override
  _UserNavigatorHomeState createState() => _UserNavigatorHomeState();
}

class _UserNavigatorHomeState extends State<UserNavigatorHome> {
  int pageIndex = 0;
  final UserHomeScreen _userHomeScreen = UserHomeScreen();
  final UserChatList _userChat = UserChatList();
  final UserPendingRequests _userPendingRequests = UserPendingRequests();
  final UserProfile _userProfile = UserProfile();

  Widget _showPage = new UserHomeScreen();

  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return _userHomeScreen;
        break;

      case 1:
        return _userChat;
        break;

      case 2:
        return _userPendingRequests;

      default:
        return _userProfile;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    UserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserDetails(),
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          color: Color(0xffbbeaba),
          buttonBackgroundColor: Color(0xfff0ffeb),//Color(0xffbbeaba),
          backgroundColor:Color(0xffbbeaba),
          animationCurve: Curves.easeIn,
          animationDuration: Duration(
            milliseconds: 390,
          ),
          height: 50,
          items: [
            // Icon(
            //   Icons.home_filled,
            //   size: 20,
            // ),
            SvgPicture.asset('assets/images/appIcon.svg',height: 20, width: 20,),
            //todo change icons
            Icon(
              Icons.chat,
              size: 20,
            ),
            Icon(
              Icons.more_time_sharp,
              size: 20,
            ),
            Icon(
              Icons.person,
              size: 20,
            ),
          ],
          onTap: (index) {
            setState(() {
              _showPage = _pageChooser(index);
            });
          },
        ),
        body: Center(
          child: _showPage,
        ),
      ),
    );
  }
}
