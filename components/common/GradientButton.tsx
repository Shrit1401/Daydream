import { forwardRef } from 'react';
import {
  TouchableOpacity,
  TouchableOpacityProps,
  View,
  StyleSheet,
  ColorValue,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import InstrumentText from './InstruemenText';
import { Link, RelativePathString } from 'expo-router';
type GradientButtonProps = {
  title: string;
  colors?: readonly [ColorValue, ColorValue, ...ColorValue[]];
  style?: any;
  href: string;
} & TouchableOpacityProps;

export const GradientButton = forwardRef<View, GradientButtonProps>(
  ({ title, colors = ['#000', '#111', '#333'], style, href, ...touchableProps }, ref) => {
    return (
      <Link href={href as RelativePathString} asChild>
        <TouchableOpacity
          ref={ref}
          {...touchableProps}
          style={[styles.touchable, style]}
          activeOpacity={0.8}>
          <LinearGradient
            colors={colors}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={styles.gradient}>
            <InstrumentText style={styles.text}>{title}</InstrumentText>
          </LinearGradient>
        </TouchableOpacity>
      </Link>
    );
  }
);

const styles = StyleSheet.create({
  touchable: {
    width: '80%',
    alignSelf: 'center',
  },
  gradient: {
    alignItems: 'center',
    borderRadius: 9999,
    paddingHorizontal: 16,
    paddingVertical: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 5,
    elevation: 8,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  text: {
    textAlign: 'center',
    fontSize: 26,
    fontStyle: 'italic',
    color: 'white',
    fontWeight: 'bold',
    alignContent: 'center',
    textShadowRadius: 2,
  },
});
