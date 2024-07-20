import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/screens/profile/presentation/profile_section.dart';

class FreindsProfileDetail extends StatefulWidget {
  final String userId;
  final String userName;
  const FreindsProfileDetail(
      {super.key, required this.userId, required this.userName});

  @override
  State<FreindsProfileDetail> createState() => _FreindsProfileDetailState();
}

class _FreindsProfileDetailState extends State<FreindsProfileDetail> {
  final _profileCubit = ProfileCubit();

  @override
  void initState() {
    super.initState();

    _profileCubit.fetchUserProfile(widget.userId);
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
          widget.userName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: Icon(Icons.notifications_outlined),
          // )
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        bloc: _profileCubit,
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
                isMe: false,
              );

            default:
              return SizedBox();
          }
        },
      ),
    );
  }
}
