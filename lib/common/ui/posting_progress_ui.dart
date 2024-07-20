import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/service/shared_preference_service.dart';

class PostingProgress extends StatelessWidget {
  PostingProgress({super.key});

  final sharedPreferencesService = SharedPreferencesService();
  @override
  Widget build(BuildContext context) {
    final userId = sharedPreferencesService.getString("userID") ?? "";
    final name = sharedPreferencesService.getString("name") ?? "";
    final userName = sharedPreferencesService.getString("userName") ?? "";
    final profilePic = sharedPreferencesService.getString("profilePic") ?? "";
    return BlocBuilder<PostingProgressCubit, PostingProgressState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case PostingProgressLoading:
            return Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              image: profilePic.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          profilePic),
                                      fit: BoxFit.cover)
                                  : null),
                          alignment: Alignment.center,
                          child: profilePic.isNotEmpty
                              ? null
                              : CustomText(
                                  text: (name.isNotEmpty
                                          ? name
                                          : userName.isNotEmpty
                                              ? userName
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                                text: name,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            CustomText(
                                text: "@${userName}",
                                textColor: const Color(0xff726E80),
                                fontSize: 12,
                                fontWeight: FontWeight.w500)
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  LinearProgressIndicator()
                ],
              ),
            );

          default:
            return SizedBox.shrink();
        }
      },
    );
  }
}
