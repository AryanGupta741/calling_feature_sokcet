import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  // Connect to Socket.IO server
  void connect() {
    socket = IO.io('http://<your-ip-address>:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket?.on('connect', (_) {
      print("Connected with ID: ${socket!.id}");
    });
  }

  // Receive your own ID from the server
  void onReceiveID(Function(String) callback) {
    socket?.on('yourID', (id) {
      callback(id);
    });
  }

  // Listen for callMade event
  void onCallMade(Function(dynamic, String) callback) {
    socket?.on('callMade', (data) {
      callback(data['signal'], data['from']);
    });
  }

  // Emit callUser event
  void emitCallUser(String targetID, String myID, dynamic signal) {
    socket?.emit('callUser', {
      'userToCall': targetID,
      'from': myID,
      'signal': signal,
    });
  }

  // Emit answerCall event
  void emitAnswerCall(String from, dynamic signal) {
    socket?.emit('answerCall', {
      'to': from,
      'signal': signal,
    });
  }
}
