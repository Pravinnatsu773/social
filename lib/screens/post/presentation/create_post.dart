import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social4/common/cubit/posting_progress_cubit.dart';
import 'package:social4/common/model/user_model.dart';
import 'package:social4/common/ui/custom_button.dart';
import 'package:social4/common/ui/custom_input_field.dart';
import 'package:social4/screens/auth/cubit/auth_cubit.dart';
import 'package:social4/screens/post/cubit/post_cubit.dart';
import 'package:social4/screens/profile/cubit/profile_post_cubit.dart';
import 'package:social4/service/shared_preference_service.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(String, File?) callBack;
  const CreatePostScreen({super.key, required this.callBack});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  int contentLimit = 1000;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  final sharedPreferencesService = SharedPreferencesService();

  String profilePic = "";
  String userId = "";
  String userName = "";

  String name = "";

  String bio = "";

  @override
  void initState() {
    super.initState();
    initializeUserData();
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

  String _cleanText() {
    String text = _contentController.text;
    // Remove multiple line breaks and replace them with a single space
    text = text.replaceAll(RegExp(r'\n+'), '\n');
    text = text.replaceAll(RegExp(r' +'), ' ');
    // // Update the text field with cleaned text
    // _contentController.text = text;
    return text;
  }

  initializeUserData() {
    userId = sharedPreferencesService.getString("userID") ?? "";
    name = sharedPreferencesService.getString("name") ?? "";
    userName = sharedPreferencesService.getString("userName") ?? "";
    profilePic = sharedPreferencesService.getString("profilePic") ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
            child: CustomButton(
              text: "post",
              onPressed: () {
                widget.callBack(_cleanText(), _imageFile);
                Navigator.pop(
                  context,
                );
              },
              textSize: 12,
              width: 60,
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          "Create a Post",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
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
                                : Text(
                                    (name.isNotEmpty
                                            ? name
                                            : userName.isNotEmpty
                                                ? userName
                                                : "")
                                        .toLowerCase()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        hintText: "Whats on your mind?",
                        showBorder: false,
                        maxLines: null,
                        maxLength: 1000,
                        onChanged: (value) {
                          setState(() {});
                        },
                        controller: _contentController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _imageFile != null
                          ? Stack(
                              children: [
                                Container(
                                  height: 300,
                                  width: double.infinity,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _imageFile = null;
                                        setState(() {});
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(12),
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.4)),
                                        child: Icon(Icons.close_rounded),
                                      ),
                                    ))
                              ],
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(
                              color: Color(0xff726E80).withOpacity(0.15)))),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: Icon(
                          Icons.image_outlined,
                          color: const Color(0xff5348EE),
                          size: 28,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.camera);
                        },
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: const Color(0xff5348EE),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Text((contentLimit - _contentController.text.length)
                          .toString()),
                      const SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            value:
                                _contentController.text.length / contentLimit,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xff5348EE)),
                            backgroundColor:
                                Color(0xff726E80).withOpacity(0.15),
                          ))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
