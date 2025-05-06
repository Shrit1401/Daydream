import '../global.css';
import { useFonts } from '@expo-google-fonts/instrument-serif/useFonts';

import { InstrumentSerif_400Regular_Italic } from '@expo-google-fonts/instrument-serif/400Regular_Italic';
import { Stack } from 'expo-router';

export default function Layout() {
  let [fontsLoaded] = useFonts({
    InstrumentSerif_400Regular_Italic,
  });

  if (!fontsLoaded) {
    return null;
  }
  return (
    <Stack
      screenOptions={{
        headerShown: false,
      }}
    />
  );
}
