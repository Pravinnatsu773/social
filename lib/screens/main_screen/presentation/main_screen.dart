import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/screens/communities/presentation/community.dart';
import 'package:social4/screens/home/presentation/home.dart';
import 'package:social4/screens/main_screen/cubit/bottom_nav_cubit.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_post_cubit.dart';
import 'package:social4/screens/profile/presentation/profile.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/notification_service.dart';
import 'package:social4/service/shared_preference_service.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [
    const HomeTab(),
    Community(),
    SizedBox(),
    SettingsTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    final userId = SharedPreferencesService().getString("userID") ?? "";

    context.read<ProfileCubit>().fetchUserProfile(userId);
    NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: null,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: Text(
              "Sezen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  if (state == 4) {
                    Navigator.pushNamed(context, AppRoutes.settingScreen);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(state == 4 ? Icons.settings_outlined : null),
                ),
              )
            ],
          ),
          backgroundColor: Colors.white,
          body: _pages[state],
          bottomNavigationBar: _CustomBottomNavigationBar(),
        );
      },
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            icon: Icons.home,
            label: 'Home',
          ),
          _NavItem(
            index: 1,
            icon: Icons.groups,
            label: 'Groups',
          ),
          _NavItem(
            index: 2,
            icon: Icons.add_box_outlined,
            label: 'create post',
          ),
          _NavItem(
            index: 3,
            icon: Icons.notifications_outlined,
            label: 'notification',
          ),
          _NavItem(
            index: 4,
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;

  _NavItem({
    required this.index,
    required this.icon,
    required this.label,
  });

  final sharedPreferencesService = SharedPreferencesService();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select((BottomNavCubit cubit) => cubit.state);
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.pushNamed(context, AppRoutes.createPostScreen, arguments: {
            "callBack": (String content, File? image) {
              final id = sharedPreferencesService.getString("userID");
              final name = sharedPreferencesService.getString("name");
              final username = sharedPreferencesService.getString("userName");
              final profilePic =
                  sharedPreferencesService.getString("profilePic");

              final bio = sharedPreferencesService.getString("bio");
              context.read<BottomNavCubit>().updateIndex(0);
              context.read<PostingProgressCubit>().inProgress();
              context.read<PostCubit>().addPost(content, image).then((value) {
                context.read<ProfilePostCubit>().fetchPosts(
                    isRefresh: true,
                    userModelData: UserModel(
                        id: id ?? "",
                        name: name ?? "",
                        username: username ?? "",
                        profilePic: profilePic ?? "",
                        bio: bio ?? ""));
              });
            }
          });
        } else {
          context.read<BottomNavCubit>().updateIndex(index);
        }
      },
      child: Icon(
        icon,
        color: isSelected ? const Color(0xff0A071C) : const Color(0xff8D8A99),
        size: 28,
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notifications'),
    );
  }
}
