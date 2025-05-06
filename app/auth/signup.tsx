import { Text, View, TextInput, TouchableOpacity, Alert, Image } from 'react-native';
import React, { useState } from 'react';
import { Container } from '~/components/common/Container';
import InstrumentText from '~/components/common/InstruemenText';
import { Button } from '~/components/common/Button';
import { FirebaseError } from 'firebase/app';
import { Link } from 'expo-router';

import { auth } from '~/utils/firebase';
import { createUserWithEmailAndPassword, updateCurrentUser, updateProfile } from 'firebase/auth';

export default function SignUp() {
  const [firstName, setFirstName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSignUp = async () => {
    if (!firstName || !email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    createUserWithEmailAndPassword(auth, email, password)
      .then(async (userCredential) => {
        const user = userCredential.user;
        await updateProfile(user, {
          displayName: firstName,
        });
        Alert.alert('Success', 'Account created successfully');
      })
      .catch((error: unknown) => {
        let errorMessage = 'An unknown error occurred';
        if (error instanceof FirebaseError) {
          errorMessage = error.message;
        } else if (error instanceof Error) {
          errorMessage = error.message;
        }
        Alert.alert('Sign-Up Failed', errorMessage);
      })
      .finally(() => setLoading(false));
  };

  const handleGoogleSignUp = async () => {
    setLoading(true);
    try {
      Alert.alert('Info', 'Google sign-up requires Expo AuthSession implementation');
    } catch (error: unknown) {
      let errorMessage = 'An unknown error occurred';
      if (error instanceof FirebaseError) {
        errorMessage = error.message;
      } else if (error instanceof Error) {
        errorMessage = error.message;
      }
      Alert.alert('Google Sign-Up Failed', errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container>
      <View className="w-full flex-1 items-center justify-center px-8">
        <InstrumentText className="mb-10 text-[60px] text-black">Sign Up</InstrumentText>

        <View className="mb-6 w-full">
          <Text className="mb-2 font-semibold text-gray-700">First Name</Text>
          <TextInput
            className="w-full rounded-lg border border-black/50 bg-white p-4 text-black/60"
            placeholder="Enter your first name"
            value={firstName}
            onChangeText={setFirstName}
            autoCapitalize="words"
          />
        </View>

        <View className="mb-6 w-full">
          <Text className="mb-2 font-semibold text-gray-700">Email</Text>
          <TextInput
            className="w-full rounded-lg border border-black/50 bg-white p-4 text-black/60"
            placeholder="Enter your email"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
        </View>

        <View className="mb-8 w-full">
          <Text className="mb-2 font-semibold text-gray-700">Password</Text>
          <TextInput
            className="w-full rounded-lg border border-black/50 bg-white p-4 text-black/60"
            placeholder="Create a password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />
        </View>

        <Button
          title={loading ? 'Creating Account...' : 'Sign Up'}
          className="mb-4 w-full"
          disabled={loading}
          onPress={handleSignUp}
        />

        <View className="my-4 w-full flex-row items-center">
          <View className="h-[1px] flex-1 bg-gray-300" />
          <Text className="mx-4 text-gray-500">OR</Text>
          <View className="h-[1px] flex-1 bg-gray-300" />
        </View>

        <TouchableOpacity
          className="mb-8 w-full flex-row items-center justify-center rounded-full border border-gray-300 bg-white p-4"
          onPress={handleGoogleSignUp}
          disabled={loading}>
          <Image
            source={require('~/assets/googleIcon.png')}
            className="h-6 w-6"
            resizeMode="contain"
          />
          <Text className="ml-2 font-semibold text-gray-700">Sign up with Google</Text>
        </TouchableOpacity>

        <Link href="/auth/login" asChild>
          <TouchableOpacity>
            <Text className="text-indigo-600">I already have an account</Text>
          </TouchableOpacity>
        </Link>
      </View>
    </Container>
  );
}
