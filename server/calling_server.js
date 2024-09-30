// Install the required packages: npm install express socket.io
const express = require("express");
const http = require("http");
const socketIo = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

io.on("connection", (socket) => {
  console.log("New user connected with socket id: ", socket.id);

  // Emit socket ID to the newly connected user
  socket.emit("yourID", socket.id);

  // Handle call event
  socket.on("callUser", (data) => {
    io.to(data.userToCall).emit("callMade", { signal: data.signal, from: data.from });
  });

  // Handle answering the call
  socket.on("answerCall", (data) => {
    io.to(data.to).emit("callAnswered", data.signal);
  });

  // Handle disconnection
  socket.on("disconnect", () => {
    console.log("User disconnected", socket.id);
  });
});

server.listen(5000, () => {
  console.log("Server is running on port 5000");
});
