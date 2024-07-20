import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/common/ui/posting_progress_ui.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/screens/post/cubit/comment_cubit.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/service/app_routes.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    if (context.read<PostCubit>().state is! PostLoaded) {
      context.read<PostCubit>().fetchPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<PostCubit>().fetchPosts(isRefresh: true);
        },
        child: SingleChildScrollView(
          child: Column(children: [
            PostingProgress(),
            BlocConsumer<PostCubit, PostState>(
              listener: (context, state) {
                if (state is PostLoaded) {
                  context.read<PostingProgressCubit>().done();
                }
              },
              builder: (context, state) {
                switch (state.runtimeType) {
                  case PostLoaded:
                    final successState = state as PostLoaded;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          successState.posts.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == successState.posts.length) {
                          paginate();
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
                                    top: BorderSide(color: Color(0xffECECEE)))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.friendsProfileDetail,
                                        arguments: {
                                          'userId': post.userId,
                                          "userName": post.userName
                                        });
                                  },
                                  child: Padding(
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
                                                    const Color(0xff726E80),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500)
                                          ],
                                        ),
                                      ],
                                    ),
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
                                            maxHeight: 350, minHeight: 200),
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
                                  height: post.img.isEmpty ? 0 : 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (post.isLikedByCurrentUser) {
                                            context
                                                .read<PostCubit>()
                                                .unlikePost(post.postId);
                                          } else {
                                            context
                                                .read<PostCubit>()
                                                .likePost(post.postId);
                                          }
                                        },
                                        child: Icon(
                                          post.isLikedByCurrentUser
                                              ? Icons.favorite
                                              : Icons.favorite_outline_rounded,
                                          size: 24,
                                          color: post.isLikedByCurrentUser
                                              ? Colors.red
                                              : const Color(0xff726E80),
                                        ),
                                      ),
                                      post.likes < 1
                                          ? SizedBox()
                                          : Row(
                                              children: [
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                CustomText(
                                                  text: post.likes.toString(),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ],
                                            ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, AppRoutes.postDetail,
                                              arguments: {
                                                "postId": post.postId
                                              });
                                        },
                                        child: Icon(Icons.mode_comment_outlined,
                                            size: 24,
                                            color: const Color(0xff726E80)),
                                      ),
                                      post.commentCount < 1
                                          ? SizedBox()
                                          : Row(
                                              children: [
                                                SizedBox(
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
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Icon(
                                        Icons.share,
                                        size: 24,
                                        color: const Color(0xff726E80),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );

                  default:
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child:
                            const Center(child: CircularProgressIndicator()));
                }
              },
            )
          ]),
        ),
      ),
    );
  }

  paginate() {
    try {
      EasyDebounce.debounce('paginate_post', const Duration(milliseconds: 500),
          () {
        context.read<PostCubit>().fetchPosts();
      });
    } catch (e) {}
  }
}
