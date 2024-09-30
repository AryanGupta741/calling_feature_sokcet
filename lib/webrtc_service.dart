import 'package:calling_feature_socket_webrtc/socket_server.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'socket_service.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  SocketService socketService;

  WebRTCService(this.socketService) {
    _initializeWebRTC();
  }

  // Initialize WebRTC
  void _initializeWebRTC() async {
    // Get the local media stream
    localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ],
      // Explicitly set Unified Plan
      'sdpSemantics': 'unified-plan',
    };

    // Create the peer connection
    peerConnection = await createPeerConnection(config);

    // Add each track from the local stream to the peer connection (replace addStream)
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Handle ICE candidates
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      socketService.socket?.emit('iceCandidate', {'candidate': candidate.toMap()});
    };
  }

  // Initiate a call
  Future<void> initiateCall(String targetID) async {
    // Create offer
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    // Emit the offer to the target user
    socketService.emitCallUser(targetID, socketService.socket!.id!, offer.toMap());
  }

  // Answer a call
  Future<void> createAnswer(signal, String from) async {
    // Set the remote description with the received offer
    await peerConnection?.setRemoteDescription(RTCSessionDescription(signal['sdp'], signal['type']));

    // Create answer
    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    // Emit the answer to the caller
    socketService.emitAnswerCall(from, answer.toMap());
  }
}
