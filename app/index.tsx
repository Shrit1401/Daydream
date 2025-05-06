import React from 'react';
import { Image, SafeAreaView, View, Text } from 'react-native';
import InstrumentText from '~/components/common/InstruemenText';
import { GradientButton } from '~/components/common/GradientButton';
import Animated, {
  FadeIn,
  FadeInDown,
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withTiming,
  Easing,
  interpolate,
} from 'react-native-reanimated';
const wallpaper = require('~/assets/wallpaper.png');

export default function Home() {
  // Animation for floating title effect
  const floating = useSharedValue(0);

  // Start the floating animation when component mounts
  React.useEffect(() => {
    floating.value = withRepeat(
      withTiming(1, { duration: 2000, easing: Easing.inOut(Easing.sin) }),
      -1,
      true
    );
  }, []);

  const floatingStyle = useAnimatedStyle(() => {
    const translateY = interpolate(floating.value, [0, 1], [0, -8]);

    return {
      transform: [{ translateY }],
    };
  });

  return (
    <>
      <Image
        source={wallpaper}
        className="absolute h-full w-full"
        style={{ resizeMode: 'cover' }}
      />
      <SafeAreaView className="flex-1 justify-between px-5 pb-10">
        <Animated.View
          className="mt-24 items-center"
          style={floatingStyle}
          entering={FadeIn.duration(1200).delay(300)}>
          <InstrumentText
            className="text-[80px] text-black"
            style={{
              textShadowColor: 'rgba(255, 255, 255, 0.5)',
              textShadowOffset: { width: 1, height: 1 },
              textShadowRadius: 5,
            }}>
            Daydream
          </InstrumentText>
          <Animated.View entering={FadeIn.duration(1500).delay(800)}>
            <Text className="mt-1 text-center text-[22px] font-bold text-black">
              a story journal
            </Text>
          </Animated.View>
        </Animated.View>
        <View className="w-full px-5">
          <Animated.View entering={FadeInDown.duration(1000).delay(1200).springify()}>
            <GradientButton href="/auth/login" title="Login" className="mb-4" />
          </Animated.View>
          <Animated.View entering={FadeInDown.duration(1000).delay(1500).springify()}>
            <GradientButton href="/auth/signup" title="Signup" />
          </Animated.View>
        </View>
      </SafeAreaView>
    </>
  );
}
