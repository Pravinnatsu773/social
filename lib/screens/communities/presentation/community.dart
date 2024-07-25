import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social4/common/ui/custom_text.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<String> imageList = [
    'https://w0.peakpx.com/wallpaper/375/113/HD-wallpaper-one-piece-anime-one-piece-anime.jpg',
    'https://i.pinimg.com/1200x/8f/15/d8/8f15d863b017fa69c4cd2fccd03641fc.jpg',
    'https://e1.pxfuel.com/desktop-wallpaper/69/955/desktop-wallpaper-best-laptop-anime.jpg',
    'https://www.colorwallpapers.com/uploads/wallpaper/bts-laptop-wallpapers/width-853/h3VeVMHqxSCG-free-bts-music-wallpaper-downloads.jpg',
    'https://w0.peakpx.com/wallpaper/971/593/HD-wallpaper-ed-sheeran-iphone-pc-mobile.jpg',
    'https://wallpapercave.com/wp/wp7981888.jpg',
    'https://images7.alphacoders.com/135/thumb-350-1355221.png'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              itemCount: imageList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xffECECEE),
                      )),
                  height: 400,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: imageList[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            const CustomText(
                                text:
                                    "Anime Haven: Your Ultimate Community for All Things Anime",
                                fontSize: 18,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w700),
                            const SizedBox(
                              height: 8,
                            ),
                            const CustomText(
                                text:
                                    "Welcome to Anime Haven, the ultimate community for anime enthusiasts! Join us to discuss your favorite series, discover new recommendations, share fan art, and connect with like-minded fans from around the world. Whether you're a seasoned otaku or just starting your anime journey, Anime Haven is your go-to place for everything anime. Let's celebrate our love for anime together!",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                fontSize: 14,
                                textColor: Color(0xff384747),
                                fontWeight: FontWeight.w400),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                ...List.generate(
                                    5,
                                    (index) => index == 4
                                        ? const CustomText(
                                            text: "219 members",
                                            fontSize: 14,
                                            // maxLines: 2,
                                            textColor: Color(0xff384747),
                                            // overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w500)
                                        : Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            height: 30,
                                            width: 30,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: CachedNetworkImageProvider(
                                                        'https://wallpapersmug.com/thumb/d0eb43/monkey-d-luffy-one-piece-aime.jpg'),
                                                    fit: BoxFit.cover)),
                                          ))
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
