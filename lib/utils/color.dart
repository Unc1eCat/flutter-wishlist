import 'package:flutter/rendering.dart';
import 'math.dart';

extension HSVColorUtilExtension on HSVColor {
  Color get rgb => toColor();
  HSLColor get hsl => HSLColor.fromColor(rgb);

  HSVColor get opaque => withAlpha(255);
  HSVColor get transparent => withAlpha(0);

  HSVColor get withInvertedHue => withHueRotated(180); 
  HSVColor get withInvertedSaturation => withSaturation(1.0 - saturation);
  HSVColor get withInvertedValue => withValue(1.0 - value);

  /// stretch is from 0.0 to 2.0. 
  /// 1.0 is the same color, 
  /// 2.0 is white, 
  /// 0.0 gives 0.0 saturation
  HSVColor withSaturationStretched(double stretch) => withSaturation(saturation.zeroStretch(stretch, 1.0));
  /// stretch is from 0.0 to 2.0. 
  /// 1.0 is the same color, 
  /// 0.0 is black, 
  /// 2.0 gives 1.0 value
  HSVColor withValueStretched(double stretch) => withValue(value.zeroStretch(stretch, 1.0));

  /// 360.0 means full rotation, the same color
  HSVColor withHueRotated(double hueRotationDegrees) => withHue((hue + hueRotationDegrees) % 360.0);

  HSVColor blendWithSvInverted(double amount) => HSVColor.fromAHSV(alpha, hue, saturation + amount * (1.0 - 2 * saturation), value + amount * (1.0 - 2 * value));
  HSVColor blendWithSaturationInverted(double amount) => withSaturation(saturation + amount * (1.0 - 2 * saturation));
  HSVColor blendWithValueInverted(double amount) => withValue(value + amount * (1.0 - 2 * value));
  
  HSVColor withFarthestLerpOfSv(double amount) => HSVColor.fromAHSV(alpha, hue, saturation.zeroOneFarthestLerp(amount), value.zeroOneFarthestLerp(amount));
  HSVColor withFarthestLerpOfSaturation(double amount) => withSaturation(saturation.zeroOneFarthestLerp(amount));
  HSVColor withFarthestLerpOfValue(double amount) => withValue(value.zeroOneFarthestLerp(amount));
  
  HSVColor withClosestLerpOfSv(double amount) => HSVColor.fromAHSV(alpha, hue, saturation.zeroOneClosestLerp(amount), value.zeroOneClosestLerp(amount));
  HSVColor withClosestLerpOfSaturation(double amount) => withSaturation(saturation.zeroOneClosestLerp(amount));
  HSVColor withClosestLerpOfValue(double amount) => withValue(value.zeroOneClosestLerp(amount));
}
extension HSLColorUtilExtension on HSLColor {
  Color get rgb => toColor();
  HSVColor get hsv => HSVColor.fromColor(rgb);
  
  HSLColor get opaque => withAlpha(255);
  HSLColor get transparent => withAlpha(0);

  HSLColor get withInvertedHue => withHueRotated(180); 
  HSLColor get withInvertedSaturation => withSaturation(1.0 - saturation);
  HSLColor get withInvertedLightness => withLightness(1.0 - lightness);

  HSLColor get withRoundedLightness => withLightness(lightness.round().toDouble());

  /// stretch is from 0.0 to 2.0. 
  /// 1.0 is the same color, 
  /// 2.0 is white, 
  /// 0.0 gives 0.0 saturation
  HSLColor withSaturationStretched(double stretch) => withSaturation(saturation.zeroStretch(stretch, 1.0));
  /// stretch is from 0.0 to 2.0. 
  /// 1.0 is the same color, 
  /// 0.0 is black, 
  /// 2.0 gives 1.0 lightness
  HSLColor withLightnessStretched(double stretch) => withLightness(lightness.zeroStretch(stretch, 1.0));

  /// 360.0 means full rotation, the same color
  HSLColor withHueRotated(double hueRotationDegrees) => withHue((hue + hueRotationDegrees) % 360.0);

  HSLColor blendWithSlInverted(double amount) => HSLColor.fromAHSL(alpha, hue, saturation + amount * (1.0 - 2 * saturation), lightness + amount * (1.0 - 2 * lightness));
  HSLColor blendWithSaturationInverted(double amount) => withSaturation(saturation + amount * (1.0 - 2 * saturation));
  HSLColor blendWithLightnessInverted(double amount) => withLightness(lightness + amount * (1.0 - 2 * lightness));
  
  HSLColor withFarthestLerpOfSaturation(double amount) => withSaturation(saturation.zeroOneFarthestLerp(amount));
  HSLColor withFarthestLerpOfLightness(double amount) => withLightness(lightness.zeroOneFarthestLerp(amount));
  
  HSLColor withClosestLerpOfSaturation(double amount) => withSaturation(saturation.zeroOneClosestLerp(amount));
  HSLColor withClosestLerpOfLightness(double amount) => withLightness(lightness.zeroOneClosestLerp(amount));
}

// argb
extension ColorUtilExtension on Color {
  HSVColor get hsv => HSVColor.fromColor(this);
  HSLColor get hsl => HSLColor.fromColor(this);

  Color get opaque => withAlpha(255);
  Color get transparent => withAlpha(0);

  Color get rgbInverted => Color(value ^ 0x00FFFFFF);
  Color get argbInverted => Color(~value);

  /// Amount is from 0.0 to 1.0
  Color? blendedWithRgbInversion(double amount) => Color.lerp(this, rgbInverted, amount);
  Color? blendedWithArgbInversion(double amount) => Color.lerp(this, argbInverted, amount);
}
