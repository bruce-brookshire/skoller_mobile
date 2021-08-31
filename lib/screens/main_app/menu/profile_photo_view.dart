import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:skoller/tools.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart' as cam;

class ProfilePhotoSourceModal extends StatelessWidget {
  final bool isJobs;

  ProfilePhotoSourceModal({this.isJobs = false});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isJobs ? SKColors.dark_gray : Colors.white;
    final promptTextColor = isJobs ? Colors.white : SKColors.dark_gray;
    final actionColor =
        isJobs ? SKColors.jobs_light_green : SKColors.skoller_blue;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Add some personality!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: promptTextColor),
            ),
            SizedBox(height: 4),
            Text(
              'Upload a picture for your ${isJobs ? 'job ' : ''}profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: promptTextColor),
            ),
            SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (_) => Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (_) => ProfilePhotoView(),
                  fullscreenDialog: true,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: actionColor,
                  boxShadow: UIAssets.boxShadow,
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Take photo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (_) async {

                final ImagePicker _picker = ImagePicker();
                // Pick an image
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                final imageFile = File(image!.path);

                final loader = SKLoadingScreen.fadeIn(context);
                SKUser.current!
                    .uploadProfilePhoto(imageFile.path)
                    .then((response) {
                  if (![200, 204].contains(response))
                    throw 'Unable to upload photo';

                  return Auth.tokenLogin();
                }).then((response) {
                  if (!response) throw 'Unable to update user';

                  DartNotificationCenter.post(
                      channel: NotificationChannels.userChanged);
                  return SKUser.current!.getJobProfile();
                }).then((response) {
                  if (!response.wasSuccessful())
                    throw 'Unable to fetch job profile';

                  DartNotificationCenter.post(
                      channel: NotificationChannels.jobsChanged);
                  loader.fadeOut();
                  Navigator.pop(context);
                }).catchError((error) {
                  loader.fadeOut();
                  DropdownBanner.showBanner(
                      text: error is String ? error : 'Unable to upload photo.',
                      color: SKColors.warning_red,
                      textStyle: TextStyle(color: Colors.white));
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: actionColor,
                  boxShadow: UIAssets.boxShadow,
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Select from library',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (SKUser.current?.avatarUrl != null) ...[
              SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) async {
                  final loader = SKLoadingScreen.fadeIn(context);
                  print(await SKUser.current?.deleteProfilePhoto());
                  await Auth.tokenLogin();
                  DartNotificationCenter.post(
                      channel: NotificationChannels.userChanged);
                  loader.fadeOut();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: SKColors.warning_red,
                    boxShadow: UIAssets.boxShadow,
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Remove photo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class ProfilePhotoView extends StatefulWidget {
  @override
  State createState() => _ProfilePhotoViewState();
}

class _ProfilePhotoViewState extends State<ProfilePhotoView> {
  // Add two variables to the state class to store the CameraController and
  // the Future.
  cam.CameraController? _controller;
  File? imageFile;

  @override
  void initState() {
    super.initState();

    cam
        .availableCameras()
        // Get first front facing camera
        .then((cameras) => cameras.firstWhere(
            (camera) => camera.lensDirection == cam.CameraLensDirection.front))
        // Initialize camera
        .then((camera) {
      if (camera != null) {
        final controller =
            cam.CameraController(camera, cam.ResolutionPreset.high);

        controller.initialize().then((_) {
          setState(() => this._controller = controller);
        });
      } else
        throw 'No front facing camera available';
    })
        // Handle errors
        .catchError((error) {
      String errorMsg = (error is String) ? error : 'Error initializing camera';

      DropdownBanner.showBanner(text: errorMsg);
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();

    if (imageFile != null) imageFile!.delete();

    super.dispose();
  }

  void tappedTakePhoto(_) async {
    try {
      // Construct the path where the image should be saved using the path
      // package.
      final path =
          (await getTemporaryDirectory()).path + '${DateTime.now()}.png';

      // Attempt to take a picture and log where it's been saved.

      await _controller!.takePicture().then((XFile? file) {
        if (mounted) {
          setState(() {
            imageFile = File(file!.path);
          });
        }
      });
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  void tappedRemovePhoto(_) {
    imageFile!.delete();
    setState(() {
      imageFile = null;
    });
  }

  void tappedSavePhoto(_) async {
    final loader = SKLoadingScreen.fadeIn(context);

    final tempDir = await getTemporaryDirectory();
    final image = img.decodeImage(imageFile!.readAsBytesSync());

    final jpegImage = File('${tempDir.path}/upload_img.jpeg')
      ..writeAsBytesSync(
          img.encodeJpg(img.copyRotate(image!, 90), quality: 100));

    await SKUser.current?.uploadProfilePhoto(jpegImage.path).then((response) {
      if (![200, 204].contains(response)) throw 'Unable to upload photo';

      return Auth.tokenLogin();
    }).then((response) {
      if (!response) throw 'Failed to fetch user';

      DartNotificationCenter.post(channel: NotificationChannels.userChanged);

      loader.fadeOut();
      Navigator.pop(context);
    }).catchError((error) {
      loader.fadeOut();

      DropdownBanner.showBanner(
          text: error is String ? error : 'Unable to upload photo.',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white));
    });

    jpegImage.delete();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    if (_controller == null)
      children = [
        Expanded(
          child: Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ];
    else {
      final cameraChild = imageFile == null
          ? cam.CameraPreview(_controller!)
          : Image.file(imageFile!);

      children = [
        Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SKColors.background_gray,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 1.75),
                blurRadius: 3.5,
              )
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Transform.scale(
                scale: (1 / _controller!.value.aspectRatio) + 0.02,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: cameraChild,
                  ),
                ),
              ),
            ),
          ),
        ),
        ...createActionButtons()
      ];
    }

    return SKNavView(
      title: 'Capture Profile Photo',
      children: children,
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
    );
  }

  List<Widget> createActionButtons() {
    final captureAction = imageFile == null;

    final actionColor =
        captureAction ? SKColors.skoller_blue : SKColors.success;
    final icon = captureAction ? Icons.camera_alt : Icons.save;
    final action = captureAction ? tappedTakePhoto : tappedSavePhoto;
    final actionText = captureAction ? 'Capture' : 'Save';

    return [
      GestureDetector(
        onTapUp: action,
        child: Container(
          margin: EdgeInsets.only(top: 24, left: 16, right: 16),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: actionColor,
            boxShadow: UIAssets.boxShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Text(
                actionText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      if (!captureAction)
        Padding(
          padding: EdgeInsets.only(top: 24),
          child: GestureDetector(
            onTapUp: tappedRemovePhoto,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.settings_backup_restore,
                    color: SKColors.warning_red,
                    size: 18,
                  ),
                ),
                Text(
                  'Retake',
                  style: TextStyle(
                    color: SKColors.warning_red,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
