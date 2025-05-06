import React from 'react';
import { Text, TextProps } from 'react-native';

interface InstrumentTextProps extends TextProps {}

const InstrumentText: React.FC<InstrumentTextProps> = ({ style, children, ...restProps }) => {
  return (
    <Text
      style={[
        {
          fontFamily: 'InstrumentSerif_400Regular_Italic',
        },
        style,
      ]}
      {...restProps}>
      {children}
    </Text>
  );
};

export default InstrumentText;
