import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


void main() {
  GetStorage storage = GetStorage();
  final String storageKey = 'history';
  storage.remove(storageKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => PageCubit(),
        child: FirstPage(),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrPage()),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.fill,
              alignment: Alignment.bottomCenter,
            )
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              Text(
                'Накорми ТУРБОСВИНА!!!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 450),
              Text(
                'Нажмите, чтобы войти на кафедру АСУ',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RegistrPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.account_balance_outlined,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            // Открыть новый экран
            Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderBoardPage()));
          },
        ),
        title: const Text('Перепись населения'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fon.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),


          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Кто ты, кормильщик?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Как имя твоё?',
                  ),
                  keyboardType: TextInputType.text,
                  controller: _usernameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Как тебя называть то!?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String username = _usernameController.text;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SavedDataPage(username)),
                      );
                    }
                  },
                  child: const Text('Готово'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
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


class LeaderBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PageCubit(),
      child: _LeaderBoardPage(),
    );
  }
}

class _LeaderBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pageCubit = BlocProvider.of<PageCubit>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.accessible_forward_sharp,
            color: Colors.white,
            size: 45,
          ),
          onPressed: () {
            // Открыть новый экран
            Navigator.pop(context, MaterialPageRoute(builder: (context) => RegistrPage()));
          },
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Почётные кормильщики",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<PageCubit, PageState>(
        builder: (context, state) {
          final history = pageCubit.getHistoryFromStorage();

          if (history == null) {
            return const Center(
              child: Text(
                'Героев ещё не было',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          history.sort((a, b) => a['seconds'].compareTo(b['seconds']));

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final operation = history[index];
              final firstNumber = operation['username'];
              final secondNumber = operation['seconds'];

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Герой ${index + 1}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Имя: $firstNumber',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Время: $secondNumber',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}




class SavedDataPage extends StatelessWidget {
  final String username;
  SavedDataPage(this.username);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PageCubit(),
      child: MainPage(username),
    );
  }
}

class MainPage extends StatelessWidget {
  final String username;
  MainPage(this.username);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<PageCubit, PageState>(
        builder: (context, state) {
          if (state is Page1State) {
            return GamePage(username);
          } else if (state is Page2State) {
            return VictoryPage(name: state.name, time: state.time);
          }else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}



class GamePage extends StatefulWidget {
  final String username;

  GamePage(this.username);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int seconds = 0;
  Timer? secondsTimer;
  double health = 100;
  Timer? regenTimer;
  String goblinImage = 'assets/goblin1.png';
  bool isVictory = false;


  @override
  void initState() {
    super.initState();
    startSecondsTimer();
    startRegenTimer();
    startPhraseTimer();
  }

  @override
  void dispose() {
    secondsTimer?.cancel();
    regenTimer?.cancel();
    super.dispose();
  }

  void startSecondsTimer() {
    secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isVictory) {
        secondsTimer?.cancel(); // Остановка таймера при победе
        return;
      }
      setState(() {
        seconds++;
      });
    });
  }
  bool showContinueText = false;

  void startRegenTimer() {
    regenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (health <= 0) {
        regenTimer?.cancel();
        setState(() {
          goblinImage = 'assets/nogoblin.png';
          isVictory = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            showContinueText = true;
          });
        });
        return;
      }
      setState(() {
        if (health <= 70 && health > 30) {
          goblinImage = 'assets/goblin2.png';
          health += 2;
        } else if (health <= 30 && health > 0) {
          goblinImage = 'assets/goblin3.png';
          health += 6;
        } else if (health < 100 && health > 70){
          goblinImage = 'assets/goblin1.png';
          health += 1;
        }
      });
    });
  }

  void handleTap() {
    if (isVictory) {
      return;
    }
    setState(() {
      health -= 1;
    });
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/battle.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$seconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: const Text(
                  'ТУРБОСВИН',
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 100,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  health > 0 ? phrases[currentPhraseIndex] : phrases1[currentPhraseIndex1],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 70,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              top: 220,
              right: 100,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 400, 5, 0),
                child: Image.asset(
                  goblinImage,
                  width: 600,
                  height: 600,
                ),
              ),
            ),
            Visibility(
              visible: health <= 0,
              child: Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (showContinueText == true) {
                      context.read<PageCubit>().showPage2(widget.username, seconds);
                    }

                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        'ВЫ ЕГО НАКОРМИЛИ!!!',
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Image.asset(
                          'assets/goblin4.png',
                          width: 650,
                          height: 650,
                        ),
                      ),

                      const SizedBox(),
                      Visibility(
                        visible: showContinueText,
                        child: const Text(
                          'Нажмите, чтобы продолжить',
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                width: 10,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: LinearProgressIndicator(
                    value: health / 100,
                    valueColor: _getHealthBarColor(),
                    backgroundColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getHealthBarColor() {
    if (health <= 30) {
      return const AlwaysStoppedAnimation<Color>(Colors.red);
    } else if (health <= 70) {
      return const AlwaysStoppedAnimation<Color>(Colors.yellow);
    } else {
      return const AlwaysStoppedAnimation<Color>(Colors.green);
    }
  }

  final List<String> phrases = [
    'Где кружки?!',
    'А мне нравится',
    'Работаю на кафедре',
    'Будет по плохому',
    'Не хотите по хорошему?',
    'Не знал что ты многодетная мать...',
    'Скажи ты у нас в Кубе\n согласен выступать?',
    'Я работаю на кафедре\n и мне все нравится',
    'Пупсикам помогали в семестре',
    'У нас у самих экзамены',
    'Пупсики мои, информация для тех\n кто более-менее нормально ходил.\n Я вам всем сделал подарок,\n когда сдавал статистику',
    'Привет, что делаешь в 3 часа ночи?',
  ];

  final List<String> phrases1 = [
    'Ты... накормил... меня.',
  ];

  int currentPhraseIndex = 0;
  int currentPhraseIndex1 = 0;

  List<int> shuffledIndices = [];

  void generateShuffledIndices() {
    shuffledIndices = List<int>.generate(phrases.length, (index) => index);
    shuffledIndices.shuffle();
  }

  int getNextRandomIndex() {
    if (shuffledIndices.isEmpty) {
      generateShuffledIndices();
    }
    int nextIndex = shuffledIndices.removeAt(0);
    return nextIndex;
  }

  void startPhraseTimer() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (health > 0) {
        setState(() {

          currentPhraseIndex = getNextRandomIndex();
        });
      } else {
        timer.cancel();
        setState(() {
          currentPhraseIndex1 = Random().nextInt(phrases1.length);
        });
      }
    });
  }

}

class VictoryPage extends StatelessWidget {
  final String name;
  final int time;

  VictoryPage({required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fon.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "Герой: $name",
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 20, width: 10),
                  Text(
                    "Время: $time",
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100, width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: const Text(
                "Теперь домой",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


abstract class PageState{}

class Page1State extends PageState{}
class Page2State extends PageState{
  String name;
  int time;
  Page2State({required this.name, required this.time});
}

class PageCubit extends Cubit<PageState> {
  PageCubit() : super(Page1State());

  final GetStorage storage = GetStorage();
  final String storageKey = 'history';

  void showPage1() {
    emit(Page1State());
  }

  void showPage2(String username, int seconds) {
    saveData(username, seconds);

    emit(Page2State(name: username, time: seconds));
  }

  void saveData(String username, int seconds) {
    List<Map<String, dynamic>>? history = storage.read<List<dynamic>>(storageKey)?.cast<Map<String, dynamic>>();
    if (history == null) {
      history = [];
    }

    history.add({
      'username': username,
      'seconds': seconds,
    });

    storage.write(storageKey, history);
  }

  List<Map<String, dynamic>>? getHistoryFromStorage() {
    return storage.read<List<Map<String, dynamic>>>(storageKey);
  }
}
