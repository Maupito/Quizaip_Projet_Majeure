import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:quiz/quizmulti.dart';

class JoinRoom extends StatefulWidget {
  final String pseudo;

  const JoinRoom({Key? key, required this.pseudo}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  TextEditingController roomIdController = TextEditingController();
  late IO.Socket socket;

  void joinRoom() {
    final String roomId = roomIdController.text;
    socket.emit('joinRoom', roomId);

    // Rediriger vers la salle après avoir rejoint
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomPage(roomId, socket)),
    );
  }

  @override
  void initState() {
    socket = IO.io('http://10.2.0.216:3000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());
    socket.connect();
    socket.on('StartQuiz', (data) {
      String receivedCategory = data['category']; // Récupérer la valeur de category
      String receivedDifficulty = data['difficulty']; // Récupérer la valeur de difficulty
      int receivedNumber = data['number'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizMulti(
            category: receivedCategory,
            difficulty: receivedDifficulty,
            number: receivedNumber,
            roomId: roomIdController.text,
            pseudo: widget.pseudo,
          ),
        ),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 380.0,
              height: 130.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: joinRoom,
                  splashColor: Colors.pink.withOpacity(0.5),
                  highlightColor: Colors.pink.withOpacity(0.2),
                  child: const Center(
                    child: Text(
                      'Rejoindre',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomPage extends StatelessWidget {
  final String roomId;
  final IO.Socket socket;

  const RoomPage(this.roomId, this.socket, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined Room ID: $roomId',
              style: const TextStyle(fontSize: 20),
            ),
            // Autres contenus de la salle...
          ],
        ),
      ),
    );
  }
}