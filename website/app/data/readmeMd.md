# privacy shit (yes you should actually read this)

yo — i'll keep this simple. i hate privacy policies that are 47 pages of lawyer speak. here's the deal:

## what we take

- just your basic info (email, name) via firebase
- some usage stats so we know if the app is broken

![Firebase](https://i.postimg.cc/jdY9fxtK/image.png)
only you name, email and date of creation of the account. nothing else. you can see it in the image above.

## what we DON'T take

- your actual journal entries/notes
- any of your private thoughts
- literally anything personal

![Coding](https://i.postimg.cc/xC5M8d1g/image.png)
if you know flutter then, hive is the database library we're using.
Hive automatically encrypts the data, so we don't have to do anything.
and is probably then sole best tool for local storage in flutter

to read the code [click here](https://github.com/Shrit1401/Daydream/blob/main/lib/utils/hive/hive_local.dart)

## how we handle your data

- your notes NEVER leave your device
- we built on [hack club's custom linux servers](https://guides.hackclub.app/index.php/Main_Page) (s/o to them for supporting teen builders with actual hardware)
- we're using llama-3.3-70b-versatile model running LOCALLY in the linux server
  ![Hackclub](https://i.postimg.cc/9QR1ryTM/image.png)
  this is the server's api call we're using to generate the response
  if you have little idea then llama models can't work without a server, so we're using a custom server.

## why you can trust us

- completely open source — [check our code](https://github.com/Shrit1401/Daydream)
- built at [hack club](https://hackclub.com/) where privacy isn't just marketing
- we built this for ourselves first
- hack club sponsors us btw so you're email is safe with us

and still, if you don't trust us, it's best to not use the app.

questions? i'm literally [shrit1401@gmail.com](mailto:shrit1401@gmail.com) — email me and i'll actually respond.

ps: we're open source so if you don't believe me, check the repo and call me out

![Daydream](https://i.postimg.cc/sDFv7b8s/image.png)
