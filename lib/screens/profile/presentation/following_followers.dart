import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/profile/cubit/followers_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/service/app_routes.dart';

class FollowingFollowers extends StatefulWidget {
  const FollowingFollowers({super.key, required this.user});

  final UserModel user;

  @override
  State<FollowingFollowers> createState() => _FollowingFollowersState();
}

class _FollowingFollowersState extends State<FollowingFollowers>
    with SingleTickerProviderStateMixin {
  final followersCubit = FollowersCubit();
  late TabController tabController;
  @override
  void initState() {
    super.initState();

    followersCubit.fetchFollowingUsers(widget.user.id,
        widget.user.followers ?? [], widget.user.following ?? []);

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          widget.user.username,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Icon(Icons.notifications_outlined),
          // )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
                // onTap: (value) {
                //   if (value == 0) {
                //     context
                //         .read<ProfilePostCubit>()
                //         .fetchPosts(isRefresh: true);
                //   }
                // },
                controller: tabController,
                labelColor: const Color(0xff08051B),
                unselectedLabelStyle: const TextStyle(
                    color: Color(0xff726E80),
                    // fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
                labelStyle: const TextStyle(
                    color: Color(0xff08051B),
                    // fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          Color(0xff5348EE), // Custom color for the underline
                      width: 3.0, // Custom thickness for the underline
                    ),
                  ),
                ),
                tabs: const [
                  Tab(
                    text: "Followers",
                  ),
                  Tab(
                    text: "Following",
                  ),
                  // Tab(
                  //   text: "Comments",
                  // ),
                ]),
            SizedBox(
              height: 16,
            ),
            BlocBuilder<FollowersCubit, FollowersState>(
              bloc: followersCubit,
              builder: (context, state) {
                switch (state.runtimeType) {
                  case FollowersLoaded:
                    final followers = (state as FollowersLoaded).followerUsers;

                    final following = (state).followingUsers;
                    return Expanded(
                      child: TabBarView(controller: tabController, children: [
                        ListView.builder(
                            itemCount: followers.length,
                            itemBuilder: (context, index) {
                              final userData = followers[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.friendsProfileDetail,
                                      arguments: {
                                        'userId': userData.id,
                                        "userName": userData.username
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            image: userData
                                                    .profilePic.isNotEmpty
                                                ? DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            userData
                                                                .profilePic),
                                                    fit: BoxFit.cover)
                                                : null),
                                        alignment: Alignment.center,
                                        child: userData.profilePic.isNotEmpty
                                            ? null
                                            : CustomText(
                                                text: (userData.name.isNotEmpty
                                                        ? userData.name
                                                        : userData.username
                                                                .isNotEmpty
                                                            ? userData.username
                                                            : "")
                                                    .toLowerCase()
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                fontSize: 18,
                                                textColor: Colors.white,
                                              ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                              text: userData.name,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                          CustomText(
                                              text: "@${userData.username}",
                                              textColor:
                                                  const Color(0xff726E80),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ListView.builder(
                            itemCount: following.length,
                            itemBuilder: (context, index) {
                              final userData = following[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.friendsProfileDetail,
                                      arguments: {
                                        'userId': userData.id,
                                        "userName": userData.username
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            image: userData
                                                    .profilePic.isNotEmpty
                                                ? DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            userData
                                                                .profilePic),
                                                    fit: BoxFit.cover)
                                                : null),
                                        alignment: Alignment.center,
                                        child: userData.profilePic.isNotEmpty
                                            ? null
                                            : CustomText(
                                                text: (userData.name.isNotEmpty
                                                        ? userData.name
                                                        : userData.username
                                                                .isNotEmpty
                                                            ? userData.username
                                                            : "")
                                                    .toLowerCase()
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                fontSize: 18,
                                                textColor: Colors.white,
                                              ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                              text: userData.name,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                          CustomText(
                                              text: "@${userData.username}",
                                              textColor:
                                                  const Color(0xff726E80),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ]),
                    );
                  default:
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
