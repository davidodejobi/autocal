extension StringExtension on String {
  /// [get asset paths]
  /// [Shared]
  String get svg => 'assets/svgs/$this.svg';
  String get png => 'assets/images/$this.png';
  String get jpg => 'assets/images/$this.jpg';
  String get json => 'assets/json/$this.json';
  String get lottie => 'assets/lottie/$this.lottie';
  String get rive => 'assets/rive/$this.riv';

  /// [Auth]
  String get authSvg => 'assets/svgs/auth/$this.svg';
  String get homeSvg => 'assets/svgs/home/$this.svg';
  String get studySetSvg => 'assets/svgs/studyset/$this.svg';

  String get sharedPng => 'assets/images/shared/$this.png';
  String get studySetPng => 'assets/images/studyset/$this.png';
  String get homePng => 'assets/images/home/$this.png';
}
