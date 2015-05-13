import {Socket} from "phoenix"
import Channel from "./channel"

export default class Api {
  constructor(url) {
    this.socket = new Socket(url)
  }
  connect() {
    this.socket.connect()
  }
  join(name, callback) {
    this.channel = new Channel(this.socket, name)
    this.channel.join(callback)
  }
}