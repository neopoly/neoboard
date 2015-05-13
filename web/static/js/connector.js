import Api from "./api"

class Connector {
  constructor(url) {
    this.api        = new Api(url)
    this.listeners  = []
    this.connected  = false
    this.channels   = []
  }
  addListener(listener) {
    this.listeners.push(listener);
  }
  establish() {
    this.api.connect()
    this.connected = true
    this._notify()
  }
  join(name) {
    return this.getChannel(name) || this._joinChannel(name)
  }
  get isConnected() {
    return this.connected
  }
  getChannel(name) {
    return _.find(this.channels, c => c.name === name)
  }
  _notify() {
    this.listeners.forEach(l => l())
  }
  _joinChannel(name) {
    this.api.join(name, board => {
      this.channels.push(board)
      this._notify()
    })
  }
}

export default new Connector("/ws")