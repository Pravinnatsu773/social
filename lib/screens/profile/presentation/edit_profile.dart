import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_input_field.dart';
import 'package:social4/common/ui/custom_text.dart';
import 'package:social4/screens/profile/cubit/profile_cubit.dart';
import 'package:social4/service/shared_preference_service.dart';

class EditProfile extends StatefulWidget {
  final VoidCallback callBack;
  const EditProfile({super.key, required this.callBack});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final sharedPreferencesService = SharedPreferencesService();
  bool isLoading = false;
  String profilePic = "";
  String userId = "";
  final userNameController = TextEditingController();

  final nameController = TextEditingController();

  final bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    userId = sharedPreferencesService.getString("userID") ?? "";
    nameController.text = sharedPreferencesService.getString("name") ?? "";
    userNameController.text =
        sharedPreferencesService.getString("userName") ?? "";
    profilePic = sharedPreferencesService.getString("profilePic") ?? "";

    bioController.text = sharedPreferencesService.getString("bio") ?? "";
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Optional: Adjust the image quality
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          // height: 200,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery);
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.image_outlined,
                      color: Color(0xff5348EE),
                      size: 28,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    CustomText(
                      text: "Photos",
                      fontWeight: FontWeight.w500,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.camera);
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xff5348EE),
                      size: 28,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    CustomText(
                      text: "Photos",
                      fontWeight: FontWeight.w500,
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          // Container(
          //   padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
          //   child: CustomButton(
          //     text: "Save",
          //     onPressed: () {
          //       Navigator.pop(
          //         context,
          //       );
          //     },
          //     textSize: 12,
          //     width: 60,
          //   ),
          // )
        ],
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? SizedBox(
                  height: 2,
                  child: const LinearProgressIndicator(
                    color: Color(0xff5348EE),
                  ),
                )
              : const SizedBox(
                  height: 2,
                ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showBottomSheet(context);
                        },
                        child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image:
                                    _imageFile == null && profilePic.isNotEmpty
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                profilePic),
                                            fit: BoxFit.cover)
                                        : null),
                            alignment: Alignment.center,
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(150),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      height: 120,
                                      width: 120,
                                    ),
                                  )
                                : profilePic.isNotEmpty
                                    ? null
                                    : CustomText(
                                        text: (nameController.text.isNotEmpty
                                                ? nameController.text
                                                : userNameController
                                                        .text.isNotEmpty
                                                    ? userNameController.text
                                                    : "")
                                            .toLowerCase()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        textColor: Colors.white,
                                        fontSize: 42)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: "Full Name",

                        fontSize: 16,
                        // textColor: Color(0xff9794A1),
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomInputField(
                        enabled: !isLoading,
                        hintText: "Full Name",
                        // allowSpace: false,
                        controller: nameController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const CustomText(
                        text: "Username",
                        fontSize: 16,
                        // textColor: Color(0xff9794A1),
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomInputField(
                        enabled: !isLoading,
                        hintText: "username",
                        allowSpace: false,
                        controller: userNameController,
                        prefix: Container(
                          // width: 12,
                          alignment: Alignment.centerRight,
                          child: const Text(
                            "@",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff8F8D9B),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        onChanged: (value) {},
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const CustomText(
                        text: "Bio",
                        fontSize: 16,
                        // textColor: Color(0xff9794A1),
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomInputField(
                        enabled: !isLoading,
                        hintText: "Bio",
                        maxLines: 5,
                        // allowSpace: false,
                        controller: bioController,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(
                            color: const Color(0xff726E80).withOpacity(0.15)))),
                child: CustomButton(
                    text: "Save",
                    color: isLoading
                        ? const Color(0xff5348EE).withOpacity(0.6)
                        : null,
                    onPressed: () {
                      if (!isLoading) {
                        isLoading = true;
                        setState(() {});
                        context
                            .read<ProfileCubit>()
                            .updateUserProfile(
                                name: nameController.text.trim(),
                                username: userNameController.text.trim(),
                                bio: bioController.text.trim(),
                                image: _imageFile)
                            .then((value) {
                          isLoading = false;
                          setState(() {});
                          Navigator.pop(context);
                        });
                      }
                    }),
              ))
        ],
      ),
    );
  }
}
