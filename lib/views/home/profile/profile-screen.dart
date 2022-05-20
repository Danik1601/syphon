import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syphon/global/colors.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/store/alerts/actions.dart';
import 'package:syphon/store/auth/actions.dart';
import 'package:syphon/store/hooks.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/settings/theme-settings/model.dart';
import 'package:syphon/store/settings/theme-settings/selectors.dart';
import 'package:syphon/store/user/model.dart';
import 'package:syphon/store/user/selectors.dart';
import 'package:syphon/views/behaviors.dart';
import 'package:syphon/views/widgets/avatars/avatar.dart';
import 'package:syphon/views/widgets/buttons/button-solid.dart';
import 'package:syphon/views/widgets/input/text-field-secure.dart';
import 'package:syphon/views/widgets/modals/modal-image-options.dart';
import 'package:touchable_opacity/touchable_opacity.dart';

final title = Strings.titleProfile;
const imageSize = Dimensions.avatarSizeDetails;

class ProfileScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dispatch = useDispatch();

    final user = useSelector<AppState, User>(
      (state) => state.authStore.user,
    );
    final loading = useSelector<AppState, bool>(
      (state) => state.authStore.loading,
    );
    final themeType = useSelector<AppState, ThemeType>(
      (state) => state.settingsStore.themeSettings.themeType,
    );

    final userIdState = useState(user.userId);
    final avatarFileState = useState<File?>(null);
    final displayNameState = useState(user.displayName);

    // TODO: switch to destructuring when released
    final userIdNew = userIdState.value;
    final avatarFileNew = avatarFileState.value;
    final displayNameNew = displayNameState.value;

    final userIdController = useTextEditingController();
    final displayNameController = useTextEditingController();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final backgroundColor = selectAvatarBackground(themeType);
    final hasNewInfo = avatarFileNew != null || displayNameNew != null || userIdNew != null;

    final onCopyToClipboard = useCallback(() async {
      await Clipboard.setData(ClipboardData(text: user.userId));
      dispatch(addInfo(message: 'Copied User ID to clipboard')); //TODO i18n
    }, [dispatch, user]);

    final onShowImageOptions = useCallback(() async {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => ModalImageOptions(
          onSetNewAvatar: ({File? image}) {
            avatarFileState.value = image;
          },
        ),
      );
    }, [context]);

    final onSaveProfile = useCallback(({
      File? avatarFileNew,
      String? userIdNew,
      String? displayNameNew,
    }) async {
      if (displayNameNew != null && user.displayName != displayNameNew) {
        final bool successful = dispatch(
          updateDisplayName(displayNameNew),
        );
        if (!successful) return false;
      }

      if (avatarFileNew != null) {
        final bool successful = dispatch(
          updateAvatar(localFile: avatarFileNew),
        );
        if (!successful) return false;
      }

      dispatch(fetchAuthUserProfile());
      return true;
    }, [user]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: DefaultScrollBehavior(),
        child: SingleChildScrollView(
          // eventually expand as profile grows
          child: Container(
            padding: Dimensions.appPaddingHorizontal,
            constraints: BoxConstraints(
              maxHeight: height * 0.9,
              maxWidth: width,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          Container(
                            width: imageSize,
                            height: imageSize,
                            child: GestureDetector(
                              onTap: () => onShowImageOptions(),
                              child: Avatar(
                                uri: avatarFileNew != null ? null : user.avatarUri,
                                file: avatarFileNew,
                                alt: formatUsername(user),
                                size: imageSize,
                                background: AppColors.hashedColorUser(user),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 2,
                            child: Container(
                              width: Dimensions.iconSizeLarge,
                              height: Dimensions.iconSizeLarge,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.iconSizeLarge,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    offset: Offset.zero,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).iconTheme.color,
                                size: Dimensions.iconSizeLite,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 6,
                            child: Container(
                              width: Dimensions.iconSizeLarge,
                              height: Dimensions.iconSizeLarge,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.iconSizeLarge,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    offset: Offset.zero,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: Theme.of(context).iconTheme.color,
                                size: Dimensions.iconSizeLite,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            constraints: BoxConstraints(
                              maxHeight: Dimensions.inputHeight,
                              maxWidth: Dimensions.inputWidthMax,
                            ),
                            child: TextFieldSecure(
                              label: 'Display Name',
                              controller: displayNameController,
                              onChanged: (name) {
                                displayNameState.value = name;
                              },
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.all(8.0),
                              constraints: BoxConstraints(
                                maxHeight: Dimensions.inputHeight,
                                maxWidth: Dimensions.inputWidthMax,
                              ),
                              child: Row(children: [
                                TextFieldSecure(
                                  disabled: false,
                                  readOnly: true,
                                  onChanged: null,
                                  enableInteractiveSelection: false,
                                  label: 'User ID',
                                  controller: userIdController,
                                  mouseCursor: MaterialStateMouseCursor.clickable,
                                  onTap: () async => onCopyToClipboard(),
                                  suffix: IconButton(
                                    onPressed: () async => onCopyToClipboard(),
                                    icon: Icon(Icons.copy),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(8.0),
                              child: ButtonSolid(
                                text: Strings.buttonSave,
                                loading: loading,
                                disabled: loading || !hasNewInfo,
                                onPressed: () async {
                                  final bool successful = await onSaveProfile(
                                    userIdNew: null,
                                    avatarFileNew: avatarFileNew,
                                    displayNameNew: displayNameNew,
                                  );
                                  if (successful) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: Dimensions.inputHeight,
                              margin: const EdgeInsets.all(10.0),
                              constraints: BoxConstraints(
                                minWidth: Dimensions.buttonWidthMin,
                                minHeight: Dimensions.buttonHeightMin,
                              ),
                              child: Visibility(
                                child: TouchableOpacity(
                                  activeOpacity: 0.4,
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    Strings.buttonCancel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
