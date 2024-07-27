import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/common/ui/posting_progress_ui.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/service/app_routes.dart';
import 'package:palette_generator/palette_generator.dart';

class CommunityDetail extends StatefulWidget {
  const CommunityDetail({super.key, required this.img});
  final String img;

  @override
  State<CommunityDetail> createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail>
    with SingleTickerProviderStateMixin {
  PaletteGenerator? _tempGenerator;
  PaletteGenerator? _paletteGenerator;
  bool loading = false;
  late TabController tabController;
  final controller = ScrollController();
  bool topSafe = false;
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    loading = true;
    _extractColors();

    controller.addListener(() {
      if (controller.offset > 230) {
        if (_tempGenerator == null) {
          _tempGenerator = _paletteGenerator;
          topSafe = true;
          setState(() {});
        }
      } else {
        if (_tempGenerator != null) {
          topSafe = false;
          _tempGenerator = null;
          setState(() {});
        }
      }
    });
  }

  Future<void> _extractColors() async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(widget.img),
    );

    setState(() {
      _paletteGenerator = paletteGenerator;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: null,
      //   surfaceTintColor: Colors.white,
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     "Name",
      //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: Stack(
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: _tempGenerator == null
                  ? null
                  : LinearGradient(
                      colors: [
                        _tempGenerator!.darkMutedColor?.color ?? Colors.white,
                        _tempGenerator!.darkMutedColor?.color ?? Colors.white,
                        _tempGenerator!.lightVibrantColor?.color ?? Colors.grey,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.3, 1.0]),
            ),
          ),
          loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: NestedScrollView(
                    controller: controller,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          backgroundColor:
                              Colors.transparent, // Make the AppBar transparent
                          elevation: 0,
                          expandedHeight: 300.0,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            // title: Text('SliverAppBar'),
                            background: Container(
                              color: Colors.black,
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: <Color>[
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black,
                                      Colors.black,
                                    ],
                                    stops: [0.0, 0.6, 0.9, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstOut,
                                child: Container(
                                  height: 380,
                                  // width: 85,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      // shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.img),
                                          fit: BoxFit.cover)),
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                          // leading: IconButton(
                          //   icon: Icon(
                          //     Icons.arrow_back,
                          //     color: Colors.white,
                          //   ),
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          titleSpacing: 0,
                          centerTitle: false,
                          leading: null,
                          // elevation: 0,

                          automaticallyImplyLeading: false,
                          leadingWidth: 0,
                          // backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.white,
                          title: Container(
                            height: kToolbarHeight,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: _tempGenerator == null
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        _tempGenerator!.darkMutedColor?.color ??
                                            Colors.white,
                                        _tempGenerator!.darkMutedColor?.color ??
                                            Colors.white,
                                        _tempGenerator!
                                                .lightVibrantColor?.color ??
                                            Colors.grey,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: [0.0, 0.2, 1.0]),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                CustomText(
                                  text: "Name",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
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
                                  labelColor: const Color(0xffffffff),
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
                                  indicatorSize: TabBarIndicatorSize.label,
                                  indicator: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(
                                            0xffffffff), // Custom color for the underline
                                        width:
                                            3.0, // Custom thickness for the underline
                                      ),
                                    ),
                                  ),
                                  tabs: const [
                                    Tab(
                                      height: 40,
                                      text: "Post",
                                    ),
                                    Tab(
                                      height: 40,
                                      text: "Media",
                                    ),
                                    // Tab(
                                    //   height: 40,
                                    //   text: "Media",
                                    // ),
                                    // Tab(
                                    //   height: 40,
                                    //   text: "Media",
                                    // ),
                                  ]),
                              _paletteGenerator),
                        ),
                      ];
                    },
                    body: SafeArea(
                      top: topSafe,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<PostCubit>()
                                .fetchPosts(isRefresh: true);
                          },
                          child: SingleChildScrollView(
                            child: Column(children: [
                              // PostingProgress(),
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
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: successState.posts.length +
                                            (state.hasMore ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (index ==
                                              successState.posts.length) {
                                            paginate();
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          final post =
                                              successState.posts[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, AppRoutes.postDetail,
                                                  arguments: {
                                                    "postId": post.postId
                                                  });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      top: BorderSide(
                                                          color: Color(
                                                              0xffECECEE)))),
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
                                                            'userId':
                                                                post.userId,
                                                            "userName":
                                                                post.userName
                                                          });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 35,
                                                            width: 35,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: post
                                                                        .userProfilePic
                                                                        .isNotEmpty
                                                                    ? DecorationImage(
                                                                        image: CachedNetworkImageProvider(post
                                                                            .userProfilePic),
                                                                        fit: BoxFit
                                                                            .cover)
                                                                    : null),
                                                            alignment: Alignment
                                                                .center,
                                                            child: post
                                                                    .userProfilePic
                                                                    .isNotEmpty
                                                                ? null
                                                                : CustomText(
                                                                    text: (post.name.isNotEmpty
                                                                            ? post.name
                                                                            : post.userName.isNotEmpty
                                                                                ? post.userName
                                                                                : "")
                                                                        .toLowerCase()
                                                                        .substring(0, 1)
                                                                        .toUpperCase(),
                                                                    fontSize:
                                                                        18,
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
                                                              CustomText(
                                                                  text:
                                                                      post.name,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                              CustomText(
                                                                  text:
                                                                      "@${post.userName}",
                                                                  textColor:
                                                                      const Color(
                                                                          0xff384747),
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  post.img.isNotEmpty
                                                      ? Container(
                                                          width:
                                                              double.infinity,
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxHeight:
                                                                      350,
                                                                  minHeight:
                                                                      200),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16),
                                                          // width: 45,
                                                          decoration:
                                                              BoxDecoration(
                                                                  // shape: BoxShape.circle,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                  image: DecorationImage(
                                                                      image: CachedNetworkImageProvider(post
                                                                          .img),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                        )
                                                      : const SizedBox(),
                                                  SizedBox(
                                                    height: post.img.isEmpty
                                                        ? 0
                                                        : 12,
                                                  ),
                                                  post.content.isEmpty
                                                      ? const SizedBox()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16.0),
                                                          child: CustomText(
                                                              text:
                                                                  post.content,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
                                                              fontSize: 16,
                                                              textColor:
                                                                  const Color(
                                                                      0xff384747),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                  SizedBox(
                                                    height: post.content.isEmpty
                                                        ? 0
                                                        : 12,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16.0),
                                                    child: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (post
                                                                .isLikedByCurrentUser) {
                                                              context
                                                                  .read<
                                                                      PostCubit>()
                                                                  .unlikePost(post
                                                                      .postId);
                                                            } else {
                                                              context
                                                                  .read<
                                                                      PostCubit>()
                                                                  .likePost(post
                                                                      .postId);
                                                            }
                                                          },
                                                          // child: Icon(
                                                          //   post.isLikedByCurrentUser
                                                          //       ? Icons.favorite
                                                          //       : Icons.favorite_outline_rounded,
                                                          //   size: 24,
                                                          //   color: post.isLikedByCurrentUser
                                                          //       ? Color(0xFFF44336)
                                                          //       : const Color(0xff726E80),
                                                          // ),
                                                          child:
                                                              SvgPicture.asset(
                                                            post.isLikedByCurrentUser
                                                                ? 'assets/images/favorite-filled.svg'
                                                                : 'assets/images/favorite.svg',
                                                            height: 24,
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
                                                                    text: post
                                                                        .likes
                                                                        .toString(),
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ],
                                                              ),
                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                AppRoutes
                                                                    .postDetail,
                                                                arguments: {
                                                                  "postId": post
                                                                      .postId
                                                                });
                                                          },
                                                          // child: Icon(Icons.mode_comment_outlined,
                                                          //     size: 24,
                                                          //     color: const Color(0xff726E80)),
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/images/comment-outline.svg',
                                                            height: 26,
                                                          ),
                                                        ),
                                                        post.commentCount < 1
                                                            ? SizedBox()
                                                            : Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  CustomText(
                                                                    text: post
                                                                        .commentCount
                                                                        .toString(),
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ],
                                                              ),
                                                        // SizedBox(
                                                        //   width: 16,
                                                        // ),
                                                        // Icon(
                                                        //   Icons.share,
                                                        //   size: 24,
                                                        //   color: const Color(0xff726E80),
                                                        // ),
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.75,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()));
                                  }
                                },
                              )
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final PaletteGenerator? _tempGenerator;

  _SliverAppBarDelegate(this._tabBar, this._tempGenerator);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: _tempGenerator == null
            ? null
            : LinearGradient(
                colors: [
                  _tempGenerator!.darkMutedColor?.color ?? Colors.white,
                  _tempGenerator!.darkMutedColor?.color ?? Colors.white,
                  _tempGenerator!.lightVibrantColor?.color ?? Colors.grey,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.2, 1.0]),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
