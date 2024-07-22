import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_input_field.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/post/cubit/comment_cubit.dart';
import 'package:social4/screens/post/cubit/post_detail_cubit.dart';
import 'package:social4/service/app_routes.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  const PostDetail({super.key, required this.postId});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _commnetController = TextEditingController();
  bool allowReply = false;
  final focusNode = FocusNode();

  Comment? selectedCommnet;

  List<Comment> viewCommnets = [];
  @override
  void initState() {
    super.initState();

    context.read<PostDetailCubit>().getPostById(widget.postId);

    context.read<CommentCubit>().fetchComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (focusNode.hasFocus) {
          focusNode.unfocus();
        }
        context.read<PostDetailCubit>().reset();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // centerTitle: true,
          title: const CustomText(
            text: "Post",
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: BlocBuilder<PostDetailCubit, PostDetailState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case PostDetailLoaded:
                  final successState = state as PostDetailLoaded;
                  final post = successState.post;
                  return Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: Color(0xffECECEE)))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            AppRoutes.friendsProfileDetail,
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
                                                  image: post.userProfilePic
                                                          .isNotEmpty
                                                      ? DecorationImage(
                                                          image: CachedNetworkImageProvider(
                                                              post.userProfilePic),
                                                          fit: BoxFit.cover)
                                                      : null),
                                              alignment: Alignment.center,
                                              child: post
                                                      .userProfilePic.isNotEmpty
                                                  ? null
                                                  : CustomText(
                                                      text: (post.name
                                                                  .isNotEmpty
                                                              ? post.name
                                                              : post.userName
                                                                      .isNotEmpty
                                                                  ? post
                                                                      .userName
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
                                                    fontWeight:
                                                        FontWeight.w600),
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
                                                context
                                                    .read<PostDetailCubit>()
                                                    .unlikePost(post.postId);
                                              } else {
                                                context
                                                    .read<PostDetailCubit>()
                                                    .likePost(post.postId);
                                              }
                                            },
                                            child: Icon(
                                              post.isLikedByCurrentUser
                                                  ? Icons.favorite
                                                  : Icons
                                                      .favorite_outline_rounded,
                                              size: 24,
                                              color: post.isLikedByCurrentUser
                                                  ? Colors.red
                                                  : const Color(0xff3F3D4E),
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
                                                      text:
                                                          post.likes.toString(),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          GestureDetector(
                                            onTap: () {},
                                            child: const Icon(
                                              Icons.mode_comment_outlined,
                                              size: 24,
                                              color: Color(0xff3F3D4E),
                                            ),
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          const Icon(
                                            Icons.share,
                                            size: 24,
                                            color: Color(0xff3F3D4E),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                              ),
                              BlocBuilder<CommentCubit, CommentState>(
                                builder: (context, state) {
                                  switch (state.runtimeType) {
                                    case CommentLoaded:
                                      final successState =
                                          state as CommentLoaded;

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: successState.comments.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final comment =
                                              successState.comments[index];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                decoration: const BoxDecoration(
                                                    // border: Border(
                                                    //     top: BorderSide(
                                                    //         color: Color(0xffECECEE)))

                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            AppRoutes
                                                                .friendsProfileDetail,
                                                            arguments: {
                                                              'userId': comment
                                                                  .userId,
                                                              "userName":
                                                                  comment
                                                                      .userName
                                                            });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    16.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              height: 25,
                                                              width: 25,
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 6),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: comment
                                                                          .userProfilePic
                                                                          .isNotEmpty
                                                                      ? DecorationImage(
                                                                          image: CachedNetworkImageProvider(comment
                                                                              .userProfilePic),
                                                                          fit: BoxFit
                                                                              .cover)
                                                                      : null),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: comment
                                                                      .userProfilePic
                                                                      .isNotEmpty
                                                                  ? null
                                                                  : CustomText(
                                                                      text: (comment.userName.isNotEmpty
                                                                              ? post
                                                                                  .userName
                                                                              : "")
                                                                          .toLowerCase()
                                                                          .substring(
                                                                              0,
                                                                              1)
                                                                          .toUpperCase(),
                                                                      fontSize:
                                                                          12,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // CustomText(
                                                                //     text: post.name,
                                                                //     fontSize: 12,
                                                                //     fontWeight:
                                                                //         FontWeight.w600),
                                                                CustomText(
                                                                    text: comment
                                                                        .userName,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                CustomText(
                                                                    text: comment
                                                                        .content,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 3,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (comment
                                                                            .isLikedByCurrentUser) {
                                                                          context
                                                                              .read<CommentCubit>()
                                                                              .unlikeComment(comment.id);
                                                                        } else {
                                                                          context
                                                                              .read<CommentCubit>()
                                                                              .likeComment(comment.id);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        comment.isLikedByCurrentUser
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_outline_rounded,
                                                                        size:
                                                                            16,
                                                                        color: comment.isLikedByCurrentUser
                                                                            ? Colors.red
                                                                            : const Color(0xff3F3D4E),
                                                                      ),
                                                                    ),
                                                                    comment.likes <
                                                                            1
                                                                        ? const SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              const SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              CustomText(
                                                                                text: comment.likes.toString(),
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      width: 16,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        selectedCommnet =
                                                                            comment;
                                                                        setState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .mode_comment_outlined,
                                                                        size:
                                                                            16,
                                                                        color: Color(
                                                                            0xff3F3D4E),
                                                                      ),
                                                                    ),
                                                                    comment.repliesCount <
                                                                            1
                                                                        ? const SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              const SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              CustomText(
                                                                                text: comment.repliesCount.toString(),
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              viewCommnets.isEmpty
                                                  ? SizedBox()
                                                  : (viewCommnets
                                                          .where((element) =>
                                                              element.id ==
                                                              comment.id)
                                                          .isNotEmpty)
                                                      ? ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: comment
                                                              .replies.length,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            final replie =
                                                                comment.replies[
                                                                    index];
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 40),
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          16),
                                                              decoration: const BoxDecoration(
                                                                  // color: Colors.red,
                                                                  // border: Border(
                                                                  //     top: BorderSide(
                                                                  //         color:
                                                                  //             Color(0xffECECEE)))
                                                                  ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            16.0),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              25,
                                                                          width:
                                                                              25,
                                                                          margin:
                                                                              const EdgeInsets.only(top: 6),
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.black,
                                                                              shape: BoxShape.circle,
                                                                              image: replie.userProfilePic.isNotEmpty ? DecorationImage(image: CachedNetworkImageProvider(replie.userProfilePic), fit: BoxFit.cover) : null),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child: replie.userProfilePic.isNotEmpty
                                                                              ? null
                                                                              : CustomText(
                                                                                  text: (replie.name.isNotEmpty
                                                                                          ? replie.name
                                                                                          : replie.userName.isNotEmpty
                                                                                              ? replie.userName
                                                                                              : "")
                                                                                      .toLowerCase()
                                                                                      .substring(0, 1)
                                                                                      .toUpperCase(),
                                                                                  fontSize: 12,
                                                                                  textColor: Colors.white,
                                                                                ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            // CustomText(
                                                                            //     text: post.name,
                                                                            //     fontSize: 12,
                                                                            //     fontWeight:
                                                                            //         FontWeight.w600),
                                                                            CustomText(
                                                                                text: replie.userName,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600),
                                                                            const SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            CustomText(
                                                                                text: replie.content,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 3,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w400),
                                                                            const SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    if (replie.isLikedByCurrentUser) {
                                                                                      context.read<CommentCubit>().unlikeComment(comment.id, isReply: true, replyId: replie.id);
                                                                                    } else {
                                                                                      context.read<CommentCubit>().likeComment(comment.id, isReply: true, replyId: replie.id);
                                                                                    }
                                                                                  },
                                                                                  child: Icon(
                                                                                    replie.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_outline_rounded,
                                                                                    size: 14,
                                                                                    color: replie.isLikedByCurrentUser ? Colors.red : const Color(0xff3F3D4E),
                                                                                  ),
                                                                                ),
                                                                                replie.likes < 1
                                                                                    ? const SizedBox()
                                                                                    : Row(
                                                                                        children: [
                                                                                          const SizedBox(
                                                                                            width: 4,
                                                                                          ),
                                                                                          CustomText(
                                                                                            text: replie.likes.toString(),
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                // const SizedBox(
                                                                                //   width:
                                                                                //       16,
                                                                                // ),
                                                                                // GestureDetector(
                                                                                //   onTap:
                                                                                //       () {
                                                                                //     context.read<CommentCubit>().addComment(
                                                                                //         post.postId,
                                                                                //         "This is my  comment");
                                                                                //   },
                                                                                //   child:
                                                                                //       const Icon(
                                                                                //     Icons
                                                                                //         .mode_comment_outlined,
                                                                                //     size:
                                                                                //         14,
                                                                                //     color:
                                                                                //         Color(0xff3F3D4E),
                                                                                //   ),
                                                                                // ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : SizedBox(),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 60),
                                                child: Row(
                                                  children: [
                                                    comment.repliesCount > 0
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              if (viewCommnets
                                                                      .isNotEmpty &&
                                                                  viewCommnets
                                                                      .where((element) =>
                                                                          element
                                                                              .id ==
                                                                          comment
                                                                              .id)
                                                                      .isNotEmpty) {
                                                                viewCommnets.removeWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        comment
                                                                            .id);
                                                                setState(() {});
                                                              } else {
                                                                context
                                                                    .read<
                                                                        CommentCubit>()
                                                                    .fetchCommentsByCommentId(
                                                                        comment
                                                                            .postId,
                                                                        comment
                                                                            .id)
                                                                    .then(
                                                                        (value) {
                                                                  viewCommnets.add(
                                                                      comment);
                                                                  setState(
                                                                      () {});
                                                                });
                                                              }
                                                            },
                                                            child: Text(viewCommnets
                                                                        .isNotEmpty &&
                                                                    viewCommnets
                                                                        .where((element) =>
                                                                            element.id ==
                                                                            comment.id)
                                                                        .isNotEmpty
                                                                ? "hide replies"
                                                                : "view replies"))
                                                        : SizedBox(),
                                                  ],
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    default:
                                      return const SizedBox();
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 180,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                selectedCommnet == null
                                    ? SizedBox()
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color:
                                            Color(0xff5348EE).withOpacity(0.1),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                margin: const EdgeInsets.only(
                                                    top: 6),
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                    image: selectedCommnet
                                                                ?.userProfilePic
                                                                .isNotEmpty ??
                                                            false
                                                        ? DecorationImage(
                                                            image: CachedNetworkImageProvider(
                                                                selectedCommnet!
                                                                    .userProfilePic),
                                                            fit: BoxFit.cover)
                                                        : null),
                                                alignment: Alignment.center,
                                                child: selectedCommnet
                                                            ?.userProfilePic
                                                            .isNotEmpty ??
                                                        false
                                                    ? null
                                                    : CustomText(
                                                        text: (selectedCommnet
                                                                        ?.userName
                                                                        .isNotEmpty ??
                                                                    true
                                                                ? selectedCommnet
                                                                        ?.userName ??
                                                                    ""
                                                                : "")
                                                            .toLowerCase()
                                                            .substring(0, 1)
                                                            .toUpperCase(),
                                                        fontSize: 12,
                                                        textColor: Colors.white,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            CustomText(
                                                text:
                                                    "Replying to ${selectedCommnet?.userName ?? ''}",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                            Spacer(),
                                            GestureDetector(
                                                onTap: () {
                                                  selectedCommnet = null;
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.close))
                                          ],
                                        ),
                                      ),
                                Container(
                                  // height: 60,
                                  constraints: const BoxConstraints(
                                    maxHeight: 180,
                                  ),

                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          top: BorderSide(
                                              color: const Color(0xff726E80)
                                                  .withOpacity(0.15)))),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomInputField(
                                          focusNode: focusNode,
                                          hintText: "Write your comment",
                                          maxLines: null,
                                          controller: _commnetController,
                                          onChanged: (value) {
                                            if (value.isEmpty && allowReply) {
                                              allowReply = false;

                                              setState(() {});
                                            } else {
                                              if (!allowReply) {
                                                allowReply = true;
                                                setState(() {});
                                              }
                                            }
                                          },
                                        ),
                                        allowReply
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  CustomButton(
                                                    text: "Reply",
                                                    onPressed: () {
                                                      if (selectedCommnet !=
                                                          null) {
                                                        context
                                                            .read<
                                                                CommentCubit>()
                                                            .addComment(
                                                                post.postId,
                                                                _commnetController
                                                                    .text
                                                                    .trim(),
                                                                parentCommentId:
                                                                    selectedCommnet
                                                                        ?.id)
                                                            .then((value) {
                                                          selectedCommnet =
                                                              null;
                                                          setState(() {});
                                                        });
                                                      } else {
                                                        context
                                                            .read<
                                                                CommentCubit>()
                                                            .addComment(
                                                              post.postId,
                                                              _commnetController
                                                                  .text
                                                                  .trim(),
                                                            );
                                                      }
                                                      _commnetController.text =
                                                          "";
                                                      if (focusNode.hasFocus) {
                                                        focusNode.unfocus();
                                                      }
                                                      setState(() {});
                                                    },
                                                    height: 30,
                                                    color:
                                                        const Color(0xff5348EE),
                                                    textSize: 10,
                                                    width: 60,
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  );

                default:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
