import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_post_cubit.dart';
import 'package:social4/service/app_routes.dart';
import 'package:social4/service/shared_preference_service.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection(
      {super.key,
      required this.profilePic,
      required this.userId,
      required this.userName,
      required this.name,
      required this.bio,
      this.callBack,
      this.isMe = false,
      required this.follower,
      required this.following,
      required this.isFollowedByMe,
      this.profilecubit});

  final ProfileCubit? profilecubit;
  final String profilePic;
  final String userId;
  final String userName;

  final String name;

  final String bio;
  final VoidCallback? callBack;
  final List follower;
  final List following;
  final bool isFollowedByMe;
  final bool isMe;

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection>
    with SingleTickerProviderStateMixin {
  final sharedPreferencesService = SharedPreferencesService();

  final _profilePostCubit = ProfilePostCubit();
  late TabController tabController;

  bool isFollowedByMe = false;
  @override
  void initState() {
    super.initState();
    isFollowedByMe = widget.isFollowedByMe;
    tabController = TabController(length: 2, vsync: this);
    if (widget.isMe) {
      if ((context.read<ProfilePostCubit>().state is! ProfilePostLoaded)) {
        context.read<ProfilePostCubit>().fetchPosts(
            isRefresh: true,
            userModelData: UserModel(
                id: widget.userId,
                name: widget.name,
                username: widget.userName,
                profilePic: widget.profilePic,
                bio: widget.bio));
      }
    } else {
      _profilePostCubit.fetchPosts(
          isRefresh: true,
          userModelData: UserModel(
              id: widget.userId,
              name: widget.name,
              username: widget.userName,
              profilePic: widget.profilePic,
              bio: widget.bio));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = sharedPreferencesService.getString("userID");

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 85,
                              width: 85,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  image: widget.profilePic.isNotEmpty
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.profilePic),
                                          fit: BoxFit.cover)
                                      : null),
                              alignment: Alignment.center,
                              child: widget.profilePic.isEmpty
                                  ? Text(
                                      (widget.name.isNotEmpty
                                              ? widget.name
                                              : widget.userName.isNotEmpty
                                                  ? widget.userName
                                                  : "")
                                          .toLowerCase()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 42),
                                    )
                                  : null,
                            ),
                            Spacer(),
                            widget.isMe
                                ? Container(
                                    height: 60,
                                    width: 80,
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 16, right: 12),
                                    child: CustomButton(
                                      text: "Edit",
                                      onPressed: widget.callBack ?? () {},
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color(0xff08051B)),
                                      textColor: const Color(0xff08051B),
                                      textSize: 14,
                                      width: 50,
                                    ),
                                  )
                                : Container(
                                    // padding: EdgeInsets.symmetric(vertical: 12),
                                    height: 30,
                                    width: 100,
                                    child: CustomButton(
                                      text: isFollowedByMe
                                          ? "Following"
                                          : "Follow",
                                      onPressed: () {
                                        setState(() {
                                          isFollowedByMe = !isFollowedByMe;
                                        });
                                        widget.profilecubit!
                                            .followUser(widget.userId)
                                            .then((value) {
                                          widget.profilecubit
                                              ?.fetchUserProfile(widget.userId);
                                        });
                                      },
                                      border: isFollowedByMe
                                          ? Border.all(
                                              color: const Color(0xff08051B))
                                          : null,
                                      textSize: 14,
                                      textColor: isFollowedByMe
                                          ? Colors.black
                                          : Colors.white,
                                      color: isFollowedByMe
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  )
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                                text: widget.name,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                            CustomText(
                                text: "@${widget.userName}",
                                textColor: const Color(0xff384747),
                                fontSize: 14,
                                fontWeight: FontWeight.w400)
                          ],
                        ),
                        // SizedBox(
                        //   height: 12,
                        // ),
                        widget.bio.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  CustomText(
                                      text: widget.bio,
                                      // textColor: Color(0xff726E80),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ],
                              ),
                        // const SizedBox(
                        //   height: 16,
                        // ),
                        // Row(
                        //   children: const [
                        //     Icon(
                        //       Icons.calendar_month_outlined,
                        //       color: Color(0xff726E80),
                        //       size: 18,
                        //     ),
                        //     SizedBox(
                        //       width: 4,
                        //     ),
                        //     CustomText(
                        //         text: "Joined July 16, 2024",
                        //         textColor: Color(0xff726E80),
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w400),
                        //   ],
                        // ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            CustomText(
                                text: widget.following.length.toString(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.followingFollowers,
                                    arguments: {
                                      'user': UserModel(
                                          id: widget.userId,
                                          name: widget.name,
                                          username: widget.userName,
                                          profilePic: widget.profilePic,
                                          bio: widget.bio,
                                          followers: widget.follower,
                                          following: widget.following)
                                    });
                              },
                              child: CustomText(
                                  text: "Following",
                                  textColor: const Color(0xff726E80),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            CustomText(
                                text: widget.follower.length.toString(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.followingFollowers,
                                    arguments: {
                                      'user': UserModel(
                                          id: widget.userId,
                                          name: widget.name,
                                          username: widget.userName,
                                          profilePic: widget.profilePic,
                                          bio: widget.bio,
                                          followers: widget.follower,
                                          following: widget.following)
                                    });
                              },
                              child: CustomText(
                                  text: "Followers",
                                  textColor: const Color(0xff726E80),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _SliverAppBarDelegate(
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
                          color: Color(
                              0xff5348EE), // Custom color for the underline
                          width: 3.0, // Custom thickness for the underline
                        ),
                      ),
                    ),
                    tabs: const [
                      Tab(
                        text: "Post",
                      ),
                      Tab(
                        text: "Media",
                      ),
                    ]),
              ),
            ),
          ];
        },
        body: TabBarView(controller: tabController, children: [
          BlocBuilder<ProfilePostCubit, ProfilePostState>(
            bloc: !widget.isMe ? _profilePostCubit : null,
            builder: (context, state) {
              switch (state.runtimeType) {
                case ProfilePostLoaded:
                  final successState = state as ProfilePostLoaded;

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (widget.isMe) {
                        await context.read<ProfilePostCubit>().fetchPosts(
                            isRefresh: true,
                            userModelData: UserModel(
                                id: widget.userId,
                                name: widget.name,
                                username: widget.userName,
                                profilePic: widget.profilePic,
                                bio: widget.bio));
                      } else {
                        await _profilePostCubit.fetchPosts(
                            isRefresh: true,
                            userModelData: UserModel(
                                id: widget.userId,
                                name: widget.name,
                                username: widget.userName,
                                profilePic: widget.profilePic,
                                bio: widget.bio));
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                            successState.posts.length + (state.hasMore ? 1 : 0),
                            (index) {
                          if (index == successState.posts.length) {
                            EasyDebounce.debounce('paginate_post',
                                const Duration(milliseconds: 500), () {
                              if (widget.isMe) {
                                context.read<ProfilePostCubit>().fetchPosts(
                                    userModelData: UserModel(
                                        id: widget.userId,
                                        name: widget.name,
                                        username: widget.userName,
                                        profilePic: widget.profilePic,
                                        bio: widget.bio));
                              } else {
                                _profilePostCubit.fetchPosts(
                                    userModelData: UserModel(
                                        id: widget.userId,
                                        name: widget.name,
                                        username: widget.userName,
                                        profilePic: widget.profilePic,
                                        bio: widget.bio));
                              }
                            });
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final post = successState.posts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.postDetail,
                                  arguments: {"postId": post.postId});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color(0xffECECEE)))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                              image: post
                                                      .userProfilePic.isNotEmpty
                                                  ? DecorationImage(
                                                      image: CachedNetworkImageProvider(
                                                          post.userProfilePic),
                                                      fit: BoxFit.cover)
                                                  : null),
                                          alignment: Alignment.center,
                                          child: post.userProfilePic.isNotEmpty
                                              ? null
                                              : CustomText(
                                                  text: (post.name.isNotEmpty
                                                          ? post.name
                                                          : post.userName
                                                                  .isNotEmpty
                                                              ? post.userName
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
                                                text: post.name,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            CustomText(
                                                text: "@${post.userName}",
                                                textColor:
                                                    const Color(0xff384747),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  post.content.isEmpty
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: CustomText(
                                              text: post.content,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400)),
                                  SizedBox(
                                    height: post.content.isEmpty ? 0 : 12,
                                  ),
                                  post.img.isNotEmpty
                                      ? Container(
                                          width: double.infinity,
                                          constraints: const BoxConstraints(
                                              maxHeight: 250, minHeight: 200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          // width: 45,
                                          decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          post.img),
                                                  fit: BoxFit.cover)),
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                    height: post.img.isNotEmpty ? 12 : 0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (post.isLikedByCurrentUser) {
                                              if (widget.isMe) {
                                                context
                                                    .read<ProfilePostCubit>()
                                                    .unlikePost(post.postId);
                                              } else {
                                                _profilePostCubit
                                                    .unlikePost(post.postId);
                                              }
                                            } else {
                                              if (widget.isMe) {
                                                context
                                                    .read<ProfilePostCubit>()
                                                    .likePost(post.postId);
                                              } else {
                                                _profilePostCubit
                                                    .likePost(post.postId);
                                              }
                                            }
                                          },
                                          // child: Icon(
                                          //     post.isLikedByCurrentUser
                                          //         ? Icons.favorite
                                          //         : Icons
                                          //             .favorite_outline_rounded,
                                          //     size: 24,
                                          //     color: post.isLikedByCurrentUser
                                          //         ? Colors.red
                                          //         : const Color(0xff726E80)),
                                          child: SvgPicture.asset(
                                            post.isLikedByCurrentUser
                                                ? 'assets/images/favorite-filled.svg'
                                                : 'assets/images/favorite.svg',
                                            height: 24,
                                          ),
                                        ),
                                        post.likes < 1
                                            ? const SizedBox()
                                            : Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  CustomText(
                                                    text: post.likes.toString(),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        SvgPicture.asset(
                                          'assets/images/comment-outline.svg',
                                          height: 26,
                                        ),
                                        post.commentCount < 1
                                            ? const SizedBox()
                                            : Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  CustomText(
                                                    text: post.commentCount
                                                        .toString(),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ],
                                              ),
                                        // const SizedBox(
                                        //   width: 16,
                                        // ),
                                        // const Icon(
                                        //   Icons.share,
                                        //   size: 24,
                                        //   color: Color(0xff726E80),
                                        // ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );

                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          BlocBuilder<ProfilePostCubit, ProfilePostState>(
            bloc: !widget.isMe ? _profilePostCubit : null,
            builder: (context, state) {
              switch (state.runtimeType) {
                case ProfilePostLoaded:
                  final successState = state as ProfilePostLoaded;
                  final postList = successState.posts
                      .where((element) => element.img.isNotEmpty)
                      .toList();
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (widget.isMe) {
                        await context.read<ProfilePostCubit>().fetchPosts(
                            isRefresh: true,
                            userModelData: UserModel(
                                id: widget.userId,
                                name: widget.name,
                                username: widget.userName,
                                profilePic: widget.profilePic,
                                bio: widget.bio));
                      } else {
                        await _profilePostCubit.fetchPosts(
                            isRefresh: true,
                            userModelData: UserModel(
                                id: widget.userId,
                                name: widget.name,
                                username: widget.userName,
                                profilePic: widget.profilePic,
                                bio: widget.bio));
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                            postList.length + (state.hasMore ? 1 : 0), (index) {
                          if (index == successState.posts.length) {
                            EasyDebounce.debounce('paginate_post',
                                const Duration(milliseconds: 500), () {
                              if (widget.isMe) {
                                context.read<ProfilePostCubit>().fetchPosts(
                                    userModelData: UserModel(
                                        id: widget.userId,
                                        name: widget.name,
                                        username: widget.userName,
                                        profilePic: widget.profilePic,
                                        bio: widget.bio));
                              } else {
                                _profilePostCubit.fetchPosts(
                                    userModelData: UserModel(
                                        id: widget.userId,
                                        name: widget.name,
                                        username: widget.userName,
                                        profilePic: widget.profilePic,
                                        bio: widget.bio));
                              }
                            });
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final post = postList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.postDetail,
                                  arguments: {"postId": post.postId});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color(0xffECECEE)))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                              image: post
                                                      .userProfilePic.isNotEmpty
                                                  ? DecorationImage(
                                                      image: CachedNetworkImageProvider(
                                                          post.userProfilePic),
                                                      fit: BoxFit.cover)
                                                  : null),
                                          alignment: Alignment.center,
                                          child: post.userProfilePic.isNotEmpty
                                              ? null
                                              : CustomText(
                                                  text: (post.name.isNotEmpty
                                                          ? post.name
                                                          : post.userName
                                                                  .isNotEmpty
                                                              ? post.userName
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
                                                text: post.name,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            CustomText(
                                                text: "@${post.userName}",
                                                textColor:
                                                    const Color(0xff384747),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  post.content.isEmpty
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: CustomText(
                                              text: post.content,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400)),
                                  SizedBox(
                                    height: post.content.isEmpty ? 0 : 12,
                                  ),
                                  post.img.isNotEmpty
                                      ? Container(
                                          width: double.infinity,
                                          constraints: const BoxConstraints(
                                              maxHeight: 250, minHeight: 200),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          // width: 45,
                                          decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          post.img),
                                                  fit: BoxFit.cover)),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (post.isLikedByCurrentUser) {
                                              if (widget.isMe) {
                                                context
                                                    .read<ProfilePostCubit>()
                                                    .unlikePost(post.postId);
                                              } else {
                                                _profilePostCubit
                                                    .unlikePost(post.postId);
                                              }
                                            } else {
                                              if (widget.isMe) {
                                                context
                                                    .read<ProfilePostCubit>()
                                                    .likePost(post.postId);
                                              } else {
                                                _profilePostCubit
                                                    .likePost(post.postId);
                                              }
                                            }
                                          },
                                          // child: Icon(
                                          //     post.isLikedByCurrentUser
                                          //         ? Icons.favorite
                                          //         : Icons
                                          //             .favorite_outline_rounded,
                                          //     size: 24,
                                          //     color: post.isLikedByCurrentUser
                                          //         ? Colors.red
                                          //         : const Color(0xff726E80)),
                                          child: SvgPicture.asset(
                                            post.isLikedByCurrentUser
                                                ? 'assets/images/favorite-filled.svg'
                                                : 'assets/images/favorite.svg',
                                            height: 24,
                                          ),
                                        ),
                                        post.likes < 1
                                            ? const SizedBox()
                                            : Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  CustomText(
                                                    text: post.likes.toString(),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        SvgPicture.asset(
                                          'assets/images/comment-outline.svg',
                                          height: 26,
                                        ),
                                        post.commentCount < 1
                                            ? const SizedBox()
                                            : Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  CustomText(
                                                    text: post.commentCount
                                                        .toString(),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ],
                                              ),
                                        // const SizedBox(
                                        //   width: 16,
                                        // ),
                                        // const Icon(
                                        //   Icons.share,
                                        //   size: 24,
                                        //   color: Color(0xff726E80),
                                        // ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );

                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ]),
      ),
    ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
