import {Socket} from "phoenix";

const App = {
  run() {
    let socket = new Socket("/ws");
    socket.connect();
    let channel = socket.chan("board:neo", {});
    channel.join().receive("ok", () => {
      console.log("Welcome to the board channel");

      channel.on("time:state", state => {
        console.log("time:state", state);
        document.write(state.now + "<br>");
      });
    })
  }
};

export default App;
