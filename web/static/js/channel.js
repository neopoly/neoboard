class Channel {
  constructor(socket, name) {
    this.socket = socket
    this._name = name
    this.chan = socket.chan(this.name, {})
  }
  join(callback) {
    this.chan.join().receive("ok", () => {
      this._after_join()
      callback(this)
    })
  }
  on(...args) {
    this.chan.on(...args)
  }
  off(...args) {
    this.chan.off(...args)
  }
  get name() {
    return this._name
  }
  _after_join() {
    console.log(`Joined: ${this._name}`)
  }
}

export default Channel
