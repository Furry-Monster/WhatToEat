import 'package:flutter/material.dart';
import 'package:witch_one/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:witch_one/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:witch_one/widgets/animated_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  int _easterEggCounter = 0;
  bool _showEasterEgg = false;

  static const String _githubAvatarUrl =
      'https://avatars.githubusercontent.com/u/144710426';
  static const String _githubUrl = 'https://github.com/Furry-Monster';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void _triggerEasterEgg() {
    setState(() {
      _easterEggCounter++;
      if (_easterEggCounter >= 7) {
        _showEasterEgg = true;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎉 我并不是彩蛋！'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('选择困难？其实答案一直都在你心里。\n\n'
                    '纠结要吃什么的时候，闭上眼睛深呼吸，\n'
                    '第一个出现在脑海中的美食，\n'
                    '就是你现在最想吃的。\n\n'
                    '生活就是这么简单，\n'
                    '不要把选择变成负担。\n\n'
                    '— 来自开发者的小建议 😊'),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/icons/icon.png',
                  width: 64,
                  height: 64,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('明白了'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _showAboutInfo() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: '吃什么',
        applicationVersion: _version,
        applicationIcon: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _githubAvatarUrl,
            width: 64,
            height: 64,
            placeholder: (context, url) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person),
            ),
          ),
        ),
        children: [
          const Text(
            '这是一个帮助选择困难症患者决定吃什么的应用。\n\n'
            '特点：\n'
            '• 支持自定义分类和标签\n'
            '• 记录消费历史\n'
            '• 现代化的渐变式UI\n'
            '• iOS,安卓,Windows,Mac,Linux多端跨平台\n\n'
            '灵感来源于我和我的啥比舍友的日常\n'
            '希望能帮助你解决"吃什么"这个宇宙终极难题！\n\n'
            '听说点7下about框框可以发现彩蛋喵！',
          ),
          const Divider(),
          InkWell(
            onTap: () => _launchGithub(),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _githubAvatarUrl,
                    width: 32,
                    height: 32,
                    placeholder: (context, url) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Furry Monster',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '开发者',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGithub() async {
    final uri = Uri.parse(_githubUrl);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开链接')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: AnimatedBackground(
        child: ListView(
          children: [
            const SizedBox(height: AppTheme.spacingNormal),
            ListTile(
              title: const Text('关于'),
              subtitle: Text('版本 $_version'),
              trailing: _showEasterEgg ? const Icon(Icons.egg_outlined) : null,
              onTap: () {
                _triggerEasterEgg();
                _showAboutInfo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
