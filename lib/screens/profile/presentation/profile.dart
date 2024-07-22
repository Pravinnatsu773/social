import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_post_cubit.dart';
import 'package:social4/screens/profile/presentation/profile_section.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/shared_preference_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  final sharedPreferencesService = SharedPreferencesService();
  late TabController tabController;

  // String profilePic = "";
  // String userId = "";
  // String userName = "";

  // String name = "";

  // String bio = "";

  @override
  void initState() {
    super.initState();
    initializeUserData();
    tabController = TabController(length: 3, vsync: this);
  }

  initializeUserData() {
    // userId = sharedPreferencesService.getString("userID") ?? "";
    // name = sharedPreferencesService.getString("name") ?? "";
    // userName = sharedPreferencesService.getString("userName") ?? "";
    // profilePic = sharedPreferencesService.getString("profilePic") ?? "";

    // bio = sharedPreferencesService.getString("bio") ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case ProfileLoaded:
            final data = (state as ProfileLoaded).userProfile;

            return ProfileSection(
                profilePic: data.profilePic,
                userId: data.id,
                userName: data.username,
                name: data.name,
                bio: data.bio,
                follower: data.followers ?? [],
                following: data.following ?? [],
                isMe: true,
                isFollowedByMe: false,
                callBack: () {
                  Navigator.pushNamed(context, AppRoutes.editProfile,
                      arguments: {"callBack": () {}}).then((value) {
                    final userId =
                        sharedPreferencesService.getString("userID") ?? "";
                    context
                        .read<ProfileCubit>()
                        .fetchUserProfile(userId)
                        .then((value) {
                      context.read<ProfilePostCubit>().fetchPosts(
                            isRefresh: true,
                          );
                    });
                  });
                });

          default:
            return Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
